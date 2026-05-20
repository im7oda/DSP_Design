# 🔷 DSP48A1 Slice Design & Verification — Spartan-6 FPGA

## 📌 Project Overview

This project implements and verifies the **DSP48A1 slice** of the **Xilinx Spartan-6 FPGA** family using **SystemVerilog**. The DSP48A1 is a high-performance arithmetic block optimized for math-intensive DSP applications such as filtering, accumulation, and multiply-add operations.

The project covers the full design flow:
- RTL implementation of the DSP48A1 slice
- Directed & randomized testbench verification in **QuestaSim**
- Synthesis, elaboration, and implementation in **Vivado**
- Static linting with no reported errors

---

## 🧠 DSP48A1 Background

The Spartan-6 family offers a high ratio of DSP48A1 slices to logic fabric, making it well-suited for signal processing workloads. Each DSP48A1 slice includes:

- A **pre-adder/subtracter** on the B/D input path
- An **18×18 multiplier**
- A **48-bit post-adder/subtracter**
- Cascadable **X** and **Z** multiplexers
- Configurable pipeline registers at each stage

---

## 🏗️ Design Parameters (Attributes)

| Parameter | Valid Values | Default | Description |
|-----------|-------------|---------|-------------|
| `A0REG` | 0, 1 | 0 | Pipeline register stage 0 for input A |
| `A1REG` | 0, 1 | 1 | Pipeline register stage 1 for input A |
| `B0REG` | 0, 1 | 0 | Pipeline register stage 0 for input B |
| `B1REG` | 0, 1 | 1 | Pipeline register stage 1 for input B |
| `CREG` | 0, 1 | 1 | Pipeline register for input C |
| `DREG` | 0, 1 | 1 | Pipeline register for input D |
| `MREG` | 0, 1 | 1 | Pipeline register at multiplier output |
| `PREG` | 0, 1 | 1 | Pipeline register at P output |
| `CARRYINREG` | 0, 1 | 1 | Pipeline register for carry-in |
| `CARRYOUTREG` | 0, 1 | 1 | Pipeline register for carry-out |
| `OPMODEREG` | 0, 1 | 1 | Pipeline register for OPMODE input |
| `CARRYINSEL` | `"CARRYIN"`, `"OPMODE5"` | `"OPMODE5"` | Carry-in source selection |
| `B_INPUT` | `"DIRECT"`, `"CASCADE"` | `"DIRECT"` | B port input routing |
| `RSTTYPE` | `"SYNC"`, `"ASYNC"` | `"SYNC"` | Reset type for all registers |

---

## 📡 Port Description

### Data Ports

| Port | Width | Direction | Description |
|------|-------|-----------|-------------|
| `A` | 18-bit | Input | Data input to multiplier / post-adder |
| `B` | 18-bit | Input | Data input to pre-adder or multiplier |
| `C` | 48-bit | Input | Data input to post-adder/subtracter |
| `D` | 18-bit | Input | Data input to pre-adder; D[11:0] concatenated with A and B |
| `CARRYIN` | 1-bit | Input | Carry input to post-adder/subtracter |
| `M` | 36-bit | Output | Buffered multiplier output (registered or direct) |
| `P` | 48-bit | Output | Primary output from post-adder/subtracter |
| `CARRYOUT` | 1-bit | Output | Cascade carry out (connect only to adjacent DSP CARRYIN) |
| `CARRYOUTF` | 1-bit | Output | Copy of CARRYOUT routable to FPGA logic |

### Cascade Ports

| Port | Direction | Description |
|------|-----------|-------------|
| `BCIN` | Input | Cascade input from adjacent DSP48A1 BCOUT |
| `BCOUT` | Output | Cascade output for Port B |
| `PCIN` | Input | Cascade input for Port P |
| `PCOUT` | Output | Cascade output for Port P |

### Control & Clock Ports

| Port | Description |
|------|-------------|
| `CLK` | DSP clock |
| `OPMODE[7:0]` | Selects arithmetic operations dynamically |
| `CEA / CEB / CEC / CED` | Clock enables for A, B, C, D registers |
| `CEM / CEP / CEOPMODE / CECARRYIN` | Clock enables for M, P, OPMODE, CARRY registers |
| `RSTA / RSTB / RSTC / RSTD` | Active-high resets for A, B, C, D registers |
| `RSTM / RSTP / RSTOPMODE / RSTCARRYIN` | Active-high resets for M, P, OPMODE, CARRY registers |

---

## 🔄 OPMODE Control

The 8-bit `OPMODE` port dynamically configures the arithmetic operation performed by the DSP48A1 slice. It controls:

- **X Multiplexer** — selects the first operand for the post-adder
- **Z Multiplexer** — selects the second operand (feedback, cascade, or C input)
- **Pre-adder operation** — add or subtract B from D
- **Carry-in source** — from CARRYIN port or OPMODE[5]
- **Post-adder operation** — add or subtract

---

## 🧪 Verification Approach

### Testbench Strategy
- **Directed test patterns** used to target specific OPMODE configurations and corner cases
- Results verified against **expected values** computed in the testbench
- Additional result checking performed through **waveform inspection**

### Simulation Tool
- **QuestaSim** — driven via a `.do` script for automated simulation flow

### Key Test Cases Covered

| Scenario | Description |
|----------|-------------|
| Multiply only | Verify 18×18 multiplier output (M and P) |
| Multiply-accumulate | P feedback through Z mux |
| Pre-adder (D+B / D−B) | Verify pre-adder/subtracter paths |
| Post-adder/subtracter | Z − (X + CIN) with SUBTRACT enabled |
| C input path | Wide addition using C register |
| Cascade path | BCIN input and PCIN/PCOUT routing |
| Pipeline depth | Verify latency with different register combinations |
| Reset behavior | Sync vs. Async reset for all registers |

---

## 🛠️ Vivado Design Flow

| Step | Details |
|------|---------|
| **Target Part** | `xc7a200tffg1156-3` |
| **Clock Constraint** | 100 MHz on pin `W5` |
| **Elaboration** | No critical warnings or errors |
| **Synthesis** | DSP48A1 block inferred in synthesized schematic |
| **Implementation** | Timing and utilization reports within spec |
| **Linting** | No errors (default methodology and goals) |

---

## 📁 Repository Structure

```
DSP48A1_Project/
├── rtl/
│   └── DSP48A1.sv          # RTL implementation
├── tb/
│   └── DSP48A1_tb.sv       # Testbench
├── sim/
│   └── run.do              # QuestaSim do file
├── constraints/
│   └── timing.xdc          # Timing constraint (100 MHz)
└── README.md
```

---

## 📊 Results Summary

| Metric | Result |
|--------|--------|
| QuestaSim Simulation | ✅ Passed — all directed tests matched expected values |
| Elaboration Messages | ✅ No critical warnings or errors |
| Synthesis Schematic | ✅ DSP48A1 block present |
| Timing (Post-Implementation) | ✅ Timing constraints met at 100 MHz |
| Linting | ✅ No errors reported |

---

## 📚 Reference

- [Xilinx Spartan-6 DSP48A1 Slice User Guide (UG389)](https://docs.amd.com/v/u/en-US/ug389)
