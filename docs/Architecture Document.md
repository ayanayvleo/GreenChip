# GreenChip Architecture Document

**Project Name:** GreenChip

**Version:** 1.0

**Author:** A'Yana Leonard

---

# 1. Purpose

This document defines the overall hardware architecture of GreenChip, an FPGA-based adaptive power and thermal management system.

The architecture is designed around reusable SystemVerilog modules that operate together to monitor hardware activity, estimate energy consumption, control cooling, and transition between intelligent operating states.

The design follows modern FPGA engineering practices emphasizing modularity, scalability, deterministic operation, and maintainability.

---

# 2. System Overview

GreenChip continuously monitors system activity and thermal conditions before making hardware-level power management decisions.

Instead of relying on software, GreenChip performs all decision-making directly in FPGA logic, allowing immediate responses at the clock-cycle level.

The system operates using one primary clock domain and a collection of independent RTL modules connected through well-defined interfaces.

---

# 3. High-Level Architecture

```
                     +----------------------+
                     |   System Clock       |
                     |      Reset           |
                     +----------+-----------+
                                |
                                v
                     +----------------------+
                     |   Clock Divider      |
                     +----------+-----------+
                                |
          +---------------------+----------------------+
          |                                            |
          v                                            v
+----------------------+                 +----------------------+
| Activity Monitor     |                 | Temperature Sensor   |
+----------+-----------+                 +----------+-----------+
           |                                         |
           +----------------+------------------------+
                            |
                            v
                 +---------------------------+
                 |     State Machine         |
                 | ECO NORMAL BOOST PROTECT |
                 +------+------------+-------+
                        |            |
                        |            |
            +-----------+            +-----------+
            |                                    |
            v                                    v
+----------------------+              +----------------------+
| Power Controller     |              | PWM Fan Controller   |
+----------+-----------+              +----------+-----------+
           |                                     |
           +---------------+---------------------+
                           |
                           v
                +-------------------------+
                | Energy Counter          |
                +-----------+-------------+
                            |
                            v
              +-----------------------------+
              | UART + LED Controller       |
              +-----------------------------+
```

---

# 4. Module Hierarchy

```
greenchip_top

├── clock_divider

├── activity_monitor

├── temperature_sensor

├── state_machine

├── power_controller

├── fan_pwm

├── energy_counter

├── uart_tx

├── uart_rx

├── spi_master

└── led_controller
```

---

# 5. Module Responsibilities

## clock_divider

Responsibilities

- Generate slower timing enables
- Create periodic sampling intervals
- Support simulation timing
- Reduce unnecessary counter duplication

---

## activity_monitor

Responsibilities

- Detect hardware activity
- Count activity events
- Determine idle conditions
- Detect high workloads
- Provide activity statistics

---

## temperature_sensor

Responsibilities

- Receive digital temperature samples
- Store latest valid reading
- Compare against thresholds
- Generate

- Warm

- Hot

- Critical

status outputs

---

## state_machine

Responsible for selecting the operating mode.

Supported States

- ECO
- NORMAL
- BOOST
- PROTECT

The state machine is the primary decision-making block within GreenChip.

---

## power_controller

Responsibilities

- Decode operating state
- Generate power control outputs
- Enable low-power operation
- Enable boost mode
- Activate protection mode

---

## fan_pwm

Responsibilities

- Generate PWM waveform
- Increase fan speed as temperature rises
- Force maximum cooling during thermal protection

---

## energy_counter

Responsibilities

- Estimate energy consumption
- Accumulate energy usage
- Track long-term power behavior

---

## uart_tx

Responsibilities

- Transmit telemetry
- Report operating state
- Report activity
- Report temperature
- Report energy usage
- Report fault conditions

---

## uart_rx

Responsibilities

Future versions may allow

- Debug commands
- Configuration updates
- Diagnostic requests

---

## spi_master

Responsibilities

- Communicate with external sensors
- Read digital temperature devices
- Support future peripheral expansion

---

## led_controller

Responsibilities

Display current operating mode.

Suggested LED assignments

| State | LEDs |
|--------|------|
| ECO | 0001 |
| NORMAL | 0010 |
| BOOST | 0100 |
| PROTECT | 1000 |

Faults may override normal operation.

---

# 6. Data Flow

```
Activity Events
        |
        V
Activity Monitor
        |
        +----------------+
                         |
Temperature Sensor ------+
                         |
                         V
                  State Machine
                         |
        +----------------+---------------+
        |                                |
        V                                V
Power Controller                  PWM Fan Controller
        |                                |
        +---------------+----------------+
                        |
                        V
                 Energy Counter
                        |
                        V
                 UART Telemetry
                        |
                        V
                 LED Controller
```

---

# 7. Clock Strategy

GreenChip uses one synchronous clock domain.

Default clock frequency

```
100 MHz
```

Clock enables are preferred over internally generated clocks to simplify timing closure and reduce clock-domain crossing complexity.

---

# 8. Reset Strategy

The system uses a synchronous active-high reset.

During reset

- State Machine enters NORMAL
- Counters clear
- UART returns idle
- SPI returns idle
- PWM output resets
- LEDs display default state
- Fault outputs clear

---

# 9. Design Philosophy

The GreenChip architecture follows several engineering principles.

- Modular design
- Reusable RTL
- Parameterized modules
- Deterministic behavior
- Vendor independence
- Simple interfaces
- Easy verification
- Scalability

Each module performs one clearly defined function and communicates only through documented interfaces.

---

# 10. Future Expansion

Future versions of GreenChip may include

- AXI-Lite Interface
- Embedded RISC-V Processor
- AI Workload Detection
- Ethernet Communication
- PCIe Interface
- Multiple Thermal Zones
- Multiple Fan Controllers
- Dynamic Voltage Scaling
- Machine Learning Optimization
- Cloud Telemetry Dashboard

---

# 11. Conclusion

The GreenChip architecture provides a modular, reusable FPGA framework for intelligent power and thermal management.

By separating functionality into dedicated SystemVerilog modules connected through well-defined interfaces, the architecture supports efficient verification, future expansion, and professional FPGA engineering practices.