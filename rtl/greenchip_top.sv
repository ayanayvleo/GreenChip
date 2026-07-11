// ============================================================
// GreenChip Top-Level Integration
// File: greenchip_top.sv
// Author: A'Yana Leonard
//
// Purpose:
// Integrates the complete GreenChip FPGA power and thermal
// management system.
//
// Requirements:
// SYS-001 through SYS-015
// ============================================================

module greenchip_top #(
    parameter integer CLK_FREQ_HZ = 100_000_000,
    parameter integer UART_BAUD   = 115_200,

    parameter integer ACTIVITY_WINDOW_CYCLES = 1000,
    parameter integer IDLE_THRESHOLD         = 2,
    parameter integer HIGH_THRESHOLD         = 100,

    parameter integer WARM_THRESHOLD         = 50,
    parameter integer HOT_THRESHOLD          = 70,
    parameter integer CRITICAL_THRESHOLD     = 85,
    parameter integer RECOVERY_TEMP          = 75,

    parameter integer ENERGY_TICK_DIVISOR    = 100_000,
    parameter integer PWM_WIDTH              = 8,
    parameter integer SPI_CLK_DIV            = 4
) (
    input  logic       clk_i,
    input  logic       rst_i,

    input  logic       activity_event_i,
    input  logic       wake_event_i,

    input  logic [7:0] temperature_sample_i,
    input  logic       temperature_valid_i,

    input  logic       uart_rx_i,
    output logic       uart_tx_o,

    input  logic       spi_miso_i,
    output logic       spi_mosi_o,
    output logic       spi_clk_o,
    output logic       spi_cs_n_o,

    output logic       fan_pwm_o,
    output logic [3:0] led_o,

    output logic [1:0] power_state_o,
    output logic       low_power_o,
    output logic       boost_o,
    output logic       protect_o,
    output logic       fault_o
);

    // --------------------------------------------------------
    // Internal signals
    // --------------------------------------------------------

    logic energy_tick;
    logic unused_divided_clock;

    logic [15:0] activity_count;
    logic        activity_sample_valid;
    logic        idle_detected;
    logic        high_activity_detected;

    logic [7:0] current_temperature;
    logic       temperature_sample_valid;
    logic       warm_detected;
    logic       hot_detected;
    logic       critical_detected;

    logic [1:0] current_state;

    logic normal_power;
    logic clock_enable;

    logic [PWM_WIDTH-1:0] fan_duty_cycle;

    logic [31:0] energy_total;

    logic [7:0] uart_rx_data;
    logic       uart_rx_valid;
    logic       uart_framing_error;

    logic       uart_tx_start;
    logic       uart_tx_busy;
    logic       uart_tx_done;
    logic [7:0] uart_tx_data;

    logic [7:0] spi_rx_data;
    logic       spi_busy;
    logic       spi_done;

    // SPI is included as reusable GreenChip IP.
    // External sensor transactions will be added in a later version.
    logic spi_start;
    logic [7:0] spi_tx_data;

    // --------------------------------------------------------
    // State encodings
    // --------------------------------------------------------

    localparam logic [1:0] STATE_ECO     = 2'b00;
    localparam logic [1:0] STATE_NORMAL  = 2'b01;
    localparam logic [1:0] STATE_BOOST   = 2'b10;
    localparam logic [1:0] STATE_PROTECT = 2'b11;

    // --------------------------------------------------------
    // Top-level output assignments
    // --------------------------------------------------------

    assign power_state_o = current_state;
    assign fault_o       = critical_detected |
                           uart_framing_error;

    // --------------------------------------------------------
    // Energy timing generator
    // --------------------------------------------------------

    clock_divider #(
        .DIVISOR(ENERGY_TICK_DIVISOR)
    ) energy_tick_generator (
        .clk_i     (clk_i),
        .rst_i     (rst_i),
        .clk_div_o (unused_divided_clock),
        .tick_o    (energy_tick)
    );

    // --------------------------------------------------------
    // Activity monitor
    // --------------------------------------------------------

    activity_monitor #(
        .WINDOW_CYCLES  (ACTIVITY_WINDOW_CYCLES),
        .IDLE_THRESHOLD (IDLE_THRESHOLD),
        .HIGH_THRESHOLD (HIGH_THRESHOLD),
        .COUNT_WIDTH    (16)
    ) activity_monitor_inst (
        .clk_i             (clk_i),
        .rst_i             (rst_i),
        .activity_event_i  (activity_event_i),
        .activity_count_o  (activity_count),
        .sample_valid_o    (activity_sample_valid),
        .idle_o            (idle_detected),
        .high_activity_o   (high_activity_detected)
    );

    // --------------------------------------------------------
    // Temperature monitor
    // --------------------------------------------------------

    temperature_sensor #(
        .WARM_THRESHOLD     (WARM_THRESHOLD),
        .HOT_THRESHOLD      (HOT_THRESHOLD),
        .CRITICAL_THRESHOLD (CRITICAL_THRESHOLD)
    ) temperature_sensor_inst (
        .clk_i               (clk_i),
        .rst_i               (rst_i),
        .temperature_i       (temperature_sample_i),
        .temperature_valid_i (temperature_valid_i),
        .temperature_o       (current_temperature),
        .sample_valid_o      (temperature_sample_valid),
        .warm_o              (warm_detected),
        .hot_o               (hot_detected),
        .critical_o          (critical_detected)
    );

    // --------------------------------------------------------
    // GreenChip operating-state controller
    // --------------------------------------------------------

    state_machine #(
        .IDLE_CONFIRM_CYCLES (4),
        .RECOVERY_TEMP       (RECOVERY_TEMP)
    ) state_machine_inst (
        .clk_i            (clk_i),
        .rst_i            (rst_i),
        .idle_i           (idle_detected),
        .high_activity_i  (high_activity_detected),
        .wake_event_i     (wake_event_i),
        .hot_i            (hot_detected),
        .critical_i       (critical_detected),
        .temperature_i    (current_temperature),
        .state_o          (current_state)
    );

    // --------------------------------------------------------
    // Power-control output decoder
    // --------------------------------------------------------

    power_controller power_controller_inst (
        .clk_i          (clk_i),
        .rst_i          (rst_i),
        .state_i        (current_state),
        .low_power_o    (low_power_o),
        .normal_power_o (normal_power),
        .boost_o        (boost_o),
        .protect_o      (protect_o),
        .clock_enable_o (clock_enable)
    );

    // --------------------------------------------------------
    // Fan duty-cycle policy
    // --------------------------------------------------------

    always_comb begin
        fan_duty_cycle = 8'd89;

        if (current_state == STATE_PROTECT ||
            critical_detected) begin

            fan_duty_cycle = 8'd255;
        end
        else if (hot_detected) begin

            fan_duty_cycle = 8'd204;
        end
        else if (warm_detected) begin

            fan_duty_cycle = 8'd140;
        end
        else begin
            case (current_state)

                STATE_ECO:
                    fan_duty_cycle = 8'd51;

                STATE_NORMAL:
                    fan_duty_cycle = 8'd89;

                STATE_BOOST:
                    fan_duty_cycle = 8'd166;

                default:
                    fan_duty_cycle = 8'd89;

            endcase
        end
    end

    // --------------------------------------------------------
    // PWM fan controller
    // --------------------------------------------------------

    fan_pwm #(
        .PWM_WIDTH(PWM_WIDTH)
    ) fan_pwm_inst (
        .clk_i        (clk_i),
        .rst_i        (rst_i),
        .duty_cycle_i (fan_duty_cycle),
        .pwm_o        (fan_pwm_o)
    );

    // --------------------------------------------------------
    // Estimated energy counter
    // --------------------------------------------------------

    energy_counter #(
        .ACC_WIDTH    (32),
        .ECO_RATE     (1),
        .NORMAL_RATE  (3),
        .BOOST_RATE   (6),
        .PROTECT_RATE (4)
    ) energy_counter_inst (
        .clk_i          (clk_i),
        .rst_i          (rst_i),
        .sample_tick_i  (energy_tick),
        .state_i        (current_state),
        .energy_total_o (energy_total)
    );

    // --------------------------------------------------------
    // LED status controller
    // --------------------------------------------------------

    led_controller led_controller_inst (
        .state_i (current_state),
        .fault_i (fault_o),
        .led_o   (led_o)
    );

    // --------------------------------------------------------
    // UART receiver
    // --------------------------------------------------------

    uart_rx #(
        .CLK_FREQ_HZ (CLK_FREQ_HZ),
        .BAUD_RATE   (UART_BAUD)
    ) uart_rx_inst (
        .clk_i           (clk_i),
        .rst_i           (rst_i),
        .rx_i            (uart_rx_i),
        .data_o          (uart_rx_data),
        .valid_o         (uart_rx_valid),
        .framing_error_o (uart_framing_error)
    );

    // --------------------------------------------------------
    // UART telemetry trigger
    //
    // Version 1 transmits the latest temperature whenever a
    // valid temperature sample is received and UART is idle.
    // --------------------------------------------------------

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            uart_tx_start <= 1'b0;
            uart_tx_data  <= 8'd0;
        end
        else begin
            uart_tx_start <= 1'b0;

            if (temperature_sample_valid &&
                !uart_tx_busy) begin

                uart_tx_data  <= current_temperature;
                uart_tx_start <= 1'b1;
            end
        end
    end

    // --------------------------------------------------------
    // UART transmitter
    // --------------------------------------------------------

    uart_tx #(
        .CLK_FREQ_HZ (CLK_FREQ_HZ),
        .BAUD_RATE   (UART_BAUD)
    ) uart_tx_inst (
        .clk_i   (clk_i),
        .rst_i   (rst_i),
        .data_i  (uart_tx_data),
        .start_i (uart_tx_start),
        .tx_o    (uart_tx_o),
        .busy_o  (uart_tx_busy),
        .done_o  (uart_tx_done)
    );

    // --------------------------------------------------------
    // SPI master
    //
    // SPI remains idle in Version 1 until an external sensor
    // transaction controller is added.
    // --------------------------------------------------------

    assign spi_start   = 1'b0;
    assign spi_tx_data = 8'd0;

    spi_master #(
        .CLK_DIV (SPI_CLK_DIV),
        .CPOL    (1'b0),
        .CPHA    (1'b0)
    ) spi_master_inst (
        .clk_i     (clk_i),
        .rst_i     (rst_i),
        .start_i   (spi_start),
        .tx_data_i (spi_tx_data),
        .miso_i    (spi_miso_i),
        .mosi_o    (spi_mosi_o),
        .sclk_o    (spi_clk_o),
        .cs_n_o    (spi_cs_n_o),
        .rx_data_o (spi_rx_data),
        .busy_o    (spi_busy),
        .done_o    (spi_done)
    );

endmodule