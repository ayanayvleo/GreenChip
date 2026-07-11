// ============================================================
// GreenChip UART Testbench
// File: tb_uart.sv
// Author: A'Yana Leonard
//
// Purpose:
// Verifies UART transmission and reception using a loopback
// connection between uart_tx and uart_rx.
// ============================================================

`timescale 1ns/1ps

module tb_uart;

    // Smaller values make simulation faster.
    localparam integer CLK_FREQ_HZ  = 1_000_000;
    localparam integer BAUD_RATE    = 100_000;
    localparam integer CLKS_PER_BIT = CLK_FREQ_HZ / BAUD_RATE;

    logic clk_i;
    logic rst_i;

    logic [7:0] tx_data_i;
    logic       tx_start_i;
    logic       uart_line;

    logic       tx_busy_o;
    logic       tx_done_o;

    logic [7:0] rx_data_o;
    logic       rx_valid_o;
    logic       framing_error_o;

    integer error_count;

    // --------------------------------------------------------
    // UART Transmitter
    // --------------------------------------------------------

    uart_tx #(
        .CLK_FREQ_HZ (CLK_FREQ_HZ),
        .BAUD_RATE   (BAUD_RATE)
    ) uart_tx_dut (
        .clk_i   (clk_i),
        .rst_i   (rst_i),
        .data_i  (tx_data_i),
        .start_i (tx_start_i),
        .tx_o    (uart_line),
        .busy_o  (tx_busy_o),
        .done_o  (tx_done_o)
    );

    // --------------------------------------------------------
    // UART Receiver
    //
    // The transmitter output is connected directly to the
    // receiver input to create a loopback connection.
    // --------------------------------------------------------

    uart_rx #(
        .CLK_FREQ_HZ (CLK_FREQ_HZ),
        .BAUD_RATE   (BAUD_RATE)
    ) uart_rx_dut (
        .clk_i           (clk_i),
        .rst_i           (rst_i),
        .rx_i            (uart_line),
        .data_o          (rx_data_o),
        .valid_o         (rx_valid_o),
        .framing_error_o (framing_error_o)
    );

    // --------------------------------------------------------
    // Generate a 1 MHz Clock
    //
    // Period = 1000 ns
    // --------------------------------------------------------

    initial begin
        clk_i = 1'b0;

        forever begin
            #500 clk_i = ~clk_i;
        end
    end

    // --------------------------------------------------------
    // UART Send-and-Check Task
    // --------------------------------------------------------

    task automatic send_and_check(
        input logic [7:0] test_byte
    );

        integer timeout_count;

        begin
            // Make sure the previous receive-valid pulse ended.
            while (rx_valid_o) begin
                @(posedge clk_i);
            end

            // Wait until the transmitter is idle.
            while (tx_busy_o) begin
                @(posedge clk_i);
            end

            // Apply data and start away from the active edge.
            @(negedge clk_i);

            tx_data_i  = test_byte;
            tx_start_i = 1'b1;

            // Hold start across one rising edge.
            @(negedge clk_i);

            tx_start_i = 1'b0;

            timeout_count = 0;

            // Wait for a fresh receive-valid pulse.
            while (!rx_valid_o &&
                   timeout_count < (CLKS_PER_BIT * 20)) begin

                @(posedge clk_i);
                timeout_count = timeout_count + 1;
            end

            if (timeout_count >= (CLKS_PER_BIT * 20)) begin
                $display(
                    "FAIL: UART timeout while receiving 0x%02h.",
                    test_byte
                );

                error_count = error_count + 1;
            end
            else begin
                // Allow registered outputs to settle.
                #1;

                if (framing_error_o) begin
                    $display(
                        "FAIL: Framing error while receiving 0x%02h.",
                        test_byte
                    );

                    error_count = error_count + 1;
                end
                else if (rx_data_o !== test_byte) begin
                    $display(
                        "FAIL: Sent 0x%02h, received 0x%02h.",
                        test_byte,
                        rx_data_o
                    );

                    error_count = error_count + 1;
                end
                else begin
                    $display(
                        "PASS: Sent and received 0x%02h.",
                        test_byte
                    );
                end
            end

            // Wait for receive-valid to clear before next test.
            while (rx_valid_o) begin
                @(posedge clk_i);
            end

            repeat (2) @(posedge clk_i);
        end

    endtask

    // --------------------------------------------------------
    // Main Test Sequence
    // --------------------------------------------------------

    initial begin
        rst_i       = 1'b1;
        tx_data_i   = 8'h00;
        tx_start_i  = 1'b0;
        error_count = 0;

        $dumpfile("sim/waveforms/tb_uart.vcd");
        $dumpvars(0, tb_uart);

        $display("========================================");
        $display("GreenChip UART Testbench");
        $display("========================================");

        // Hold reset.
        repeat (4) @(posedge clk_i);

        rst_i = 1'b0;

        repeat (2) @(posedge clk_i);

        // ----------------------------------------------------
        // Reset Checks
        // ----------------------------------------------------

        if (uart_line !== 1'b1) begin
            $display(
                "FAIL: UART line was not idle-high after reset."
            );

            error_count = error_count + 1;
        end
        else begin
            $display(
                "PASS: UART line is idle-high after reset."
            );
        end

        if (tx_busy_o !== 1'b0) begin
            $display(
                "FAIL: UART transmitter remained busy after reset."
            );

            error_count = error_count + 1;
        end
        else begin
            $display(
                "PASS: UART transmitter reset correctly."
            );
        end

        // ----------------------------------------------------
        // Data Tests
        // ----------------------------------------------------

        send_and_check(8'h00);
        send_and_check(8'hFF);
        send_and_check(8'h55);
        send_and_check(8'hAA);
        send_and_check(8'hA5);
        send_and_check(8'h3C);

        // ----------------------------------------------------
        // Final Result
        // ----------------------------------------------------

        if (error_count == 0) begin
            $display("========================================");
            $display("ALL UART TESTS PASSED");
            $display("========================================");
        end
        else begin
            $display("========================================");
            $display(
                "UART TEST FAILED WITH %0d ERROR(S)",
                error_count
            );
            $display("========================================");
        end

        $finish;
    end

endmodule