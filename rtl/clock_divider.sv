// ============================================================
// GreenChip Clock Divider
// File: clock_divider.sv
// Author: A'Yana Leonard
//
// Purpose:
// Divides the primary FPGA clock and generates a single-cycle
// timing pulse.
//
// Requirements:
// CLK-001 through CLK-004
// ============================================================

module clock_divider #(
    parameter integer DIVISOR = 100
) (
    input  logic clk_i,
    input  logic rst_i,

    output logic clk_div_o,
    output logic tick_o
);

    // Determine the number of counter bits required.
    localparam integer COUNTER_WIDTH =
        (DIVISOR <= 2) ? 1 : $clog2(DIVISOR);

    logic [COUNTER_WIDTH-1:0] counter;

    // Prevent invalid parameter values.
    initial begin
        if (DIVISOR < 2) begin
            $error("DIVISOR must be greater than or equal to 2.");
        end
    end

    // Clock-divider logic
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            counter   <= '0;
            clk_div_o <= 1'b0;
            tick_o    <= 1'b0;
        end
        else begin
            // Tick normally remains low.
            tick_o <= 1'b0;

            // Toggle divided clock after half of the divisor period.
            if (counter == (DIVISOR / 2) - 1) begin
                counter   <= '0;
                clk_div_o <= ~clk_div_o;
                tick_o    <= 1'b1;
            end
            else begin
                counter <= counter + 1'b1;
            end
        end
    end

endmodule