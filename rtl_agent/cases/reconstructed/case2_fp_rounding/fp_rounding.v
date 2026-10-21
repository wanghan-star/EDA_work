// Floating-point rounding stage (single precision), behavioral reference.
// mant_in = {hidden(1), frac(23), guard, round, sticky}
module fp_rounding (
    input  [7:0]  exp_in,
    input  [26:0] mant_in,
    input         sign,
    input  [1:0]  rmode,      // 00: RNE, 01: RTZ, 10: RUP(+inf), 11: RDN(-inf)
    output reg [7:0]  exp_out,
    output reg [22:0] mant_out,
    output reg        inexact,
    output reg        overflow
);
    reg        round_up;
    reg [24:0] mant_rnd;
    wire       guard  = mant_in[2];
    wire       rbit   = mant_in[1];
    wire       sticky = mant_in[0];
    wire       lsb    = mant_in[3];

    always @(*) begin
        inexact = guard | rbit | sticky;
        case (rmode)
            2'b00: round_up = guard & (rbit | sticky | lsb);
            2'b01: round_up = 1'b0;
            2'b10: round_up = (~sign) & (guard | rbit | sticky);
            2'b11: round_up = sign & (guard | rbit | sticky);
            default: round_up = 1'b0;
        endcase
        mant_rnd = {1'b0, mant_in[26:3]} + {24'd0, round_up};
        if (mant_rnd[24]) begin
            mant_out = mant_rnd[23:1];
            exp_out  = exp_in + 8'd1;
        end else begin
            mant_out = mant_rnd[22:0];
            exp_out  = exp_in;
        end
        if (exp_out == 8'hFF || (exp_in == 8'hFF)) begin
            overflow = 1'b1;
            exp_out  = 8'hFF;
            mant_out = 23'd0;
        end else begin
            overflow = 1'b0;
        end
    end
endmodule
