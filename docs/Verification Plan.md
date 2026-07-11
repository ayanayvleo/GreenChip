# GreenChip Verification Plan

**Project Name:** GreenChip

**Version:** 1.0

**Author:** A'Yana Leonard

---

# 1. Purpose

The purpose of this Verification Plan is to define the strategy, methodology, and test procedures that will be used to verify the functionality of the GreenChip FPGA design.

Verification ensures that every module behaves according to the project requirements before full system integration.

---

# 2. Verification Objectives

The primary objectives are to:

- Verify every RTL module independently.
- Verify module interfaces.
- Verify top-level integration.
- Detect functional defects early.
- Ensure deterministic operation.
- Verify state transitions.
- Verify communication protocols.
- Verify reset behavior.
- Verify boundary conditions.
- Verify fault handling.

---

# 3. Verification Strategy

GreenChip will use a bottom-up verification methodology.

Development Order

```
RTL Module

↓

Module Testbench

↓

Simulation

↓

Debug

↓

Verification

↓

Integration

↓

System Test

↓

Final Verification
```

Every module must pass verification before it is integrated into the top-level design.

---

# 4. Verification Environment

Simulation Tools

- Icarus Verilog
- vvp
- GTKWave

FPGA Tools

- AMD Vivado

Development Environment

- Visual Studio Code
- Git
- PowerShell

---

# 5. Module Verification

Each RTL module shall receive its own dedicated testbench.

| RTL Module | Testbench |
|------------|-----------|
| clock_divider.sv | tb_clock_divider.sv |
| activity_monitor.sv | (Future) |
| temperature_sensor.sv | (Future) |
| state_machine.sv | (Future) |
| power_controller.sv | tb_power_controller.sv |
| fan_pwm.sv | (Future) |
| energy_counter.sv | (Future) |
| uart_tx.sv | tb_uart.sv |
| uart_rx.sv | tb_uart.sv |
| spi_master.sv | tb_spi.sv |
| led_controller.sv | (Future) |
| greenchip_top.sv | tb_greenchip_top.sv |

---

# 6. Functional Verification

The following functionality shall be verified.

## Clock Divider

Verify

- Clock division
- Tick generation
- Reset
- Parameterized division ratios

---

## Activity Monitor

Verify

- Activity counting
- Idle detection
- High activity detection
- Counter reset
- Observation window timing

---

## Temperature Sensor

Verify

- Temperature capture
- Threshold comparison
- Warm detection
- Hot detection
- Critical detection

---

## State Machine

Verify

- Initial state
- ECO transitions
- NORMAL transitions
- BOOST transitions
- PROTECT transitions
- Recovery behavior

---

## Power Controller

Verify

- Low-power output
- Boost output
- Protect output
- State decoding

---

## Fan PWM

Verify

- PWM generation
- Duty-cycle accuracy
- Maximum cooling
- Reset behavior

---

## Energy Counter

Verify

- Counter reset
- Energy accumulation
- State-dependent increments
- Overflow behavior

---

## UART

Verify

- Transmission
- Reception
- Busy signal
- Done signal
- Baud-rate timing

---

## SPI

Verify

- Clock generation
- MOSI
- MISO
- Chip Select
- Busy signal
- Done signal

---

## LED Controller

Verify

- Operating-state indication
- Fault indication

---

# 7. Reset Verification

Every module shall be tested for proper reset behavior.

Reset verification includes

- Counter initialization
- Register initialization
- State initialization
- Output initialization

---

# 8. Boundary Testing

Each module shall be tested using

- Minimum values
- Maximum values
- Threshold values
- Overflow conditions
- Underflow conditions

---

# 9. Fault Testing

Fault scenarios include

- Invalid temperature values
- Critical temperature
- Invalid UART data
- SPI communication failures
- Invalid state transitions
- Reset during operation

---

# 10. Integration Verification

After all modules have passed standalone verification, the following integration tests shall be performed.

- Clock distribution
- Signal routing
- State transitions
- UART telemetry
- SPI communication
- Fan control
- LED indication
- Energy estimation

---

# 11. Regression Testing

Every bug fix shall be followed by regression testing.

Regression testing ensures that fixing one defect does not introduce additional defects.

Minimum regression suite

- Clock Divider
- UART
- SPI
- Power Controller
- Top-Level Integration

---

# 12. Waveform Analysis

Simulation waveforms shall be reviewed for

- Correct timing
- Correct state transitions
- Proper signal synchronization
- PWM behavior
- UART timing
- SPI timing

Waveforms will be stored in

```
sim/waveforms/
```

---

# 13. Success Criteria

GreenChip verification will be considered successful when

- Every RTL module compiles successfully.
- Every dedicated testbench passes.
- Top-level integration behaves correctly.
- No functional errors remain.
- All required simulations complete successfully.
- Waveforms match expected behavior.
- All project requirements are satisfied.

---

# 14. Verification Deliverables

The verification process will produce

- Testbenches
- Simulation logs
- Waveform files
- Verification reports
- Timing reports
- Regression test results

These deliverables provide objective evidence that GreenChip satisfies its functional requirements and is ready for FPGA implementation.