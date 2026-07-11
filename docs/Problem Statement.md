# GreenChip Problem Statement

**Project Name:** GreenChip

**Version:** 1.0

**Author:** A'Yana Leonard

**Repository:** GreenChip

---

# 1. Introduction

GreenChip is an FPGA-based adaptive power and thermal management controller designed to intelligently monitor digital system activity, estimate energy usage, monitor thermal conditions, and dynamically adjust operating modes in real time.

Unlike software-based power management, GreenChip performs these decisions directly in programmable hardware, allowing deterministic responses with minimal latency.

The project serves as a complete FPGA engineering portfolio demonstrating the full digital design lifecycle, from requirements analysis through RTL implementation, verification, debugging, and documentation.

---

# 2. Background

Modern digital systems—including servers, embedded devices, edge-computing platforms, and data-center hardware—often consume more power than necessary because hardware components continue operating at full performance even during periods of low activity.

Excessive power consumption increases:

- Electrical costs
- Heat generation
- Cooling requirements
- Hardware wear
- Environmental impact

Although operating systems provide software power management, software introduces scheduling delays and depends on processor availability. Hardware-based monitoring can respond immediately at the clock-cycle level.

---

# 3. Problem Statement

Many embedded systems lack an intelligent hardware controller capable of continuously evaluating system activity and thermal conditions while automatically selecting an appropriate operating mode.

Without dedicated hardware power management, systems may:

- Continue running at full power during idle periods
- Waste energy through unnecessary processing
- Generate excessive heat
- Increase cooling demands
- Reduce long-term hardware reliability
- Delay responses to changing workloads

There is a need for a reusable FPGA-based controller capable of making these decisions independently of software.

---

# 4. Proposed Solution

GreenChip provides an adaptive hardware controller that continuously evaluates system conditions and dynamically selects one of four operating modes:

- ECO
- NORMAL
- BOOST
- PROTECT

The controller performs the following functions:

- Monitors digital activity
- Receives temperature measurements
- Detects idle and high-load conditions
- Estimates cumulative energy usage
- Controls PWM cooling outputs
- Reports system status over UART
- Indicates operating state using LEDs
- Supports future sensor expansion through SPI

All functionality is implemented using synthesizable SystemVerilog.

---

# 5. Project Objectives

The primary objectives of GreenChip are:

- Demonstrate professional FPGA engineering practices
- Develop modular and reusable SystemVerilog IP
- Design deterministic hardware state machines
- Reduce unnecessary power consumption
- Improve thermal management
- Produce complete engineering documentation
- Create reusable verification environments
- Demonstrate debugging and root-cause analysis
- Build a portfolio-quality FPGA project

---

# 6. Intended Applications

GreenChip is designed as a research and educational platform but represents technology applicable to:

- Data centers
- Edge computing
- Industrial automation
- Embedded systems
- Robotics
- Smart manufacturing
- FPGA development boards
- Sustainable computing research

---

# 7. Project Scope

### Included

- SystemVerilog RTL
- Power-state controller
- Activity monitor
- Temperature monitor
- PWM fan controller
- UART communication
- SPI master
- Energy counter
- LED controller
- Top-level integration
- Testbenches
- Simulation
- Verification
- Engineering documentation

### Excluded (Version 1)

- ASIC fabrication
- Analog circuitry
- Machine-learning inference
- Cloud dashboards
- Physical temperature sensors
- Commercial certification

---

# 8. Success Criteria

The GreenChip project will be considered successful when:

- All RTL modules compile successfully.
- Every module passes simulation.
- State transitions operate correctly.
- PWM output responds appropriately to temperature.
- UART communication functions correctly.
- SPI communication functions correctly.
- Energy estimation operates correctly.
- Verification reports are completed.
- Engineering documentation is finalized.
- The project demonstrates professional FPGA engineering practices.

---

# 9. Expected Deliverables

The completed project will include:

- Engineering documentation
- Modular RTL source code
- Simulation testbenches
- Verification reports
- Timing reports
- Utilization reports
- Debug documentation
- Architecture diagrams
- Waveform captures
- Git revision history

---

# 10. Conclusion

GreenChip demonstrates the complete FPGA development lifecycle through the design of a modular adaptive power and thermal management controller. The project combines hardware monitoring, intelligent state management, communication interfaces, reusable IP development, verification planning, and engineering documentation into a professional engineering portfolio suitable for demonstrating FPGA design capabilities.