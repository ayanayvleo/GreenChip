// ============================================================
// GreenChip Power Controller
// File: power_controller.sv
// Author: A'Yana Leonard
//
// Purpose:
// Decodes the current operating state into hardware control
// signals for power management.
//
// Requirements:
// PWR-001 through PWR-015
// ============================================================

module power_controller (

    input  logic       clk_i,
    input  logic       rst_i,

    input  logic [1:0] state_i,

    output logic       low_power_o,
    output logic       normal_power_o,
    output logic       boost_o,
    output logic       protect_o,
    output logic       clock_enable_o

);

    localparam logic [1:0] STATE_ECO     = 2'b00;
    localparam logic [1:0] STATE_NORMAL  = 2'b01;
    localparam logic [1:0] STATE_BOOST   = 2'b10;
    localparam logic [1:0] STATE_PROTECT = 2'b11;

    always_ff @(posedge clk_i) begin

        if (rst_i) begin

            low_power_o    <= 1'b0;
            normal_power_o <= 1'b1;
            boost_o        <= 1'b0;
            protect_o      <= 1'b0;
            clock_enable_o <= 1'b1;

        end
        else begin

            case (state_i)

                STATE_ECO: begin

                    low_power_o    <= 1'b1;
                    normal_power_o <= 1'b0;
                    boost_o        <= 1'b0;
                    protect_o      <= 1'b0;
                    clock_enable_o <= 1'b1;

                end

                STATE_NORMAL: begin

                    low_power_o    <= 1'b0;
                    normal_power_o <= 1'b1;
                    boost_o        <= 1'b0;
                    protect_o      <= 1'b0;
                    clock_enable_o <= 1'b1;

                end

                STATE_BOOST: begin

                    low_power_o    <= 1'b0;
                    normal_power_o <= 1'b0;
                    boost_o        <= 1'b1;
                    protect_o      <= 1'b0;
                    clock_enable_o <= 1'b1;

                end

                STATE_PROTECT: begin

                    low_power_o    <= 1'b0;
                    normal_power_o <= 1'b0;
                    boost_o        <= 1'b0;
                    protect_o      <= 1'b1;
                    clock_enable_o <= 1'b0;

                end

                default: begin

                    low_power_o    <= 1'b0;
                    normal_power_o <= 1'b1;
                    boost_o        <= 1'b0;
                    protect_o      <= 1'b0;
                    clock_enable_o <= 1'b1;

                end

            endcase

        end

    end

endmodule