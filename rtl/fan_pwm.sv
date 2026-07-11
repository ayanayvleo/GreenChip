// ============================================================
// GreenChip PWM Fan Controller
// File: fan_pwm.sv
// Author: A'Yana Leonard
//
// Purpose:
// Generates a pulse-width modulation signal for fan control.
//
// Requirements:
// FAN-001 through FAN-007
// ============================================================

module fan_pwm #(
    parameter integer PWM_WIDTH = 8
) (
    input  logic                 clk_i,
    input  logic                 rst_i,
    input  logic [PWM_WIDTH-1:0] duty_cycle_i,

    output logic                 pwm_o
);

    logic [PWM_WIDTH-1:0] pwm_counter;

    initial begin
        if (PWM_WIDTH < 1) begin
            $error("PWM_WIDTH must be greater than zero.");
        end
    end

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            pwm_counter <= '0;
            pwm_o       <= 1'b0;
        end
        else begin
            pwm_counter <= pwm_counter + 1'b1;

            if (duty_cycle_i == {PWM_WIDTH{1'b0}}) begin
                pwm_o <= 1'b0;
            end
            else if (duty_cycle_i == {PWM_WIDTH{1'b1}}) begin
                pwm_o <= 1'b1;
            end
            else begin
                pwm_o <= (pwm_counter < duty_cycle_i);
            end
        end
    end

endmodule