module TopModule(input clk, input rst,
                 input [7:0] x0, x1, x2, x3, x4, x5, x6, x7,
                 input [7:0] c0, c1, c2, c3, c4, c5, c6, c7,
                 input start, output reg done, output reg [17:0] y);
  reg [1:0] i;
  reg [17:0] acc;

  reg [7:0] xa, xb, ca, cb;
  always @(*) begin
    case (i)
      2'd0: begin xa = x0; xb = x1; ca = c0; cb = c1; end
      2'd1: begin xa = x2; xb = x3; ca = c2; cb = c3; end
      2'd2: begin xa = x4; xb = x5; ca = c4; cb = c5; end
      default: begin xa = x6; xb = x7; ca = c6; cb = c7; end
    endcase
  end

  wire [15:0] pa = xa * ca;
  wire [15:0] pb = xb * cb;
  wire [16:0] psum = {1'b0, pa} + {1'b0, pb};
  wire [17:0] nacc = acc + {1'b0, psum};

  always @(posedge clk or posedge rst) begin
    if (rst) begin i <= 0; acc <= 0; done <= 0; end
    else if (start) begin i <= 0; acc <= 0; done <= 0; end
    else if (!done) begin
      if (i == 2'd3) begin
        acc <= nacc;
        done <= 1;
        y <= nacc;
      end else begin
        acc <= nacc;
      end
      i <= i + 1;
    end
  end
endmodule
