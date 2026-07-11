# ============================================================
# GreenChip Basys 3 Constraints
# Target: Digilent Basys 3
# FPGA: xc7a35tcpg236-1
#
# IMPORTANT:
# This bitstream is intended specifically for the Basys 3.
# Do not program it onto a different FPGA board.
# ============================================================


# ------------------------------------------------------------
# 100 MHz System Clock
# Basys 3 onboard clock
# ------------------------------------------------------------

set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } \
    [get_ports clk_i]

create_clock \
    -add \
    -name greenchip_system_clock \
    -period 10.000 \
    -waveform {0.000 5.000} \
    [get_ports clk_i]


# ------------------------------------------------------------
# Reset Button
# Center pushbutton
# ------------------------------------------------------------

set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } \
    [get_ports rst_i]


# ------------------------------------------------------------
# Input Switches
#
# SW0-SW7  = Temperature value
# SW8      = Activity event
# SW9      = Wake event
# SW10     = Temperature valid
# ------------------------------------------------------------

set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33 } \
    [get_ports {temperature_sample_i[0]}]

set_property -dict { PACKAGE_PIN V16 IOSTANDARD LVCMOS33 } \
    [get_ports {temperature_sample_i[1]}]

set_property -dict { PACKAGE_PIN W16 IOSTANDARD LVCMOS33 } \
    [get_ports {temperature_sample_i[2]}]

set_property -dict { PACKAGE_PIN W17 IOSTANDARD LVCMOS33 } \
    [get_ports {temperature_sample_i[3]}]

set_property -dict { PACKAGE_PIN W15 IOSTANDARD LVCMOS33 } \
    [get_ports {temperature_sample_i[4]}]

set_property -dict { PACKAGE_PIN V15 IOSTANDARD LVCMOS33 } \
    [get_ports {temperature_sample_i[5]}]

set_property -dict { PACKAGE_PIN W14 IOSTANDARD LVCMOS33 } \
    [get_ports {temperature_sample_i[6]}]

set_property -dict { PACKAGE_PIN W13 IOSTANDARD LVCMOS33 } \
    [get_ports {temperature_sample_i[7]}]

set_property -dict { PACKAGE_PIN V2 IOSTANDARD LVCMOS33 } \
    [get_ports activity_event_i]

set_property -dict { PACKAGE_PIN T3 IOSTANDARD LVCMOS33 } \
    [get_ports wake_event_i]

set_property -dict { PACKAGE_PIN T2 IOSTANDARD LVCMOS33 } \
    [get_ports temperature_valid_i]


# ------------------------------------------------------------
# USB UART
#
# Basys 3 onboard USB-to-UART bridge
# ------------------------------------------------------------

set_property -dict { PACKAGE_PIN B18 IOSTANDARD LVCMOS33 } \
    [get_ports uart_rx_i]

set_property -dict { PACKAGE_PIN A18 IOSTANDARD LVCMOS33 } \
    [get_ports uart_tx_o]


# ------------------------------------------------------------
# SPI Interface — Pmod JA
#
# JA1 = Fan PWM
# JA2 = SPI MOSI
# JA3 = SPI Clock
# JA4 = SPI Chip Select
# JA7 = SPI MISO
# ------------------------------------------------------------

set_property -dict { PACKAGE_PIN J1 IOSTANDARD LVCMOS33 } \
    [get_ports fan_pwm_o]

set_property -dict { PACKAGE_PIN L2 IOSTANDARD LVCMOS33 } \
    [get_ports spi_mosi_o]

set_property -dict { PACKAGE_PIN J2 IOSTANDARD LVCMOS33 } \
    [get_ports spi_clk_o]

set_property -dict { PACKAGE_PIN G2 IOSTANDARD LVCMOS33 } \
    [get_ports spi_cs_n_o]

set_property -dict { PACKAGE_PIN H1 IOSTANDARD LVCMOS33 } \
    [get_ports spi_miso_i]


# ------------------------------------------------------------
# LED Outputs
#
# LED0-LED3 = GreenChip state pattern
# LED4-LED5 = Encoded power state
# LED6      = Low-power output
# LED7      = Boost output
# LED8      = Protect output
# LED9      = Fault output
# ------------------------------------------------------------

set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } \
    [get_ports {led_o[0]}]

set_property -dict { PACKAGE_PIN E19 IOSTANDARD LVCMOS33 } \
    [get_ports {led_o[1]}]

set_property -dict { PACKAGE_PIN U19 IOSTANDARD LVCMOS33 } \
    [get_ports {led_o[2]}]

set_property -dict { PACKAGE_PIN V19 IOSTANDARD LVCMOS33 } \
    [get_ports {led_o[3]}]

set_property -dict { PACKAGE_PIN W18 IOSTANDARD LVCMOS33 } \
    [get_ports {power_state_o[0]}]

set_property -dict { PACKAGE_PIN U15 IOSTANDARD LVCMOS33 } \
    [get_ports {power_state_o[1]}]

set_property -dict { PACKAGE_PIN U14 IOSTANDARD LVCMOS33 } \
    [get_ports low_power_o]

set_property -dict { PACKAGE_PIN V14 IOSTANDARD LVCMOS33 } \
    [get_ports boost_o]

set_property -dict { PACKAGE_PIN V13 IOSTANDARD LVCMOS33 } \
    [get_ports protect_o]

set_property -dict { PACKAGE_PIN V3 IOSTANDARD LVCMOS33 } \
    [get_ports fault_o]


# ------------------------------------------------------------
# Basys 3 Configuration
# ------------------------------------------------------------

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]