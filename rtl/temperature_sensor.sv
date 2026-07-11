// ============================================================
// GreenChip Temperature Sensor Interface
// File: temperature_sensor.sv
// Author: A'Yana Leonard
//
// Purpose:
// Stores the latest valid temperature sample and classifies it
// as normal, warm, hot, or critical.
//
// Requirements:
// TMP-001 through TMP-010
// ============================================================

module temperature_sensor #(
    parameter integer WARM_THRESHOLD     = 50,
    parameter integer HOT_THRESHOLD      = 70,
    parameter integer CRITICAL_THRESHOLD = 85
) (
    input  logic       clk_i,
    input  logic       rst_i,
    input  logic [7:0] temperature_i,
    input  logic       temperature_valid_i,

    output logic [7:0] temperature_o,
    output logic       sample_valid_o,
    output logic       warm_o,
    output logic       hot_o,
    output logic       critical_o
);

    initial begin
        if (WARM_THRESHOLD >= HOT_THRESHOLD) begin
            $error("WARM_THRESHOLD must be less than HOT_THRESHOLD.");
        end

        if (HOT_THRESHOLD >= CRITICAL_THRESHOLD) begin
            $error("HOT_THRESHOLD must be less than CRITICAL_THRESHOLD.");
        end

        if (CRITICAL_THRESHOLD > 255) begin
            $error("CRITICAL_THRESHOLD must fit within 8 bits.");
        end
    end

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            temperature_o <= 8'd0;
            sample_valid_o <= 1'b0;
            warm_o         <= 1'b0;
            hot_o          <= 1'b0;
            critical_o     <= 1'b0;
        end
        else begin
            sample_valid_o <= 1'b0;

            if (temperature_valid_i) begin
                temperature_o <= temperature_i;
                sample_valid_o <= 1'b1;

                if (temperature_i >= CRITICAL_THRESHOLD) begin
                    warm_o     <= 1'b1;
                    hot_o      <= 1'b1;
                    critical_o <= 1'b1;
                end
                else if (temperature_i >= HOT_THRESHOLD) begin
                    warm_o     <= 1'b1;
                    hot_o      <= 1'b1;
                    critical_o <= 1'b0;
                end
                else if (temperature_i >= WARM_THRESHOLD) begin
                    warm_o     <= 1'b1;
                    hot_o      <= 1'b0;
                    critical_o <= 1'b0;
                end
                else begin
                    warm_o     <= 1'b0;
                    hot_o      <= 1'b0;
                    critical_o <= 1'b0;
                end
            end
        end
    end

endmodule