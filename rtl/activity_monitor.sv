// ============================================================
// GreenChip Activity Monitor
// File: activity_monitor.sv
// Author: A'Yana Leonard
//
// Purpose:
// Counts activity events during a configurable observation
// window and classifies the workload as idle, normal, or high.
//
// Requirements:
// ACT-001 through ACT-009
// ============================================================

module activity_monitor #(
    parameter integer WINDOW_CYCLES  = 1000,
    parameter integer IDLE_THRESHOLD = 2,
    parameter integer HIGH_THRESHOLD = 100,
    parameter integer COUNT_WIDTH    = 16
) (
    input  logic                   clk_i,
    input  logic                   rst_i,
    input  logic                   activity_event_i,

    output logic [COUNT_WIDTH-1:0] activity_count_o,
    output logic                   sample_valid_o,
    output logic                   idle_o,
    output logic                   high_activity_o
);

    localparam integer WINDOW_COUNTER_WIDTH =
        (WINDOW_CYCLES <= 2) ? 1 : $clog2(WINDOW_CYCLES);

    logic [WINDOW_COUNTER_WIDTH-1:0] window_counter;
    logic [COUNT_WIDTH-1:0]          event_counter;

    initial begin
        if (WINDOW_CYCLES < 1) begin
            $error("WINDOW_CYCLES must be greater than zero.");
        end

        if (HIGH_THRESHOLD <= IDLE_THRESHOLD) begin
            $error(
                "HIGH_THRESHOLD must be greater than IDLE_THRESHOLD."
            );
        end
    end

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            window_counter   <= '0;
            event_counter    <= '0;
            activity_count_o <= '0;
            sample_valid_o   <= 1'b0;
            idle_o           <= 1'b1;
            high_activity_o  <= 1'b0;
        end
        else begin
            sample_valid_o <= 1'b0;

            // Count incoming activity pulses.
            if (activity_event_i) begin
                if (event_counter != {COUNT_WIDTH{1'b1}}) begin
                    event_counter <= event_counter + 1'b1;
                end
            end

            // Complete the current observation window.
            if (window_counter == WINDOW_CYCLES - 1) begin
                window_counter   <= '0;
                activity_count_o <= event_counter;
                sample_valid_o   <= 1'b1;

                if (event_counter <= IDLE_THRESHOLD) begin
                    idle_o          <= 1'b1;
                    high_activity_o <= 1'b0;
                end
                else if (event_counter >= HIGH_THRESHOLD) begin
                    idle_o          <= 1'b0;
                    high_activity_o <= 1'b1;
                end
                else begin
                    idle_o          <= 1'b0;
                    high_activity_o <= 1'b0;
                end

                event_counter <= '0;
            end
            else begin
                window_counter <= window_counter + 1'b1;
            end
        end
    end

endmodule