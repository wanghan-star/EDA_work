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

    always @ (posedge clk) begin
        if (EN == 0) begin
            // Do nothing if EN is 0
        end else begin
            if (Rst == 1) begin
                SP = 3'd4;
                EMPTY = SP[2];
                dataOut = 4'h0;
                m0 = 0;
                m1 = 0;
                m2 = 0;
                m3 = 0;
            end else if (Rst == 0) begin
                FULL = SP ? 0 : 1;
                EMPTY = SP[2];
                dataOut = 4'hx;
                
                if (FULL == 1'b0 && RW == 1'b0) begin
                    SP = SP - 1'b1;
                    FULL = SP ? 0 : 1;
                    EMPTY = SP[2];
                    case (SP[1:0])
                        2'd0: if (SP != 3'd4) m0 = dataIn;
                        2'd1: m1 = dataIn;
                        2'd2: m2 = dataIn;
                        2'd3: m3 = dataIn;
                    endcase
                end else if (EMPTY == 1'b0 && RW == 1'b1) begin
                    case (SP[1:0])
                        2'd0: dataOut = m0;
                        2'd1: dataOut = m1;
                        2'd2: dataOut = m2;
                        2'd3: dataOut = m3;
                    endcase
                    case (SP[1:0])
                        2'd0: m0 = 0;
                        2'd1: m1 = 0;
                        2'd2: m2 = 0;
                        2'd3: m3 = 0;
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
