module TopModule(input clk, input rst, input start,
                 input [7:0] x0,x1,x2,x3,x4,x5,x6,x7,
                 input [7:0] c0,c1,c2,c3,c4,c5,c6,c7,
                 output reg done, output reg [17:0] y);
  reg i;
  reg [17:0] acc;
  wire [17:0] p0 = x0*c0;
  wire [17:0] p1 = x1*c1;
  wire [17:0] p2 = x2*c2;
  wire [17:0] p3 = x3*c3;
  wire [17:0] p4 = x4*c4;
  wire [17:0] p5 = x5*c5;
  wire [17:0] p6 = x6*c6;
  wire [17:0] p7 = x7*c7;
  wire [17:0] lo = p0 + p1 + p2 + p3;
  wire [17:0] hi = p4 + p5 + p6 + p7;
  wire [17:0] sum_lo = acc + lo;
  wire [17:0] sum_hi = acc + hi;
  always @(posedge clk or posedge rst) begin
    if (rst) begin i <= 0; acc <= 0; done <= 0; end
    else if (start) begin i <= 0; acc <= 0; done <= 0; end
    else if (!done) begin
      if (!i) acc <= sum_lo;
      else begin acc <= sum_hi; done <= 1; y <= sum_hi; end
      i <= i + 1;
    end
  end
endmodule
