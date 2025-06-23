`timescale 1ns /1ps

module fir_serial_wrapper #(
    parameter N = 4
)(
    input wire clk,
    input wire rst,
    input wire serial_in,
    output reg serial_out,
    output reg data_valid
);

    reg [15:0] input_shift_reg = 0;
    reg [4:0] input_bit_count = 0;

    reg [31:0] output_shift_reg = 0;
    reg [5:0] output_bit_count = 0;

    reg load_sample = 0;
    reg signed [15:0] parallel_input = 0;
    wire signed [31:0] parallel_output;

    fir_csm #(N) fir_inst (
        .clk(clk),
        .rst(rst),
        .data_valid(load_sample),
        .x_in(parallel_input),
        .y_out(parallel_output)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            input_shift_reg <= 0;
            input_bit_count <= 0;
            load_sample <= 0;
            parallel_input <= 0;
        end else begin
            load_sample <= 0;
            input_shift_reg <= {input_shift_reg[14:0], serial_in};
            input_bit_count <= input_bit_count + 1;

            if (input_bit_count == 15) begin
                parallel_input <= {input_shift_reg[14:0], serial_in};
                load_sample <= 1;
                input_bit_count <= 0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            output_shift_reg <= 0;
            output_bit_count <= 0;
            serial_out <= 0;
            data_valid <= 0;
        end else begin
            data_valid <= 0;
            if (load_sample) begin
                output_shift_reg <= parallel_output;
                output_bit_count <= 0;
                data_valid <= 1;
            end else if (output_bit_count < 32) begin
                serial_out <= output_shift_reg[31];
                output_shift_reg <= {output_shift_reg[30:0], 1'b0};
                output_bit_count <= output_bit_count + 1;
            end else begin
                serial_out <= 0;
            end
        end
    end

endmodule
