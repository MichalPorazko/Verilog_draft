module wish_bone_slave(


input wire RST_I,
input wire CLK_I,
input wire [7:0] DAT_I,
input wire STB_I,
input wire WE_I,


output wire ACK_O,
output wire [7:0] DAT_O,
output wire [7:0] PRT_O

);

wire internal_DAT_I;
assign [7:0] internal_DAT_I = DAT_I; 

reg [7:0] Q;

always @(posedge CLK_I) begin
    if (RST_I) begin
        Q <= 8'b00000000
    `else if (STB_I && WE_I ) begin
        Q <= internal_DAT_I;
     else 
        Q <= Q;
    end   
    end   


end

assign DAT_O = Q;
assign PRT_O = Q;
assign ACK_O = STB_I;