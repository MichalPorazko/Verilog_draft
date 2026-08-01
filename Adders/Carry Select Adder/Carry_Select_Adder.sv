module csla_uniform #(
    parameter int WIDTH = 16,
    parameter int BLOCK_W = 4,
    parameter bit FIRST_BLOCK_SELECT = 1'b0
) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic             cin,
    output logic [WIDTH-1:0] sum,
    output logic             cout
);
    localparam int NUM_BLOCKS = (WIDTH + BLOCK_W - 1) / BLOCK_W;

    logic [NUM_BLOCKS:0] csel;
    assign csel[0] = cin;

    for (genvar g = 0; g < NUM_BLOCKS; g++) begin : G_BLK
        localparam int LSB = g * BLOCK_W;
        localparam int WB  = (LSB + BLOCK_W <= WIDTH) ? BLOCK_W : (WIDTH - LSB);

        if ((g == 0) && !FIRST_BLOCK_SELECT) begin : G_FIRST_RCA
            rca_block #(.W(WB)) u_rca (
                .a   (a[LSB +: WB]),
                .b   (b[LSB +: WB]),
                .cin (csel[0]),
                .sum (sum[LSB +: WB]),
                .cout(csel[1])
            );
        end
        else begin : G_CS
            logic [WB-1:0] s0, s1;
            logic          c0, c1;
            logic          sel;

            assign sel = (g == 0) ? cin : csel[g];

            rca_block #(.W(WB)) u_rca0 (
                .a   (a[LSB +: WB]),
                .b   (b[LSB +: WB]),
                .cin (1'b0),
                .sum (s0),
                .cout(c0)
            );

            rca_block #(.W(WB)) u_rca1 (
                .a   (a[LSB +: WB]),
                .b   (b[LSB +: WB]),
                .cin (1'b1),
                .sum (s1),
                .cout(c1)
            );

            assign sum[LSB +: WB] = sel ? s1 : s0;
            assign csel[g+1]      = sel ? c1 : c0;
        end
    end

    assign cout = csel[NUM_BLOCKS];
endmodule



module csla_sqrt #(
    parameter int WIDTH = 16,
    parameter bit FIRST_BLOCK_SELECT = 1'b0,
    parameter int BASE_W   // 0 = choose K automatically
) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic             cin,
    output logic [WIDTH-1:0] sum,
    output logic             cout
);

    // Ideal width of block idx before the last "remainder" adjustment
    function automatic int ideal_block_w(input int idx, input int k);
        begin
            if (FIRST_BLOCK_SELECT)
                ideal_block_w = k + idx;              // K, K+1, K+2, ...
                $$display("ideal_block_w, FIRST_BLOCK_SELECT, idx: %d , k: %d, ideal_block_w = k + idx = %d", idx, k, ideal_block_w);
            else if (idx == 0)
                ideal_block_w = k;                    // K
                $$display("ideal_block_w, idx == 0, idx: %d , k: %d, ideal_block_w = k", idx, k);
            else
                ideal_block_w = k + idx - 1;          // K, K+1, K+2, ...
                $$display("ideal_block_w, else, idx: %d , k: %d, ideal_block_w = k + idx - 1 = %d", idx, k, ideal_block_w);
        end
    endfunction

    // Number of blocks needed to cover WIDTH bits
    function automatic int blocks_for_k(input int width, input int k);
        int s, p;
        begin
            s = 0;
            p = 0;
            $$display("blocks_for_k, start: width: %d, k: %d", width, k);
            while (s < width) begin
                s += ideal_block_w(p, k);
                $$display("blocks_for_k, loop: p: %d, s: %d, ideal_block_w(p, k): %d", p, s, ideal_block_w(p, k));
                p++;
            end
            blocks_for_k = p;
            $$display("blocks_for_k, end: p: %d", p);
        end
    endfunction

    // Simple delay metric under tmux = tcarry
    function automatic int delay_for_k(input int width, input int k);
        int p;
        begin
            p = blocks_for_k(width, k);
            if (FIRST_BLOCK_SELECT)
                delay_for_k = k + p;      // first block has RCA + mux
            else
                delay_for_k = k + p - 1;  // first block is plain RCA
        end
    endfunction

    // Choose K automatically
    function automatic int choose_k(input int width);
        int k, p, d;
        int best_k, best_p, best_d;
        begin
            best_k = 1;
            best_p = blocks_for_k(width, 1);
            best_d = delay_for_k(width, 1);

            for (k = 2; k <= width; k++) begin
                p = blocks_for_k(width, k);
                d = delay_for_k(width, k);

                if ((d < best_d) ||
                    ((d == best_d) && (p < best_p)) ||
                    ((d == best_d) && (p == best_p) && (k > best_k))) begin
                    best_d = d;
                    best_p = p;
                    best_k = k;
                end
            end

            choose_k = best_k;
        end
    endfunction

    localparam int K          = (BASE_W == 0) ? choose_k(WIDTH) : BASE_W;
    localparam int NUM_BLOCKS = blocks_for_k(WIDTH, K);

    function automatic int ideal_prefix(input int count);
        int s;
        begin
            s = 0;
            for (int i = 0; i < count; i++)
                s += ideal_block_w(i, K);
            ideal_prefix = s;
        end
    endfunction

    // Actual width of block idx, with the last block taking the remainder
    function automatic int actual_block_w(input int idx);
        int used, w;
        begin
            used = ideal_prefix(idx);
            w    = ideal_block_w(idx, K);

            if (used + w <= WIDTH)
                actual_block_w = w;
            else
                actual_block_w = WIDTH - used;
        end
    endfunction

    logic [NUM_BLOCKS:0] csel;
    assign csel[0] = cin;

    for (genvar g = 0; g < NUM_BLOCKS; g++) begin : G_BLK
        localparam int LSB = ideal_prefix(g);
        localparam int WB  = actual_block_w(g);

        if ((g == 0) && !FIRST_BLOCK_SELECT) begin : G_FIRST_RCA
            rca_block #(.W(WB)) u_rca (
                .a   (a[LSB +: WB]),
                .b   (b[LSB +: WB]),
                .cin (csel[0]),
                .sum (sum[LSB +: WB]),
                .cout(csel[g + 1])
            );
        end
        else begin : G_CS
            logic [WB-1:0] s0, s1;
            logic          c0, c1;
            logic          sel;

            assign sel = (g == 0) ? cin : csel[g];

            rca_block #(.W(WB)) u_rca0 (
                .a   (a[LSB +: WB]),
                .b   (b[LSB +: WB]),
                .cin (1'b0),
                .sum (s0),
                .cout(c0)
            );

            rca_block #(.W(WB)) u_rca1 (
                .a   (a[LSB +: WB]),
                .b   (b[LSB +: WB]),
                .cin (1'b1),
                .sum (s1),
                .cout(c1)
            );

            assign sum[LSB +: WB] = sel ? s1 : s0;
            assign csel[g + 1]    = sel ? c1 : c0;
        end
    end

    assign cout = csel[NUM_BLOCKS];
endmodule