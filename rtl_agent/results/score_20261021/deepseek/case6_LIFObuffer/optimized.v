module LIFObuffer (
    input [3:0] dataIn,
    input RW,
    input EN,
    input Rst,
    input clk,
    output reg EMPTY,
    output reg FULL,
    output reg [3:0] dataOut
);

    reg [3:0] m0, m1, m2, m3;
    reg [2:0] SP;

    wire push = (EN == 1'b1) && (Rst == 1'b0) && (SP != 3'd0) && (RW == 1'b0);
    wire pop  = (EN == 1'b1) && (Rst == 1'b0) && (SP != 3'd4) && (RW == 1'b1);

    wire [2:0] SP_dec = SP - 3'd1;
    wire [2:0] SP_inc = SP + 3'd1;

    wire [3:0] sel = (SP == 3'd0) ? m0 :
                     (SP == 3'd1) ? m1 :
                     (SP == 3'd2) ? m2 : m3;

    wire [2:0] SP_next = push ? SP_dec : (pop ? SP_inc : SP);

    always @ (posedge clk) begin
        if (EN == 0) begin
            // Do nothing if EN is 0
        end else begin
            if (Rst == 1) begin
                SP = 3'd4;
                EMPTY = SP[2];
                dataOut = 4'h0;
                m0 = 0; m1 = 0; m2 = 0; m3 = 0;
            end else if (Rst == 0) begin
                FULL = SP ? 0 : 1;
                EMPTY = SP[2];
                dataOut = 4'hx;

                if (FULL == 1'b0 && RW == 1'b0) begin
                    SP = SP - 1'b1;
                    FULL = SP ? 0 : 1;
                    EMPTY = SP[2];
                    case (SP)
                        3'd0: m0 = dataIn;
                        3'd1: m1 = dataIn;
                        3'd2: m2 = dataIn;
                        3'd3: m3 = dataIn;
                        default: ;
                    endcase
                end else if (EMPTY == 1'b0 && RW == 1'b1) begin
                    dataOut = sel;
                    case (SP)
                        3'd0: m0 = 0;
                        3'd1: m1 = 0;
                        3'd2: m2 = 0;
                        3'd3: m3 = 0;
                        default: ;
                    endcase
                    SP = SP + 1;
                    FULL = SP ? 0 : 1;
                    EMPTY = SP[2];
                end else begin
                    // Do nothing if neither condition is met
                end
            end else begin
                // Do nothing if neither condition is met
            end
        end
    end
endmodule
