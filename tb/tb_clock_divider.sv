// ============================================================
// GreenChip Clock Divider Testbench
// File: tb_clock_divider.sv
// Author: A'Yana Leonard
//
// Purpose:
// Verifies reset behavior, divided clock operation, and
// single-cycle tick generation.
// ============================================================

`timescale 1ns/1ps

module tb_clock_divider;

    // Use a small divisor so simulation finishes quickly.
    localparam integer DIVISOR = 10;

    logic clk_i;
    logic rst_i;

    logic clk_div_o;
    logic tick_o;

    integer tick_count;
    integer error_count;

    // --------------------------------------------------------
    // Device Under Test
    // --------------------------------------------------------

    clock_divider #(
        .DIVISOR(DIVISOR)
    ) dut (
        .clk_i     (clk_i),
        .rst_i     (rst_i),
        .clk_div_o (clk_div_o),
        .tick_o    (tick_o)
    );

    // --------------------------------------------------------
    // Generate a 100 MHz clock
    //
    // 10 ns total period:
    // 5 ns low + 5 ns high
    // --------------------------------------------------------

    initial begin
        clk_i = 1'b0;

        forever begin
            #5 clk_i = ~clk_i;
        end
    end

    // --------------------------------------------------------
    // Count tick pulses
    // --------------------------------------------------------

    always @(posedge clk_i) begin
        if (rst_i) begin
            tick_count = 0;
        end
        else if (tick_o) begin
            tick_count = tick_count + 1;
        end
    end

    // --------------------------------------------------------
    // Main Test Sequence
    // --------------------------------------------------------

    initial begin
        rst_i       = 1'b1;
        tick_count  = 0;
        error_count = 0;

        // Create waveform output.
        $dumpfile("sim/waveforms/tb_clock_divider.vcd");
        $dumpvars(0, tb_clock_divider);

        $display("========================================");
        $display("GreenChip Clock Divider Testbench");
        $display("========================================");

        // Hold reset for several clock cycles.
        repeat (3) @(posedge clk_i);

        rst_i = 1'b0;

        @(posedge clk_i);

        // Check reset values.
        if (clk_div_o !== 1'b0) begin
            $display("FAIL: clk_div_o did not reset to 0.");
            error_count = error_count + 1;
        end
        else begin
            $display("PASS: clk_div_o reset correctly.");
        end

        if (tick_o !== 1'b0) begin
            $display("FAIL: tick_o did not reset to 0.");
            error_count = error_count + 1;
        end
        else begin
            $display("PASS: tick_o reset correctly.");
        end

        // Run long enough to observe multiple output toggles.
        repeat (40) @(posedge clk_i);

        if (tick_count == 8) begin
            $display(
                "PASS: Correct tick count detected: %0d",
                tick_count
            );
        end
        else begin
            $display(
                "FAIL: Expected 8 ticks but detected %0d.",
                tick_count
            );

            error_count = error_count + 1;
        end

        // ----------------------------------------------------
        // Final Result
        // ----------------------------------------------------

        if (error_count == 0) begin
            $display("========================================");
            $display("ALL CLOCK DIVIDER TESTS PASSED");
            $display("========================================");
        end
        else begin
            $display("========================================");
            $display(
                "CLOCK DIVIDER TEST FAILED WITH %0d ERROR(S)",
                error_count
            );
            $display("========================================");
        end

        $finish;
    end

endmodule