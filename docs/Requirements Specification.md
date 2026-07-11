# GreenChip Requirements Specification

## 1. Document Purpose

This document defines the functional, performance, interface, verification, and quality requirements for the GreenChip FPGA-based adaptive power and thermal-management system.

## 2. Requirement Language

The word **shall** identifies a mandatory requirement.

The word **should** identifies a recommended design goal.

The word **may** identifies an optional feature.

## 3. System-Level Requirements

| ID | Requirement |
|---|---|
| SYS-001 | GreenChip shall be implemented as synthesizable SystemVerilog RTL. |
| SYS-002 | GreenChip shall use a modular architecture. |
| SYS-003 | GreenChip shall provide a single top-level integration module. |
| SYS-004 | GreenChip shall operate from a primary system clock. |
| SYS-005 | GreenChip shall support a synchronous reset strategy. |
| SYS-006 | GreenChip shall monitor system activity. |
| SYS-007 | GreenChip shall monitor temperature data. |
| SYS-008 | GreenChip shall control a PWM cooling output. |
| SYS-009 | GreenChip shall control system power-state outputs. |
| SYS-010 | GreenChip shall estimate accumulated energy use. |
| SYS-011 | GreenChip shall provide LED-based status indication. |
| SYS-012 | GreenChip shall provide UART telemetry output. |
| SYS-013 | GreenChip shall include an SPI master interface. |
| SYS-014 | GreenChip shall detect and report fault conditions. |
| SYS-015 | GreenChip shall support simulation without physical sensors. |

## 4. Clock and Reset Requirements

| ID | Requirement |
|---|---|
| CLK-001 | The default system clock frequency shall be 100 MHz. |
| CLK-002 | Clock-frequency values shall be parameterized where practical. |
| CLK-003 | Derived timing enables should be generated without unnecessary internal clock domains. |
| CLK-004 | The clock-divider module shall produce a deterministic divided output or pulse. |
| RST-001 | All stateful modules shall respond to reset. |
| RST-002 | Reset shall place the system in a defined safe state. |
| RST-003 | The default safe operating state shall be NORMAL unless a thermal fault is present. |
| RST-004 | Energy and activity counters shall clear during reset. |
| RST-005 | The PWM output shall return to a defined value during reset. |

## 5. Activity-Monitor Requirements

| ID | Requirement |
|---|---|
| ACT-001 | The activity monitor shall accept an activity-event input. |
| ACT-002 | The activity monitor shall count activity events during a configurable observation window. |
| ACT-003 | The observation-window length shall be parameterized. |
| ACT-004 | The activity monitor shall produce an activity-count output. |
| ACT-005 | The activity monitor shall classify activity as idle when activity remains below the idle threshold. |
| ACT-006 | The activity monitor shall classify activity as high when activity exceeds the high-activity threshold. |
| ACT-007 | Threshold values shall be parameterized. |
| ACT-008 | Activity classification shall update at the end of each observation window. |
| ACT-009 | Counter overflow shall be prevented or handled safely. |

## 6. Temperature-Monitor Requirements

| ID | Requirement |
|---|---|
| TMP-001 | The system shall accept temperature data in digital form. |
| TMP-002 | The initial design shall represent temperature as an unsigned integer in degrees Celsius. |
| TMP-003 | The temperature-monitor module shall store the most recent valid sample. |
| TMP-004 | The module shall provide a sample-valid output or equivalent status. |
| TMP-005 | The module shall compare temperature against configurable thresholds. |
| TMP-006 | The module shall identify warm, hot, and critical conditions. |
| TMP-007 | The default warm threshold shall be 50 degrees Celsius. |
| TMP-008 | The default hot threshold shall be 70 degrees Celsius. |
| TMP-009 | The default critical threshold shall be 85 degrees Celsius. |
| TMP-010 | A critical temperature shall override normal power-optimization behavior. |

## 7. Power-Control Requirements

| ID | Requirement |
|---|---|
| PWR-001 | The system shall support NORMAL, ECO, BOOST, and PROTECT operating states. |
| PWR-002 | NORMAL shall represent standard system operation. |
| PWR-003 | ECO shall represent reduced-power operation. |
| PWR-004 | BOOST shall represent high-performance operation. |
| PWR-005 | PROTECT shall represent a thermally protective operating state. |
| PWR-006 | The power controller shall receive activity and thermal classifications. |
| PWR-007 | The power controller shall enter ECO after a configurable sustained-idle interval. |
| PWR-008 | The power controller shall enter BOOST during high activity when temperature is below the hot threshold. |
| PWR-009 | The power controller shall enter PROTECT when temperature is critical. |
| PWR-010 | PROTECT shall have the highest transition priority. |
| PWR-011 | The controller shall leave PROTECT only after temperature falls below a recovery threshold. |
| PWR-012 | The recovery threshold shall include hysteresis. |
| PWR-013 | A wake event shall cause the controller to leave ECO. |
| PWR-014 | State outputs shall be registered. |
| PWR-015 | State transitions shall be deterministic. |

## 8. Cooling-Control Requirements

| ID | Requirement |
|---|---|
| FAN-001 | The fan controller shall generate a PWM output. |
| FAN-002 | PWM resolution shall be parameterized. |
| FAN-003 | Fan duty cycle shall increase with temperature. |
| FAN-004 | Fan duty cycle may also increase during BOOST operation. |
| FAN-005 | The fan shall operate at maximum duty cycle during PROTECT. |
| FAN-006 | The PWM duty-cycle input shall support values from zero through the configured maximum. |
| FAN-007 | The PWM output shall be deterministic after reset. |
| FAN-008 | The design shall avoid combinational glitches on the PWM output. |

## 9. Energy-Estimation Requirements

| ID | Requirement |
|---|---|
| ENG-001 | The energy counter shall accumulate estimated energy units over time. |
| ENG-002 | The accumulated value shall be based on the active operating state. |
| ENG-003 | Each operating state shall have a configurable energy-rate value. |
| ENG-004 | ECO shall use a lower energy rate than NORMAL. |
| ENG-005 | BOOST shall use a higher energy rate than NORMAL. |
| ENG-006 | PROTECT shall use a defined emergency energy rate. |
| ENG-007 | The accumulator width shall be parameterized. |
| ENG-008 | Energy accumulation shall occur on a configurable timing enable. |
| ENG-009 | Overflow behavior shall be documented. |
| ENG-010 | The initial version may use estimated units rather than calibrated joules. |

## 10. UART Requirements

| ID | Requirement |
|---|---|
| UART-001 | GreenChip shall provide UART transmit capability. |
| UART-002 | GreenChip shall provide UART receive capability. |
| UART-003 | The default UART baud rate shall be 115200 baud. |
| UART-004 | UART framing shall use eight data bits, no parity, and one stop bit. |
| UART-005 | UART timing shall be derived from the configured system clock. |
| UART-006 | The transmitter shall provide a busy indicator. |
| UART-007 | The transmitter shall accept a valid or start input. |
| UART-008 | The receiver shall provide a data-valid indication. |
| UART-009 | The receiver shall detect the start bit near its center. |
| UART-010 | Received bytes shall be presented as eight-bit data. |
| UART-011 | Invalid stop-bit behavior shall be documented. |
| UART-012 | Telemetry shall include operating state, temperature, activity, and fault status. |

## 11. SPI Requirements

| ID | Requirement |
|---|---|
| SPI-001 | The design shall include an SPI master module. |
| SPI-002 | SPI clock frequency shall be configurable. |
| SPI-003 | The module shall generate chip-select, serial-clock, and MOSI signals. |
| SPI-004 | The module shall receive MISO data. |
| SPI-005 | The initial implementation shall support eight-bit transfers. |
| SPI-006 | The module shall provide a transaction-start input. |
| SPI-007 | The module shall provide busy and done indications. |
| SPI-008 | Clock polarity and phase shall be configurable or explicitly documented. |
| SPI-009 | Chip select shall remain active for the full transaction. |
| SPI-010 | The SPI module shall return received data after a completed transaction. |

## 12. LED Requirements

| ID | Requirement |
|---|---|
| LED-001 | The LED controller shall display the active operating state. |
| LED-002 | ECO, NORMAL, BOOST, and PROTECT shall have distinguishable patterns. |
| LED-003 | Fault status shall override normal status indication when required. |
| LED-004 | The number of LEDs shall be parameterized where practical. |
| LED-005 | LED outputs shall be registered or combinationally stable. |

## 13. Fault-Handling Requirements

| ID | Requirement |
|---|---|
| FLT-001 | GreenChip shall identify critical-temperature conditions. |
| FLT-002 | GreenChip shall identify invalid or missing temperature samples when implemented. |
| FLT-003 | GreenChip shall provide a consolidated fault output. |
| FLT-004 | Critical faults shall force the system into a safe operating state. |
| FLT-005 | Fault status shall be available to UART telemetry. |
| FLT-006 | Fault conditions shall be testable in simulation. |

## 14. Verification Requirements

| ID | Requirement |
|---|---|
| VER-001 | Every major RTL module shall be compiled independently or as part of an appropriate testbench. |
| VER-002 | The clock-divider module shall have a dedicated testbench. |
| VER-003 | The UART modules shall have a dedicated testbench. |
| VER-004 | The SPI module shall have a dedicated testbench. |
| VER-005 | The power controller shall have a dedicated testbench. |
| VER-006 | The top-level GreenChip system shall have an integration testbench. |
| VER-007 | Testbenches shall include reset testing. |
| VER-008 | Testbenches shall include nominal operating conditions. |
| VER-009 | Testbenches shall include boundary conditions. |
| VER-010 | Testbenches shall include abnormal or fault conditions. |
| VER-011 | Testbenches shall report pass or fail results. |
| VER-012 | Simulation waveforms shall be generated for selected test cases. |
| VER-013 | Verification results shall be documented. |
| VER-014 | Fixed defects shall be covered by regression testing. |

## 15. Quality Requirements

| ID | Requirement |
|---|---|
| QLT-001 | RTL shall use consistent naming conventions. |
| QLT-002 | Module interfaces shall be documented. |
| QLT-003 | Parameters shall be used for reusable configuration values. |
| QLT-004 | Unexplained magic numbers shall be avoided. |
| QLT-005 | Latches shall not be intentionally inferred. |
| QLT-006 | Multiple drivers shall not be created. |
| QLT-007 | Clock-domain crossings shall be avoided in the initial version. |
| QLT-008 | Generated files shall remain outside the RTL directory. |
| QLT-009 | Source files shall be maintained under Git version control. |
| QLT-010 | Major development milestones shall use descriptive Git commits. |

## 16. Performance Goals

| ID | Goal |
|---|---|
| PERF-001 | The design should meet timing at a 100 MHz system clock on the selected target FPGA. |
| PERF-002 | Critical thermal response should begin within one system-clock cycle after a valid critical-temperature classification. |
| PERF-003 | Wake-up from ECO should begin within one system-clock cycle after a valid wake event. |
| PERF-004 | UART communication should operate at 115200 baud with the default clock configuration. |
| PERF-005 | PWM output should provide at least eight bits of duty-cycle resolution. |

## 17. Resource Goals

The project should remain small enough for an entry-level development board.

Initial resource goals:

- Fewer than 5,000 lookup tables
- Fewer than 5,000 flip-flops
- No mandatory DSP blocks
- No mandatory block RAM
- One primary clock
- No high-speed transceivers required

## 18. Traceability

Each RTL module shall trace to one or more requirement groups:

| Module | Primary Requirement Groups |
|---|---|
| clock_divider.sv | CLK |
| activity_monitor.sv | ACT |
| temperature_sensor.sv | TMP |
| state_machine.sv | PWR |
| power_controller.sv | PWR, FLT |
| fan_pwm.sv | FAN |
| energy_counter.sv | ENG |
| uart_tx.sv | UART |
| uart_rx.sv | UART |
| spi_master.sv | SPI |
| led_controller.sv | LED, FLT |
| greenchip_top.sv | SYS, integration requirements |
