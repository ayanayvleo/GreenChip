// ============================================================
// GreenChip Top-Level Testbench
// File: tb_greenchip_top.sv
// Author: A'Yana Leonard
//
// Purpose:
// Performs basic integration testing of the complete GreenChip
// system.
// ============================================================

`timescale 1ns/1ps

module tb_greenchip_top;

    logic clk_i;
    logic rst_i;

    logic activity_event_i;
    logic wake_event_i;

    logic [7:0] temperature_sample_i;
    logic temperature_valid_i;

    logic uart_rx_i;
    logic uart_tx_o;

    logic spi_miso_i;
    logic spi_mosi_o;
    logic spi_clk_o;
    logic spi_cs_n_o;

    logic fan_pwm_o;

    logic [3:0] led_o;

    logic [1:0] power_state_o;

    logic low_power_o;
    logic boost_o;
    logic protect_o;
    logic fault_o;

    integer error_count;

    // --------------------------------------------------------
    // Device Under Test
    // --------------------------------------------------------

    greenchip_top dut (

        .clk_i(clk_i),
        .rst_i(rst_i),

        .activity_event_i(activity_event_i),
        .wake_event_i(wake_event_i),

        .temperature_sample_i(temperature_sample_i),
        .temperature_valid_i(temperature_valid_i),

        .uart_rx_i(uart_rx_i),
        .uart_tx_o(uart_tx_o),

        .spi_miso_i(spi_miso_i),
        .spi_mosi_o(spi_mosi_o),
        .spi_clk_o(spi_clk_o),
        .spi_cs_n_o(spi_cs_n_o),

        .fan_pwm_o(fan_pwm_o),

        .led_o(led_o),

        .power_state_o(power_state_o),

        .low_power_o(low_power_o),
        .boost_o(boost_o),
        .protect_o(protect_o),
        .fault_o(fault_o)

    );

    // --------------------------------------------------------
    // Generate 100 MHz Clock
    // --------------------------------------------------------

    initial begin

        clk_i = 1'b0;

        forever begin
            #5 clk_i = ~clk_i;
        end

    end

    // --------------------------------------------------------
    // Main Test Sequence
    // --------------------------------------------------------

    initial begin

        rst_i = 1'b1;

        activity_event_i = 1'b0;
        wake_event_i = 1'b0;

        temperature_sample_i = 8'd25;
        temperature_valid_i = 1'b0;

        uart_rx_i = 1'b1;

        spi_miso_i = 1'b0;

        error_count = 0;

        $dumpfile("sim/waveforms/tb_greenchip_top.vcd");
        $dumpvars(0, tb_greenchip_top);

        $display("");
        $display("========================================");
        $display("GreenChip Integration Test");
        $display("========================================");

        repeat (5) @(posedge clk_i);

        rst_i = 1'b0;

        //-----------------------------------------------------
        // Normal Temperature
        //-----------------------------------------------------

        temperature_sample_i = 8'd30;
        temperature_valid_i = 1'b1;

        @(posedge clk_i);

        temperature_valid_i = 1'b0;

        repeat (20) @(posedge clk_i);

        //-----------------------------------------------------
        // Simulate Activity
        //-----------------------------------------------------

        repeat (15) begin

            activity_event_i = 1'b1;

            @(posedge clk_i);

            activity_event_i = 1'b0;

            @(posedge clk_i);

        end

        //-----------------------------------------------------
        // High Temperature
        //-----------------------------------------------------

        temperature_sample_i = 8'd90;
        temperature_valid_i = 1'b1;

        @(posedge clk_i);

        temperature_valid_i = 1'b0;

        repeat (30) @(posedge clk_i);

        //-----------------------------------------------------
        // Wake Event
        //-----------------------------------------------------

        wake_event_i = 1'b1;

        @(posedge clk_i);

        wake_event_i = 1'b0;

        repeat (20) @(posedge clk_i);

        //-----------------------------------------------------
        // Basic Checks
        //-----------------------------------------------------

        if (fan_pwm_o !== 1'b0 &&
            fan_pwm_o !== 1'b1) begin

            $display("FAIL: Invalid PWM output.");
            error_count++;

        end

        if (led_o === 4'bxxxx) begin

            $display("FAIL: LED output unknown.");
            error_count++;

        end

        if (power_state_o === 2'bxx) begin

            $display("FAIL: Invalid state output.");
            error_count++;

        end

        //-----------------------------------------------------
        // Final Report
        //-----------------------------------------------------

        if (error_count == 0) begin

            $display("");
            $display("========================================");
            $display("GREENCHIP INTEGRATION PASSED");
            $display("========================================");

        end
        else begin

            $display("");
            $display("========================================");
            $display("GREENCHIP INTEGRATION FAILED");
            $display("Errors: %0d", error_count);
            $display("========================================");

        end

        $finish;

    end

endmodule