`timescale 1ns / 1ps

module csm (
    input wire clk,
    input wire rst,
    input wire signed [15:0] x_in,
    input wire signed [16:0] coeff,
    output reg signed [31:0] y_out
);

    wire [15:0] abs_coeff = coeff[15:0];
    wire sign = coeff[16];

    wire signed [16:0] x = x_in;
    wire signed [16:0] x_s1 = x >>> 1;
    wire signed [16:0] x_s2 = x >>> 2;

    wire signed [16:0] bcs[0:7];
    assign bcs[0] = 0;
    assign bcs[1] = x_s2;
    assign bcs[2] = x_s1;
    assign bcs[3] = x_s1 + x_s2;
    assign bcs[4] = x;
    assign bcs[5] = x + x_s2;
    assign bcs[6] = x + x_s1;
    assign bcs[7] = x + x_s1 + x_s2;

    wire [2:0] sel[0:4];
    assign sel[0] = abs_coeff[15:13];
    assign sel[1] = abs_coeff[12:10];
    assign sel[2] = abs_coeff[9:7];
    assign sel[3] = abs_coeff[6:4];
    assign sel[4] = abs_coeff[3:1];
    wire sel6 = abs_coeff[0];

    reg signed [16:0] r[0:5];
    reg sign_s1;

    // Stage 1: select BCS
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r[0] <= 0; r[1] <= 0; r[2] <= 0;
            r[3] <= 0; r[4] <= 0; r[5] <= 0;
            sign_s1 <= 0;
        end else begin
            r[0] <= bcs[sel[0]];
            r[1] <= bcs[sel[1]];
            r[2] <= bcs[sel[2]];
            r[3] <= bcs[sel[3]];
            r[4] <= bcs[sel[4]];
            r[5] <= sel6 ? bcs[4] : 0;
            sign_s1 <= sign;
        end
    end

    reg signed [31:0] sr[0:5];
    reg sign_s2;

    // Stage 2: shift
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sr[0] <= 0; sr[1] <= 0; sr[2] <= 0;
            sr[3] <= 0; sr[4] <= 0; sr[5] <= 0;
            sign_s2 <= 0;
        end else begin
            sr[0] <= r[0] >>> 1;
            sr[1] <= r[1] >>> 4;
            sr[2] <= r[2] >>> 7;
            sr[3] <= r[3] >>> 10;
            sr[4] <= r[4] >>> 13;
            sr[5] <= r[5] >>> 16;
            sign_s2 <= sign_s1;
        end
    end

    wire signed [31:0] sum = sr[0] + sr[1] + sr[2] + sr[3] + sr[4] + sr[5];

    // Stage 3: apply sign
    always @(posedge clk or posedge rst) begin
        if (rst)
            y_out <= 0;
        else
            y_out <= sign_s2 ? -sum : sum;
    end

endmodule
