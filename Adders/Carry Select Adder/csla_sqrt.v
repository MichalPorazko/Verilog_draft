module csla_sqrt #(
    parameter WIDTH, //= 16,
    parameter FIRST_BLOCK_SELECT = 1'b0,
    parameter BASE_W   // 0 = choose K automatically
) (
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    input  cin,
    output [WIDTH-1:0] sum,
    output cout
);

    // Ideal width of block idx before the last "remainder" adjustment
    function automatic integer  ideal_block_w(input integer idx, input integer k);
        begin
            if (FIRST_BLOCK_SELECT)
                ideal_block_w = k + idx;              // K, K+1, K+2, ...
                $display("ideal_block_w, FIRST_BLOCK_SELECT, idx: %d , k: %d, ideal_block_w = k + idx = %d", idx, k, ideal_block_w);
            else if (idx == 0)
                ideal_block_w = k;                    // K
                $display("ideal_block_w, idx == 0, idx: %d , k: %d, ideal_block_w = k", idx, k);
            else
                ideal_block_w = k + idx - 1;          // K, K+1, K+2, ...
                $display("ideal_block_w, else, idx: %d , k: %d, ideal_block_w = k + idx - 1 = %d", idx, k, ideal_block_w);
        end
    endfunction

    // Number of blocks needed to cover WIDTH bits
    function automatic integer  blocks_for_k(input integer  width, input integer  k);
        integer  s, p;
        begin
            s = 0;
            p = 0;
            $display("blocks_for_k, start: width: %d, k: %d", width, k);
            while (s < width) begin
                s += ideal_block_w(p, k);
                $display("blocks_for_k, loop: p: %d, s: %d, ideal_block_w(p, k): %d", p, s, ideal_block_w(p, k));
                p++;
            end
            blocks_for_k = p;
            $display("blocks_for_k, end: p: %d", p);
        end
    endfunction

    // Simple delay metric under tmux = tcarry
    function automatic integer  delay_for_k(input integer  width, input integer  k);
        integer  p;
        begin
            p = blocks_for_k(width, k);
            $display("delay_for_k, blocks_for_k(width, k): %d", p);
            if (FIRST_BLOCK_SELECT)
                delay_for_k = k + p;      // first block has RCA + mux
            else
                delay_for_k = k + p - 1;  // first block is plain RCA
            $display("delay_for_k, result: %d", delay_for_k);
        end
    endfunction

    // Choose K automatically
    function automatic integer  choose_k(input int width);
        integer  k, p, d;
        integer  best_k, best_p, best_d;
        begin
            best_k = 1;
            best_p = blocks_for_k(width, 1);
            best_d = delay_for_k(width, 1);
            $display("choose_k, initial: best_k: %d, best_p: %d, best_d: %d", best_k, best_p, best_d);

            for (k = 2; k <= width; k++) begin
                p = blocks_for_k(width, k);
                d = delay_for_k(width, k);
                $display("choose_k, loop: k: %d, p: %d, d: %d", k, p, d);

                if ((d < best_d) ||
                    ((d == best_d) && (p < best_p)) ||
                    ((d == best_d) && (p == best_p) && (k > best_k))) begin
                    best_d = d;
                    best_p = p;
                    best_k = k;
                    $display("choose_k, update: best_k: %d, best_p: %d, best_d: %d", best_k, best_p, best_d);
                end
            end

            choose_k = best_k;
            $display("choose_k, final: best_k: %d", best_k);
        end
    endfunction

    localparam integer  K          = (BASE_W == 0) ? choose_k(WIDTH) : BASE_W;
    localparam integer  NUM_BLOCKS = blocks_for_k(WIDTH, K);
    $display("Module params: WIDTH: %d, K: %d, NUM_BLOCKS: %d", WIDTH, K, NUM_BLOCKS);

    function automatic integer  ideal_prefix(input integer  count);
        integer  s;
        begin
            s = 0;
            for (integer  i = 0; i < count; i++)
                s += ideal_block_w(i, K);
            ideal_prefix = s;
            $display("ideal_prefix, count: %d, result: %d", count, ideal_prefix);
        end
    endfunction

    // Actual width of block idx, with the last block taking the remainder
    function automatic integer  actual_block_w(input integer  idx);
        integer  used, w;
        begin
            used = ideal_prefix(idx);
            w    = ideal_block_w(idx, K);
            $display("actual_block_w, idx: %d, used: %d, w: %d", idx, used, w);

            if (used + w <= WIDTH)
                actual_block_w = w;
            else
                actual_block_w = WIDTH - used;
            $display("actual_block_w, result: %d", actual_block_w);
        end
    endfunction

    logic [NUM_BLOCKS:0] csel;
    assign csel[0] = cin;
    $display("csel[0] assigned to cin: %b", cin);

    for (genvar g = 0; g < NUM_BLOCKS; g++) begin : G_BLK
        localparam integer  LSB = ideal_prefix(g);
        localparam integer  WB  = actual_block_w(g);
        $display("G_BLK, g: %d, LSB: %d, WB: %d", g, LSB, WB);

        if ((g == 0) && !FIRST_BLOCK_SELECT) begin : G_FIRST_RCA
            $display("G_FIRST_RCA, g: %d", g);
            rca_block #(.W(WB)) u_rca (
                .a   (a[LSB +: WB]),
                .b   (b[LSB +: WB]),
                .cin (csel[0]),
                .sum (sum[LSB +: WB]),
                .cout(csel[g + 1])
            );
        end
        else begin : G_CS
            $display("G_CS, g: %d", g);
            logic [WB-1:0] s0, s1;
            logic          c0, c1;
            logic          sel;

            assign sel = (g == 0) ? cin : csel[g];
            $display("G_CS, sel assigned: %b", sel);

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
            $display("G_CS, sum[LSB +: WB] assigned, csel[%d] assigned", g + 1);
        end
    end

    assign cout = csel[NUM_BLOCKS];
    $display("cout assigned to csel[NUM_BLOCKS]: %b", csel[NUM_BLOCKS]);
endmodule