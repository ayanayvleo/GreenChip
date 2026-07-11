# 🌿 GreenChip

> **Energy-Aware FPGA Architecture for Sustainable Embedded Systems**

![SystemVerilog](https://img.shields.io/badge/SystemVerilog-HDL-blue)
![Vivado](https://img.shields.io/badge/Vivado-2026.1-orange)
![FPGA](https://img.shields.io/badge/FPGA-Artix--7-success)
![Status](https://img.shields.io/badge/Status-Bitstream_Generated-brightgreen)

---

<p align="center">

# Building Smarter, More Sustainable Hardware

*A modular FPGA architecture designed to explore intelligent power management through dedicated digital logic.*

</p>

---

<p align="center">
<img src="images/greenchip-rtl-schematic.png" width="600">
</p>

---

# Overview

GreenChip is a research-focused FPGA architecture designed in **SystemVerilog** to demonstrate how dedicated digital hardware can monitor and respond to system activity, communication, and environmental conditions in real time.

Rather than relying solely on software for system management, GreenChip explores a hardware-first approach by integrating sensing, communication, monitoring, and power management directly into programmable logic.

The project was designed, verified, synthesized, implemented, and compiled into a hardware-ready FPGA bitstream using **AMD Vivado 2026.1**.

---

# Architecture

GreenChip is built from modular hardware components that communicate through a centralized control architecture.

### Core Modules

- UART Transmitter
- UART Receiver
- SPI Master
- Temperature Sensor
- Activity Monitor
- Power Controller
- State Machine
- Clock Divider
- PWM Fan Controller
- Energy Counter
- LED Controller

---

# FPGA Implementation

<p align="center">
<img src="images/greenchip-fpga-floorplan.png" width="350">
</p>

After RTL verification, the complete design successfully passed:

- ✅ RTL Simulation
- ✅ Functional Verification
- ✅ Vivado Synthesis
- ✅ Placement
- ✅ Routing
- ✅ Timing Analysis
- ✅ Bitstream Generation

The floorplan above shows the physical placement of GreenChip within the AMD Artix-7 FPGA fabric after implementation.

---

# Development Flow

```text
Research
      │
      ▼
Architecture Design
      │
      ▼
SystemVerilog RTL
      │
      ▼
Module Verification
      │
      ▼
Integration Testing
      │
      ▼
Vivado Synthesis
      │
      ▼
Implementation
      │
      ▼
Timing Analysis
      │
      ▼
Bitstream Generation
```

---

# Engineering Summary

| Category | Result |
|-----------|--------|
| HDL | SystemVerilog |
| FPGA Family | AMD Artix-7 |
| Design Environment | AMD Vivado 2026.1 |
| RTL Modules | 20 |
| Internal Nets | 94 |
| I/O Ports | 30 |
| RTL Simulation | ✅ Passed |
| Synthesis | ✅ Passed |
| Implementation | ✅ Passed |
| Timing | ✅ Passed |
| Bitstream | ✅ Generated |

---

# Verification

Every major subsystem was verified independently before full system integration.

| Component | Status |
|-----------|--------|
| UART | ✅ Pass |
| SPI | ✅ Pass |
| Power Controller | ✅ Pass |
| GreenChip Integration | ✅ Pass |

---

# Repository Structure

```text
GreenChip
│
├── constraints/
├── docs/
├── images/
│   ├── greenchip-rtl-schematic.png
│   └── greenchip-fpga-floorplan.png
│
├── rtl/
│   ├── activity_monitor.sv
│   ├── clock_divider.sv
│   ├── energy_counter.sv
│   ├── fan_pwm.sv
│   ├── greenchip_top.sv
│   ├── led_controller.sv
│   ├── power_controller.sv
│   ├── spi_master.sv
│   ├── state_machine.sv
│   ├── temperature_sensor.sv
│   ├── uart_rx.sv
│   └── uart_tx.sv
│
├── tb/
└── README.md
```

---

# Technology Stack

- SystemVerilog
- AMD Vivado 2026.1
- Icarus Verilog
- GTKWave
- Git
- GitHub

---

# Current Status

🟢 RTL Complete

🟢 Verification Complete

🟢 Synthesis Complete

🟢 FPGA Implementation Complete

🟢 Timing Closure Achieved

🟢 Bitstream Successfully Generated

---

# Future Roadmap

- Hardware validation on a physical AMD Artix-7 FPGA
- Live temperature sensor integration
- External power monitoring
- Dynamic power optimization
- AI-assisted hardware control
- Expanded peripheral support

---

# Author

## A'Yana Leonard

Electrical & Computer Engineering Research

**Interests**

- FPGA Design
- Digital Systems
- Sustainable Computing
- Embedded Systems
- Hardware Architecture
- Green Technology

---

> *GreenChip represents an exploration into how programmable hardware can contribute to more intelligent and energy-aware embedded systems.*
