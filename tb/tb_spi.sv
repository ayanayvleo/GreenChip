// ============================================================
// GreenChip SPI Master Testbench
// File: tb_spi.sv
// Author: A'Yana Leonard
//
// Purpose:
// Verifies SPI Mode 0 clock generation, MOSI transmission,
// MISO reception, chip-select timing, busy, and done behavior.
// ============================================================

`timescale 1ns/1ps

module tb_spi;

    localparam integer CLK_DIV = 2;

    logic clk_i;
    logic rst_i;

    logic       start_i;
    logic [7:0] tx_data_i;
    logic       miso_i;

    logic       mosi_o;
    logic       sclk_o;
    logic       cs_n_o;
    logic [7:0] rx_data_o;
    logic       busy_o;
    logic       done_o;

    integer error_count;
    integer edge_count;
    integer bit_position;

    logic [7:0] expected_rx_data;
    logic [7:0] captured_mosi_data;

    // --------------------------------------------------------
    // Device Under Test
    // --------------------------------------------------------

    spi_master #(
        .CLK_DIV (CLK_DIV),
        .CPOL    (1'b0),
        .CPHA    (1'b0)
    ) dut (
        .clk_i     (clk_i),
        .rst_i     (rst_i),
        .start_i   (start_i),
        .tx_data_i (tx_data_i),
        .miso_i    (miso_i),
        .mosi_o    (mosi_o),
        .sclk_o    (sclk_o),
        .cs_n_o    (cs_n_o),
        .rx_data_o (rx_data_o),
        .busy_o    (busy_o),
        .done_o    (done_o)
    );

    // --------------------------------------------------------
    // Generate a 100 MHz system clock
    //
    // Period = 10 ns
    // --------------------------------------------------------

    initial begin
        clk_i = 1'b0;

        forever begin
            #5 clk_i = ~clk_i;
        end
    end

    // --------------------------------------------------------
    // Simulated SPI Slave
    //
    // SPI Mode 0:
    // - Data is sampled on the rising edge.
    // - Data changes on the falling edge.
    // --------------------------------------------------------

    always @(negedge sclk_o) begin
        if (!cs_n_o && bit_position >= 0) begin
            miso_i <= expected_rx_data[bit_position];
        end
    end

    // Capture the MOSI bit presented by the master.
    always @(posedge sclk_o) begin
        if (!cs_n_o && bit_position >= 0) begin
            captured_mosi_data[bit_position] = mosi_o;
            edge_count = edge_count + 1;

            if (bit_position > 0) begin
                bit_position = bit_position - 1;
            end
        end
    end

    // --------------------------------------------------------
    // SPI Transfer and Verification Task
    // --------------------------------------------------------

    task automatic run_spi_test(
        input logic [7:0] transmit_byte,
        input logic [7:0] receive_byte
    );

        integer timeout_count;

        begin
            // Wait for any previous transaction to finish.
            while (busy_o || done_o) begin
                @(posedge clk_i);
            end

            tx_data_i          = transmit_byte;
            expected_rx_data   = receive_byte;
            captured_mosi_data = 8'h00;
            bit_position       = 7;
            edge_count         = 0;

            // In Mode 0, the first MISO bit must already be
            // available before the first rising SPI edge.
            miso_i = receive_byte[7];

            // Apply start away from the active system-clock edge.
            @(negedge clk_i);

            start_i = 1'b1;

            // Hold start across one rising edge.
            @(negedge clk_i);

            start_i = 1'b0;

            timeout_count = 0;

            // Confirm that the SPI master accepted the request.
            while (!busy_o && timeout_count < 20) begin
                @(posedge clk_i);
                timeout_count = timeout_count + 1;
            end

            if (timeout_count >= 20) begin
                $display(
                    "FAIL: SPI master did not accept TX=0x%02h.",
                    transmit_byte
                );

                error_count = error_count + 1;
            end
            else begin
                timeout_count = 0;

                // Wait for transaction completion.
                while (!done_o && timeout_count < 200) begin
                    @(posedge clk_i);
                    timeout_count = timeout_count + 1;
                end

                if (timeout_count >= 200) begin
                    $display(
                        "FAIL: SPI timeout for TX=0x%02h.",
                        transmit_byte
                    );

                    error_count = error_count + 1;
                end
                else begin
                    // Allow registered DUT outputs to settle.
                    #1;

                    if (rx_data_o !== receive_byte) begin
                        $display(
                            "FAIL: SPI RX expected 0x%02h, received 0x%02h.",
                            receive_byte,
                            rx_data_o
                        );

                        error_count = error_count + 1;
                    end
                    else begin
                        $display(
                            "PASS: SPI RX received 0x%02h.",
                            rx_data_o
                        );
                    end

                    if (captured_mosi_data !== transmit_byte) begin
                        $display(
                            "FAIL: SPI MOSI expected 0x%02h, captured 0x%02h.",
                            transmit_byte,
                            captured_mosi_data
                        );

                        error_count = error_count + 1;
                    end
                    else begin
                        $display(
                            "PASS: SPI MOSI transmitted 0x%02h.",
                            captured_mosi_data
                        );
                    end

                    if (edge_count != 8) begin
                        $display(
                            "FAIL: Expected 8 SPI rising edges, detected %0d.",
                            edge_count
                        );

                        error_count = error_count + 1;
                    end
                    else begin
                        $display(
                            "PASS: Correct SPI clock edge count detected."
                        );
                    end

                    if (cs_n_o !== 1'b1) begin
                        $display(
                            "FAIL: SPI chip select did not return inactive."
                        );

                        error_count = error_count + 1;
                    end
                    else begin
                        $display(
                            "PASS: SPI chip select returned inactive."
                        );
                    end
                end
            end

            // Allow done_o to clear before the next transaction.
            while (done_o) begin
                @(posedge clk_i);
            end

            repeat (2) @(posedge clk_i);
        end

    endtask

    // --------------------------------------------------------
    // Main Test Sequence
    // --------------------------------------------------------

    initial begin
        rst_i               = 1'b1;
        start_i             = 1'b0;
        tx_data_i           = 8'h00;
        miso_i              = 1'b0;
        expected_rx_data    = 8'h00;
        captured_mosi_data  = 8'h00;
        bit_position        = 7;
        edge_count          = 0;
        error_count         = 0;

        $dumpfile("sim/waveforms/tb_spi.vcd");
        $dumpvars(0, tb_spi);

        $display("========================================");
        $display("GreenChip SPI Testbench");
        $display("========================================");

        // Hold reset.
        repeat (4) @(posedge clk_i);

        // Release reset away from the active clock edge.
        @(negedge clk_i);
        rst_i = 1'b0;

        repeat (2) @(posedge clk_i);

        // ----------------------------------------------------
        // Reset Checks
        // ----------------------------------------------------

        if (cs_n_o !== 1'b1) begin
            $display(
                "FAIL: SPI chip select was not inactive after reset."
            );

            error_count = error_count + 1;
        end
        else begin
            $display(
                "PASS: SPI chip select reset correctly."
            );
        end

        if (sclk_o !== 1'b0) begin
            $display(
                "FAIL: SPI clock did not reset to CPOL=0."
            );

            error_count = error_count + 1;
        end
        else begin
            $display(
                "PASS: SPI clock reset correctly."
            );
        end

        if (busy_o !== 1'b0) begin
            $display(
                "FAIL: SPI remained busy after reset."
            );

            error_count = error_count + 1;
        end
        else begin
            $display(
                "PASS: SPI busy signal reset correctly."
            );
        end

        // ----------------------------------------------------
        // Transfer Tests
        // ----------------------------------------------------

        run_spi_test(8'hA5, 8'h3C);
        run_spi_test(8'h00, 8'hFF);
        run_spi_test(8'hFF, 8'h00);
        run_spi_test(8'h55, 8'hAA);

        // ----------------------------------------------------
        // Final Result
        // ----------------------------------------------------

        if (error_count == 0) begin
            $display("========================================");
            $display("ALL SPI TESTS PASSED");
            $display("========================================");
        end
        else begin
            $display("========================================");
            $display(
                "SPI TEST FAILED WITH %0d ERROR(S)",
                error_count
            );
            $display("========================================");
        end

        $finish;
    end

endmodule