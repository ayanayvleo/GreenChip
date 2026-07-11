// ============================================================
// GreenChip Power Controller Testbench
// File: tb_power_controller.sv
// Author: A'Yana Leonard
//
// Purpose:
// Verifies the Power Controller correctly decodes all GreenChip
// operating states.
// ============================================================

`timescale 1ns/1ps

module tb_power_controller;

    logic clk_i;
    logic rst_i;

    logic [1:0] state_i;

    logic low_power_o;
    logic normal_power_o;
    logic boost_o;
    logic protect_o;
    logic clock_enable_o;

    integer error_count;

    localparam logic [1:0] STATE_ECO     = 2'b00;
    localparam logic [1:0] STATE_NORMAL  = 2'b01;
    localparam logic [1:0] STATE_BOOST   = 2'b10;
    localparam logic [1:0] STATE_PROTECT = 2'b11;

    // --------------------------------------------------------
    // Device Under Test
    // --------------------------------------------------------

    power_controller dut (

        .clk_i(clk_i),
        .rst_i(rst_i),

        .state_i(state_i),

        .low_power_o(low_power_o),
        .normal_power_o(normal_power_o),
        .boost_o(boost_o),
        .protect_o(protect_o),
        .clock_enable_o(clock_enable_o)

    );

    // --------------------------------------------------------
    // Generate Clock
    // --------------------------------------------------------

    initial begin

        clk_i = 1'b0;

        forever begin
            #5 clk_i = ~clk_i;
        end

    end

    // --------------------------------------------------------
    // Verify State Outputs
    // --------------------------------------------------------

    task automatic verify_state(

        input logic [1:0] state,
        input logic expected_low,
        input logic expected_normal,
        input logic expected_boost,
        input logic expected_protect,
        input logic expected_clock_enable

    );

    begin

        state_i = state;

        @(posedge clk_i);

        #1;

        if (low_power_o !== expected_low) begin
            $display("FAIL: low_power_o incorrect.");
            error_count++;
        end

        if (normal_power_o !== expected_normal) begin
            $display("FAIL: normal_power_o incorrect.");
            error_count++;
        end

        if (boost_o !== expected_boost) begin
            $display("FAIL: boost_o incorrect.");
            error_count++;
        end

        if (protect_o !== expected_protect) begin
            $display("FAIL: protect_o incorrect.");
            error_count++;
        end

        if (clock_enable_o !== expected_clock_enable) begin
            $display("FAIL: clock_enable_o incorrect.");
            error_count++;
        end

    end

    endtask

    // --------------------------------------------------------
    // Main Test
    // --------------------------------------------------------

    initial begin

        rst_i       = 1'b1;
        state_i     = STATE_NORMAL;
        error_count = 0;

        $dumpfile("sim/waveforms/tb_power_controller.vcd");
        $dumpvars(0, tb_power_controller);

        $display("");
        $display("========================================");
        $display("GreenChip Power Controller Testbench");
        $display("========================================");

        repeat (3) @(posedge clk_i);

        rst_i = 1'b0;

        // ECO
        verify_state(
            STATE_ECO,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            1'b1
        );

        // NORMAL
        verify_state(
            STATE_NORMAL,
            1'b0,
            1'b1,
            1'b0,
            1'b0,
            1'b1
        );

        // BOOST
        verify_state(
            STATE_BOOST,
            1'b0,
            1'b0,
            1'b1,
            1'b0,
            1'b1
        );

        // PROTECT
        verify_state(
            STATE_PROTECT,
            1'b0,
            1'b0,
            1'b0,
            1'b1,
            1'b0
        );

        // ----------------------------------------------------
        // Final Report
        // ----------------------------------------------------

        if (error_count == 0) begin

            $display("");
            $display("========================================");
            $display("ALL POWER CONTROLLER TESTS PASSED");
            $display("========================================");

        end
        else begin

            $display("");
            $display("========================================");
            $display("POWER CONTROLLER TEST FAILED");
            $display("Errors: %0d", error_count);
            $display("========================================");

        end

        $finish;

    end

endmodule