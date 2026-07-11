// ============================================================
// GreenChip UART Transmitter
// File: uart_tx.sv
// Author: A'Yana Leonard
//
// Purpose:
// Transmits 8-bit data using standard UART 8-N-1 framing.
//
// Requirements:
// UART-001 through UART-007
// ============================================================

module uart_tx #(
    parameter integer CLK_FREQ_HZ = 100_000_000,
    parameter integer BAUD_RATE   = 115_200
) (
    input  logic       clk_i,
    input  logic       rst_i,
    input  logic [7:0] data_i,
    input  logic       start_i,

    output logic       tx_o,
    output logic       busy_o,
    output logic       done_o
);

    localparam integer CLKS_PER_BIT = CLK_FREQ_HZ / BAUD_RATE;
    localparam integer BAUD_COUNTER_WIDTH =
        (CLKS_PER_BIT <= 1) ? 1 : $clog2(CLKS_PER_BIT);

    typedef enum logic [2:0] {
        UART_IDLE,
        UART_START,
        UART_DATA,
        UART_STOP,
        UART_DONE
    } uart_state_t;

    uart_state_t current_state;

    logic [BAUD_COUNTER_WIDTH-1:0] baud_counter;
    logic [2:0]                    bit_index;
    logic [7:0]                    data_register;

    initial begin
        if (CLK_FREQ_HZ < BAUD_RATE) begin
            $error("CLK_FREQ_HZ must be greater than BAUD_RATE.");
        end

        if (CLKS_PER_BIT < 1) begin
            $error("CLKS_PER_BIT must be at least 1.");
        end
    end

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            current_state <= UART_IDLE;
            baud_counter  <= '0;
            bit_index     <= '0;
            data_register <= '0;

            tx_o          <= 1'b1;
            busy_o        <= 1'b0;
            done_o        <= 1'b0;
        end
        else begin
            done_o <= 1'b0;

            case (current_state)

                UART_IDLE: begin
                    tx_o         <= 1'b1;
                    busy_o       <= 1'b0;
                    baud_counter <= '0;
                    bit_index    <= '0;

                    if (start_i) begin
                        data_register <= data_i;
                        busy_o        <= 1'b1;
                        current_state <= UART_START;
                    end
                end

                UART_START: begin
                    tx_o   <= 1'b0;
                    busy_o <= 1'b1;

                    if (baud_counter == CLKS_PER_BIT - 1) begin
                        baud_counter  <= '0;
                        current_state <= UART_DATA;
                    end
                    else begin
                        baud_counter <= baud_counter + 1'b1;
                    end
                end

                UART_DATA: begin
                    tx_o   <= data_register[bit_index];
                    busy_o <= 1'b1;

                    if (baud_counter == CLKS_PER_BIT - 1) begin
                        baud_counter <= '0;

                        if (bit_index == 3'd7) begin
                            bit_index     <= '0;
                            current_state <= UART_STOP;
                        end
                        else begin
                            bit_index <= bit_index + 1'b1;
                        end
                    end
                    else begin
                        baud_counter <= baud_counter + 1'b1;
                    end
                end

                UART_STOP: begin
                    tx_o   <= 1'b1;
                    busy_o <= 1'b1;

                    if (baud_counter == CLKS_PER_BIT - 1) begin
                        baud_counter  <= '0;
                        current_state <= UART_DONE;
                    end
                    else begin
                        baud_counter <= baud_counter + 1'b1;
                    end
                end

                UART_DONE: begin
                    tx_o          <= 1'b1;
                    busy_o        <= 1'b0;
                    done_o        <= 1'b1;
                    current_state <= UART_IDLE;
                end

                default: begin
                    current_state <= UART_IDLE;
                    tx_o          <= 1'b1;
                    busy_o        <= 1'b0;
                    done_o        <= 1'b0;
                end

            endcase
        end
    end

endmodule