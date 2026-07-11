// ============================================================
// GreenChip UART Receiver
// File: uart_rx.sv
// Author: A'Yana Leonard
//
// Purpose:
// Receives 8-bit UART data using standard 8-N-1 framing.
// Samples each UART bit near its center for reliable decoding.
//
// Requirements:
// UART-001 through UART-007
// ============================================================

module uart_rx #(
    parameter integer CLK_FREQ_HZ = 100_000_000,
    parameter integer BAUD_RATE   = 115_200
) (
    input  logic       clk_i,
    input  logic       rst_i,
    input  logic       rx_i,

    output logic [7:0] data_o,
    output logic       valid_o,
    output logic       framing_error_o
);

    localparam integer CLKS_PER_BIT =
        CLK_FREQ_HZ / BAUD_RATE;

    localparam integer HALF_CLKS_PER_BIT =
        CLKS_PER_BIT / 2;

    localparam integer BAUD_COUNTER_WIDTH =
        (CLKS_PER_BIT <= 1)
        ? 1
        : $clog2(CLKS_PER_BIT);

    typedef enum logic [2:0] {
        RX_IDLE,
        RX_START,
        RX_DATA,
        RX_STOP,
        RX_DONE
    } rx_state_t;

    rx_state_t current_state;

    logic [BAUD_COUNTER_WIDTH-1:0] baud_counter;
    logic [2:0]                    bit_index;
    logic [7:0]                    shift_register;

    initial begin
        if (CLK_FREQ_HZ < BAUD_RATE) begin
            $error(
                "CLK_FREQ_HZ must be greater than BAUD_RATE."
            );
        end

        if (CLKS_PER_BIT < 2) begin
            $error(
                "CLKS_PER_BIT must be at least 2."
            );
        end
    end

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            current_state   <= RX_IDLE;
            baud_counter    <= '0;
            bit_index       <= '0;
            shift_register  <= '0;

            data_o          <= '0;
            valid_o         <= 1'b0;
            framing_error_o <= 1'b0;
        end
        else begin
            // valid_o is a one-clock pulse.
            valid_o <= 1'b0;

            case (current_state)

                // ------------------------------------------------
                // Wait for the UART line to go low.
                // A low line indicates the beginning of a start bit.
                // ------------------------------------------------

                RX_IDLE: begin
                    baud_counter    <= '0;
                    bit_index       <= '0;
                    framing_error_o <= 1'b0;

                    if (rx_i == 1'b0) begin
                        current_state <= RX_START;
                    end
                end

                // ------------------------------------------------
                // Wait until the center of the start bit.
                // Confirm the line is still low.
                // ------------------------------------------------

                RX_START: begin
                    if (
                        baud_counter ==
                        HALF_CLKS_PER_BIT - 1
                    ) begin
                        baud_counter <= '0;

                        if (rx_i == 1'b0) begin
                            bit_index     <= '0;
                            current_state <= RX_DATA;
                        end
                        else begin
                            // False start-bit detection.
                            current_state <= RX_IDLE;
                        end
                    end
                    else begin
                        baud_counter <= baud_counter + 1'b1;
                    end
                end

                // ------------------------------------------------
                // Sample each of the eight data bits.
                // UART transmits least-significant bit first.
                // ------------------------------------------------

                RX_DATA: begin
                    if (
                        baud_counter ==
                        CLKS_PER_BIT - 1
                    ) begin
                        baud_counter <= '0;

                        shift_register[bit_index] <= rx_i;

                        if (bit_index == 3'd7) begin
                            bit_index     <= '0;
                            current_state <= RX_STOP;
                        end
                        else begin
                            bit_index <= bit_index + 1'b1;
                        end
                    end
                    else begin
                        baud_counter <= baud_counter + 1'b1;
                    end
                end

                // ------------------------------------------------
                // Verify that the stop bit is high.
                // ------------------------------------------------

                RX_STOP: begin
                    if (
                        baud_counter ==
                        CLKS_PER_BIT - 1
                    ) begin
                        baud_counter <= '0;

                        if (rx_i == 1'b1) begin
                            data_o        <= shift_register;
                            current_state <= RX_DONE;
                        end
                        else begin
                            framing_error_o <= 1'b1;
                            current_state   <= RX_IDLE;
                        end
                    end
                    else begin
                        baud_counter <= baud_counter + 1'b1;
                    end
                end

                // ------------------------------------------------
                // Report the completed byte for one clock cycle.
                // ------------------------------------------------

                RX_DONE: begin
                    valid_o       <= 1'b1;
                    current_state <= RX_IDLE;
                end

                default: begin
                    current_state   <= RX_IDLE;
                    baud_counter    <= '0;
                    bit_index       <= '0;
                    shift_register  <= '0;
                end

            endcase
        end
    end

endmodule