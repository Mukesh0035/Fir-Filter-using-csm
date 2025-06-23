`timescale 1ns /1ps

module fir_csm #(
    parameter N = 4
)(
    input wire clk,
    input wire rst,
    input wire data_valid,
    input wire signed [15:0] x_in,
    output reg signed [31:0] y_out
);

//    wire signed [16:0] COEFFS[0:N-1];
//    assign COEFFS[0] = 17'b0_0100000000000000;
//    assign COEFFS[1] = 17'b0_0100000000000000;
//    assign COEFFS[2] = 17'b0_0100000000000000;
//    assign COEFFS[3] = 17'b0_0100000000000000;

     function automatic signed [16:0] get_coeff(input integer index);
    case (index)
        0: get_coeff = 17'b0_0100000000000000;
        1: get_coeff = 17'b0_0100000000000000;
        2: get_coeff = 17'b0_0100000000000000;
        3: get_coeff = 17'b0_0100000000000000;
        default: get_coeff = 17'sd0;
    endcase
endfunction


    reg signed [15:0] shift_reg[0:N-1];

 wire signed [15:0] gated_input [N-1:0];
generate
    for (genvar i = 0; i < N; i=i+1) begin : input_gate
        assign gated_input[i] = data_valid ? shift_reg[i] : 16'sd0;
    end
endgenerate

wire signed [31:0] tap_outputs [N-1:0];
generate
    for (genvar i = 0; i < N; i=i+1) begin : taps
    csm tap_inst (
        .clk(clk),
        .rst(rst),
        .x_in(gated_input[i]),
        .coeff(get_coeff(i)),
        .y_out(tap_outputs[i])
    );
end

endgenerate




    integer j;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (j = 0; j < N; j = j + 1)
                shift_reg[j] <= 0;
        end else if (data_valid) begin
            shift_reg[0] <= x_in;
            for (j = 1; j < N; j = j + 1)
                shift_reg[j] <= shift_reg[j-1];
        end
    end

    reg [2:0] valid_pipe = 0;
    always @(posedge clk or posedge rst)
        if (rst) valid_pipe <= 0;
        else valid_pipe <= {valid_pipe[1:0], data_valid};

    integer k;
    reg signed [31:0] sum;
    always @(posedge clk or posedge rst) begin
        if (rst)
            y_out <= 0;
        else if (valid_pipe[2]) begin
            sum = 0;
            for (k = 0; k < N; k = k + 1)
                sum = sum + tap_outputs[k];
            y_out <= sum;
        end
    end

endmodule
