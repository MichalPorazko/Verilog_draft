module full_adder_hardcoded ( 
    input a, 
    input b, 
    input c_in, 
    output sum, 
    output c_out 
);

    assign sum = a ^ b ^ c_in;
    assign c_out = (a & b) | (c_in & (a ^ b));

endmodule


module fulladder(A, B, Ci, S, Co);
  input A, B, Ci;
  output S, Co;
  wire w1,w2,w3;
  //Structural code for one bit full adder
  xor G1(w1, A, B);
  xor G2(S, w1, Ci);
  and G3(w2, w1, Ci);
  and G4(w3, A, B);
  or G5(Co, w2, w3);
endmodule

module full_add(a,b,cin,sum,cout);
  input a,b,cin;
  output sum,cout;
  wire x,y,z;
 
// instantiate building blocks of full adder 
  half_add h1(.a(a),.b(b),.s(x),.c(y));
  half_add h2(.a(x),.b(cin),.s(sum),.c(z));
  or o1(cout,y,z);
endmodule : full_add

// code your half adder design             
module half_add(a,b,s,c); 
  input a,b;
  output s,c;
 
// gate level design of half adder  
  xor x1(s,a,b);
  and a1(c,a,b);
endmodule :half_add


function automatic [BIT_WIDTH:0] add_fn (
    input logic [BIT_WIDTH-1:0] a,
    input logic [BIT_WIDTH-1:0] b,
    input logic                 cin
);
    add_fn = a + b + cin;
endfunction

/*
logic [BIT_WIDTH:0] tmp;
assign tmp  = add_fn(a, b, cin);
assign sum  = tmp[BIT_WIDTH-1:0];
assign cout = tmp[BIT_WIDTH];
*/

module full_adder (
    input  logic a,
    input  logic b,
    input  logic cin,
    output logic sum,
    output logic cout
);
    assign {cout, sum} = a + b + cin;
endmodule


