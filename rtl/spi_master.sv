// ============================================================
// GreenChip SPI Master
// File: spi_master.sv
// Author: A'Yana Leonard
//
// Purpose:
// Performs an 8-bit SPI transfer with configurable clock
// polarity, clock phase, and clock divider.
//
// Requirements:
// SPI-001 through SPI-008
// ============================================================

module spi_master #(
    parameter integer CLK_DIV = 4,
    parameter bit     CPOL    = 1'b0,
    parameter bit     CPHA    = 1'b0
) (
    input  logic       clk_i,
    input  logic       rst_i,

    input  logic       start_i,
    input  logic [7:0] tx_data_i,
    input  logic       miso_i,

    output logic       mosi_o,
    output logic       sclk_o,
    output logic       cs_n_o,

    output logic [7:0] rx_data_o,
    output logic       busy_o,
    output logic       done_o
);

    localparam integer DIV_COUNTER_WIDTH =
        (CLK_DIV <= 1) ? 1 : $clog2(CLK_DIV);

    logic [DIV_COUNTER_WIDTH-1:0] div_counter;
    logic [2:0]                   bit_index;
    logic [7:0]                   tx_shift;
    logic [7:0]                   rx_shift;
    logic                         edge_phase;

    initial begin
        if (CLK_DIV < 2) begin
            $error("CLK_DIV must be greater than or equal to 2.");
        end
    end

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            div_counter <= '0;
            bit_index   <= '0;
            tx_shift    <= '0;
            rx_shift    <= '0;
            edge_phase  <= 1'b0;

            mosi_o      <= 1'b0;
            sclk_o      <= CPOL;
            cs_n_o      <= 1'b1;

            rx_data_o   <= '0;
            busy_o      <= 1'b0;
            done_o      <= 1'b0;
        end
        else begin
            done_o <= 1'b0;

            if (!busy_o) begin
                sclk_o      <= CPOL;
                cs_n_o      <= 1'b1;
                div_counter <= '0;
                edge_phase  <= 1'b0;
                bit_index   <= 3'd7;

                if (start_i) begin
                    tx_shift  <= tx_data_i;
                    rx_shift  <= '0;

                    mosi_o    <= tx_data_i[7];
                    cs_n_o    <= 1'b0;
                    busy_o    <= 1'b1;
                end
            end
            else begin
                if (div_counter == CLK_DIV - 1) begin
                    div_counter <= '0;
                    edge_phase  <= ~edge_phase;

                    if (!edge_phase) begin
                        // Leading edge
                        sclk_o <= ~CPOL;

                        if (CPHA == 1'b0) begin
                            rx_shift[bit_index] <= miso_i;
                        end
                        else begin
                            mosi_o <= tx_shift[bit_index];
                        end
                    end
                    else begin
                        // Trailing edge
                        sclk_o <= CPOL;

                        if (CPHA == 1'b0) begin
                            if (bit_index == 3'd0) begin
                                rx_data_o <= {
                                    rx_shift[7:1],
                                    miso_i
                                };

                                cs_n_o <= 1'b1;
                                busy_o <= 1'b0;
                                done_o <= 1'b1;
                            end
                            else begin
                                bit_index <= bit_index - 1'b1;
                                mosi_o    <= tx_shift[bit_index - 1'b1];
                            end
                        end
                        else begin
                            rx_shift[bit_index] <= miso_i;

                            if (bit_index == 3'd0) begin
                                rx_data_o <= {
                                    rx_shift[7:1],
                                    miso_i
                                };

                                cs_n_o <= 1'b1;
                                busy_o <= 1'b0;
                                done_o <= 1'b1;
                            end
                            else begin
                                bit_index <= bit_index - 1'b1;
                            end
                        end
                    end
                end
                else begin
                    div_counter <= div_counter + 1'b1;
                end
            end
        end
    end

endmodule