# GreenChip Design Decisions

**Project Name:** GreenChip

**Version:** 1.0

**Author:** A'Yana Leonard

---

# 1. Purpose

This document records the major engineering decisions made during the design and development of GreenChip.

Each decision includes the reasoning behind the choice and, when applicable, alternatives that were considered. Maintaining a design decision log improves maintainability, traceability, and future development.

---

# 2. Design Philosophy

GreenChip was designed around four core engineering principles.

- Modularity
- Reusability
- Deterministic Hardware
- Scalability

Every RTL module performs one specific function and communicates through documented interfaces.

---

# 3. Decision Log

---

## DD-001

### Decision

Use SystemVerilog instead of Verilog.

### Reason

SystemVerilog provides

- Better readability
- Parameterized modules
- Stronger typing
- Improved synthesizable constructs
- Cleaner state machine implementation

### Alternative

Verilog-2001

### Result

SystemVerilog selected.

---

## DD-002

### Decision

Use a single system clock.

### Reason

A single clock domain simplifies

- Timing analysis
- Verification
- Simulation
- FPGA implementation
- Debugging

### Alternative

Multiple clock domains

### Result

Single clock domain selected.

---

## DD-003

### Decision

Prefer clock-enable signals over internally generated clocks.

### Reason

Clock enables reduce

- Clock-domain crossing issues
- Timing complexity
- Routing complexity

### Result

Clock enables selected.

---

## DD-004

### Decision

Implement four operating modes.

Operating Modes

- ECO
- NORMAL
- BOOST
- PROTECT

### Reason

Allows adaptive hardware behavior while remaining easy to verify.

---

## DD-005

### Decision

Use a centralized State Machine.

### Reason

A single controller simplifies

- Debugging
- Verification
- Expansion
- Maintenance

Instead of allowing each module to make independent decisions.

---

## DD-006

### Decision

Implement reusable RTL modules.

### Reason

Each module should be usable in future FPGA projects.

Examples

- UART
- SPI
- PWM
- Clock Divider

---

## DD-007

### Decision

Separate reusable IP from project RTL.

Directory Structure

```
rtl/
```

contains project implementation.

```
ip/
```

contains reusable hardware IP.

---

## DD-008

### Decision

Use parameterized modules.

Examples

- Counter Width
- PWM Resolution
- UART Baud Rate
- SPI Clock Divider
- Clock Frequency
- Temperature Thresholds

### Reason

Improves portability between FPGA boards.

---

## DD-009

### Decision

Use synchronous reset.

### Reason

Provides predictable FPGA behavior and simplifies timing closure.

---

## DD-010

### Decision

Implement PWM cooling instead of simple ON/OFF fan control.

### Reason

PWM allows

- Reduced power consumption
- Better thermal control
- Lower fan noise
- Higher efficiency

---

## DD-011

### Decision

Estimate relative energy instead of measuring actual power.

### Reason

Actual power measurement requires

- Voltage sensing
- Current sensing
- Analog circuitry

Version 1 focuses on digital estimation.

---

## DD-012

### Decision

Represent temperature using an 8-bit unsigned value.

### Reason

Provides sufficient range for simulation while minimizing hardware resources.

---

## DD-013

### Decision

Use UART for telemetry.

### Reason

UART is

- Simple
- Widely supported
- Easy to debug
- Compatible with serial terminals

---

## DD-014

### Decision

Use SPI for sensor communication.

### Reason

SPI is commonly used with

- Temperature sensors
- ADCs
- Digital peripherals

---

## DD-015

### Decision

Use LEDs for quick visual status.

### Reason

Allows immediate debugging without requiring UART.

---

## DD-016

### Decision

Store engineering documentation using Markdown.

### Reason

Markdown

- Works natively on GitHub
- Supports version control
- Easy to read
- Easy to edit

---

## DD-017

### Decision

Use Git for version control.

### Reason

Allows

- Change tracking
- Version history
- Collaboration
- Rollback capability

---

## DD-018

### Decision

Develop every RTL module with a dedicated testbench.

### Reason

Verification should occur before system integration.

---

## DD-019

### Decision

Verify modules independently before connecting them.

### Reason

Smaller simulations make debugging significantly easier.

---

## DD-020

### Decision

Target AMD Vivado while maintaining compatibility with Icarus Verilog where practical.

### Reason

Allows

- Fast simulation
- Professional FPGA synthesis
- Timing analysis
- Bitstream generation

---

# 4. Assumptions

The current design assumes

- One FPGA device
- One primary clock
- Digital temperature input
- One cooling fan
- One UART interface
- One SPI master
- No external processor

---

# 5. Future Design Decisions

Future versions may include

- Embedded RISC-V Processor
- AXI-Lite Bus
- PCIe
- Ethernet
- AI-assisted power prediction
- Dynamic Voltage Scaling
- Multiple Temperature Sensors
- Multiple Fan Controllers
- DDR Memory Interface
- Cloud Telemetry

---

# 6. Engineering Principles

GreenChip follows these engineering principles throughout development.

- Keep modules small.
- Keep interfaces simple.
- Parameterize everything practical.
- Verify before integration.
- Document every major decision.
- Design for reuse.
- Avoid unnecessary complexity.
- Maintain deterministic behavior.

---

# 7. Conclusion

The design decisions documented here establish the engineering philosophy behind GreenChip.

By emphasizing modularity, reuse, verification, and maintainability, GreenChip serves as both a practical FPGA project and a demonstration of professional digital hardware engineering practices.