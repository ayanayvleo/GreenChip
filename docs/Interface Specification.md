# GreenChip Interface Specification

**Project Name:** GreenChip

**Version:** 1.0

**Author:** A'Yana Leonard

---

# 1. Purpose

This document defines the interfaces used by the GreenChip FPGA system.

Every RTL module communicates through these interfaces. Maintaining consistent signal naming and interface definitions improves readability, verification, debugging, and future scalability.

---

# 2. Naming Conventions

| Suffix | Meaning |
|---------|---------|
| _i | Input |
| _o | Output |
| _n | Active Low |
| _valid | Data Valid |
| _ready | Ready Signal |
| _busy | Module Busy |
| _done | Operation Complete |
| _state | Current Operating State |
| _count | Counter Value |

---

# 3. Top-Level Interface

The GreenChip top-level module shall expose the following ports.

```systemverilog
module greenchip_top(

    input  logic clk_i,
    input  logic rst_i,

    input  logic activity_event_i,
    input  logic wake_event_i,

    input  logic [7:0] temperature_sample_i,
    input  logic temperature_valid_i,

    input  logic uart_rx_i,
    output logic uart_tx_o,

    input  logic spi_miso_i,
    output logic spi_mosi_o,
    output logic spi_clk_o,
    output logic spi_cs_n_o,

    output logic fan_pwm_o,

    output logic [3:0] led_o,

    output logic [1:0] power_state_o,

    output logic low_power_o,
    output logic boost_o,
    output logic protect_o,

    output logic fault_o

);
```

---

# 4. Signal Descriptions

## Clock

| Signal | Width | Description |
|---------|-------|-------------|
| clk_i | 1 | Primary FPGA clock |

---

## Reset

| Signal | Width | Description |
|---------|-------|-------------|
| rst_i | 1 | Active-high synchronous reset |

---

## Activity Interface

| Signal | Width | Description |
|---------|-------|-------------|
| activity_event_i | 1 | Activity pulse input |
| wake_event_i | 1 | Wake request |

---

## Temperature Interface

| Signal | Width | Description |
|---------|-------|-------------|
| temperature_sample_i | 8 | Temperature sample (°C) |
| temperature_valid_i | 1 | Sample valid indicator |

---

## UART Interface

| Signal | Width | Description |
|---------|-------|-------------|
| uart_rx_i | 1 | UART receive |
| uart_tx_o | 1 | UART transmit |

---

## SPI Interface

| Signal | Width | Description |
|---------|-------|-------------|
| spi_mosi_o | 1 | Master Out Slave In |
| spi_miso_i | 1 | Master In Slave Out |
| spi_clk_o | 1 | SPI Clock |
| spi_cs_n_o | 1 | Active-low Chip Select |

---

## PWM Interface

| Signal | Width | Description |
|---------|-------|-------------|
| fan_pwm_o | 1 | PWM cooling output |

---

## LED Interface

| Signal | Width | Description |
|---------|-------|-------------|
| led_o | 4 | Operating status LEDs |

---

## Power Control

| Signal | Width | Description |
|---------|-------|-------------|
| power_state_o | 2 | Current operating state |
| low_power_o | 1 | ECO mode output |
| boost_o | 1 | BOOST mode output |
| protect_o | 1 | PROTECT mode output |
| fault_o | 1 | Fault indicator |

---

# 5. Operating State Encoding

| State | Binary |
|---------|---------|
| ECO | 2'b00 |
| NORMAL | 2'b01 |
| BOOST | 2'b10 |
| PROTECT | 2'b11 |

---

# 6. Module Interfaces

## clock_divider

### Inputs

- clk_i
- rst_i

### Outputs

- clk_div_o
- tick_o

---

## activity_monitor

### Inputs

- clk_i
- rst_i
- activity_event_i

### Outputs

- activity_count_o
- idle_o
- high_activity_o
- sample_valid_o

---

## temperature_sensor

### Inputs

- clk_i
- rst_i
- temperature_sample_i
- temperature_valid_i

### Outputs

- temperature_o
- warm_o
- hot_o
- critical_o

---

## state_machine

### Inputs

- clk_i
- rst_i
- idle_i
- high_activity_i
- wake_event_i
- warm_i
- hot_i
- critical_i

### Outputs

- power_state_o

---

## power_controller

### Inputs

- clk_i
- rst_i
- power_state_i

### Outputs

- low_power_o
- boost_o
- protect_o

---

## fan_pwm

### Inputs

- clk_i
- rst_i
- duty_cycle_i

### Outputs

- fan_pwm_o

---

## energy_counter

### Inputs

- clk_i
- rst_i
- sample_tick_i
- power_state_i

### Outputs

- energy_total_o

---

## uart_tx

### Inputs

- clk_i
- rst_i
- tx_data_i
- tx_start_i

### Outputs

- uart_tx_o
- busy_o
- done_o

---

## uart_rx

### Inputs

- clk_i
- rst_i
- uart_rx_i

### Outputs

- rx_data_o
- data_valid_o

---

## spi_master

### Inputs

- clk_i
- rst_i
- start_i
- tx_data_i
- spi_miso_i

### Outputs

- spi_mosi_o
- spi_clk_o
- spi_cs_n_o
- rx_data_o
- busy_o
- done_o

---

## led_controller

### Inputs

- power_state_i
- fault_i

### Outputs

- led_o

---

# 7. UART Configuration

Default UART configuration

- Baud Rate: 115200
- Data Bits: 8
- Stop Bits: 1
- Parity: None

---

# 8. SPI Configuration

Default SPI configuration

- Master Mode
- 8-bit transfers
- Configurable clock divider
- Configurable SPI mode
- Single slave support

---

# 9. Parameterization

The following parameters should remain configurable throughout the design.

- Clock Frequency
- UART Baud Rate
- SPI Clock Divider
- PWM Resolution
- Temperature Thresholds
- Activity Thresholds
- Counter Widths
- Energy Increment Values

---

# 10. Design Philosophy

All module interfaces are intentionally simple, deterministic, and reusable.

Modules communicate only through documented ports, allowing each component to be independently simulated, verified, reused, and integrated into future FPGA projects with minimal modification.