// ============================================================
// GreenChip State Machine
// File: state_machine.sv
// Author: A'Yana Leonard
//
// Purpose:
// Selects ECO, NORMAL, BOOST, or PROTECT based on workload
// activity and thermal conditions.
//
// Requirements:
// PWR-001 through PWR-015
// ============================================================

module state_machine #(
    parameter integer IDLE_CONFIRM_CYCLES = 4,
    parameter integer RECOVERY_TEMP       = 75
) (
    input  logic       clk_i,
    input  logic       rst_i,

    input  logic       idle_i,
    input  logic       high_activity_i,
    input  logic       wake_event_i,

    input  logic       hot_i,
    input  logic       critical_i,
    input  logic [7:0] temperature_i,

    output logic [1:0] state_o
);

    localparam logic [1:0] STATE_ECO     = 2'b00;
    localparam logic [1:0] STATE_NORMAL  = 2'b01;
    localparam logic [1:0] STATE_BOOST   = 2'b10;
    localparam logic [1:0] STATE_PROTECT = 2'b11;

    localparam integer IDLE_COUNT_WIDTH =
        (IDLE_CONFIRM_CYCLES <= 1)
        ? 1
        : $clog2(IDLE_CONFIRM_CYCLES + 1);

    logic [1:0] current_state;
    logic [1:0] next_state;

    logic [IDLE_COUNT_WIDTH-1:0] idle_counter;
    logic idle_confirmed;

    initial begin
        if (IDLE_CONFIRM_CYCLES < 1) begin
            $error("IDLE_CONFIRM_CYCLES must be greater than zero.");
        end

        if (RECOVERY_TEMP > 255) begin
            $error("RECOVERY_TEMP must fit within 8 bits.");
        end
    end

    assign state_o = current_state;

    assign idle_confirmed =
        (idle_counter >= IDLE_CONFIRM_CYCLES);

    // Count consecutive idle cycles.
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            idle_counter <= '0;
        end
        else begin
            if (!idle_i || wake_event_i || critical_i) begin
                idle_counter <= '0;
            end
            else if (idle_counter < IDLE_CONFIRM_CYCLES) begin
                idle_counter <= idle_counter + 1'b1;
            end
        end
    end

    // State register.
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            current_state <= STATE_NORMAL;
        end
        else begin
            current_state <= next_state;
        end
    end

    // Next-state logic.
    always_comb begin
        next_state = current_state;

        // Thermal protection always has highest priority.
        if (critical_i) begin
            next_state = STATE_PROTECT;
        end
        else begin
            case (current_state)

                STATE_ECO: begin
                    if (wake_event_i || !idle_i) begin
                        next_state = STATE_NORMAL;
                    end
                end

                STATE_NORMAL: begin
                    if (high_activity_i && !hot_i) begin
                        next_state = STATE_BOOST;
                    end
                    else if (idle_confirmed && !hot_i) begin
                        next_state = STATE_ECO;
                    end
                end

                STATE_BOOST: begin
                    if (hot_i || !high_activity_i) begin
                        next_state = STATE_NORMAL;
                    end
                end

                STATE_PROTECT: begin
                    if (!critical_i &&
                        temperature_i < RECOVERY_TEMP) begin
                        next_state = STATE_NORMAL;
                    end
                end

                default: begin
                    next_state = STATE_NORMAL;
                end

            endcase
        end
    end

endmodule