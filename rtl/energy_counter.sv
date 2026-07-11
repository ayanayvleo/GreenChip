// ============================================================
// GreenChip Energy Counter
// File: energy_counter.sv
// Author: A'Yana Leonard
//
// Purpose:
// Estimates cumulative energy usage based on the current
// operating state.
//
// Requirements:
// ENG-001 through ENG-009
// ============================================================

module energy_counter #(

    parameter integer ACC_WIDTH    = 32,

    parameter integer ECO_RATE     = 1,
    parameter integer NORMAL_RATE  = 3,
    parameter integer BOOST_RATE   = 6,
    parameter integer PROTECT_RATE = 4

) (

    input  logic                 clk_i,
    input  logic                 rst_i,
    input  logic                 sample_tick_i,
    input  logic [1:0]           state_i,

    output logic [ACC_WIDTH-1:0] energy_total_o

);

    localparam logic [1:0] STATE_ECO     = 2'b00;
    localparam logic [1:0] STATE_NORMAL  = 2'b01;
    localparam logic [1:0] STATE_BOOST   = 2'b10;
    localparam logic [1:0] STATE_PROTECT = 2'b11;

    always_ff @(posedge clk_i) begin

        if (rst_i) begin

            energy_total_o <= '0;

        end
        else if (sample_tick_i) begin

            case (state_i)

                STATE_ECO:
                    energy_total_o <= energy_total_o + ECO_RATE;

                STATE_NORMAL:
                    energy_total_o <= energy_total_o + NORMAL_RATE;

                STATE_BOOST:
                    energy_total_o <= energy_total_o + BOOST_RATE;

                STATE_PROTECT:
                    energy_total_o <= energy_total_o + PROTECT_RATE;

                default:
                    energy_total_o <= energy_total_o;

            endcase

        end

    end

endmodule