// ============================================================
// GreenChip LED Controller
// File: led_controller.sv
// Author: A'Yana Leonard
//
// Purpose:
// Displays the current GreenChip operating state and provides
// a visible fault override.
//
// Requirements:
// LED-001 through LED-002
// FLT-001 through FLT-004
// ============================================================

module led_controller (
    input  logic [1:0] state_i,
    input  logic       fault_i,

    output logic [3:0] led_o
);

    localparam logic [1:0] STATE_ECO     = 2'b00;
    localparam logic [1:0] STATE_NORMAL  = 2'b01;
    localparam logic [1:0] STATE_BOOST   = 2'b10;
    localparam logic [1:0] STATE_PROTECT = 2'b11;

    always_comb begin
        if (fault_i) begin
            led_o = 4'b1111;
        end
        else begin
            case (state_i)

                STATE_ECO:
                    led_o = 4'b0001;

                STATE_NORMAL:
                    led_o = 4'b0010;

                STATE_BOOST:
                    led_o = 4'b0100;

                STATE_PROTECT:
                    led_o = 4'b1000;

                default:
                    led_o = 4'b0010;

            endcase
        end
    end

endmodule