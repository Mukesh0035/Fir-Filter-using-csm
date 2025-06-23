`timescale 1ns / 1ps

module fir_tb;

    parameter N = 4;
    parameter SAMPLE_COUNT = 100;

    // Testbench signals
    reg clk;
    reg rst;
    reg data_valid;
    reg signed [15:0] x_in;
    wire signed [31:0] y_out;

    // Instantiate the FIR filter
    fir_csm #(N) dut (
        .clk(clk),
        .rst(rst),
        .data_valid(data_valid),
        .x_in(x_in),
        .y_out(y_out)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Input stimulus storage
    reg signed [15:0] input_data [0:SAMPLE_COUNT-1];

    // File I/O
    integer i;
    integer out_file;

    // Stimulus logic
    initial begin
        // Load input file
        $readmemb("sin.data", input_data);  // Use $readmemh for hex, or use $fscanf for decimal values

        // Initialize
        rst = 1;
        x_in = 0;
        data_valid = 0;
        #20;
        rst = 0;

        // Open output file
        out_file = $fopen("output.data", "w");
        $fwrite(out_file, "Time(ns)\tInput\tOutput\n");

        // Feed samples with data_valid
        for (i = 0; i < SAMPLE_COUNT; i = i + 1) begin
            @(posedge clk);
            x_in <= input_data[i];
            data_valid <= 1;
            @(posedge clk);
            data_valid <= 0;
        end

        // Wait for pipeline to flush
        repeat (10) @(posedge clk);

        $fclose(out_file);
        $finish;
    end

    // Output monitoring
    always @(posedge clk) begin
        if (!rst)
            $fwrite(out_file, "%0dns\t%d\t%d\n", $time, x_in, y_out);
    end

    initial begin
        $display("Running FIR Filter Testbench...");
        $monitor("Time: %0dns, x_in: %d, y_out: %d", $time, x_in, y_out);
    end

endmodule
