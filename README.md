# FIR Filter with Coefficient Selection Module (CSM)

This project implements a parameterizable FIR filter using an efficient coefficient selection method (CSM), optimized for FPGA and ASIC designs. It includes a serial wrapper and a testbench for verification.

---

## 📁 Module Overview

### 1. `csm.v`
Implements coefficient scaling and multiplication via shift-and-add logic using Booth-like encoding.  
Supports signed 17-bit coefficients (`[16:0]`), with the MSB used as a sign bit.  
Computes output using bit-compressed sum (BCS) technique to reduce multiplier complexity.

### 2. `fir_csm.v`
Parameterizable N-tap FIR filter using `csm` modules for each tap.  
Inputs are fed through a shift register, and taps operate in parallel.  
Output is delayed to match pipeline latency.

### 3. `fir_serial_wrapper.v`
Converts serial input to 16-bit parallel samples for the FIR filter and serializes the 32-bit output.  
Useful for interfacing with ADCs or serial buses.

### 4. `fir_tb.v`
Testbench for simulating the FIR filter.  
Loads input from `sin.data`, and logs results in `output.data`.

---

//## 📸 Simulation Waveform

**Add your simulation waveform image below:**

> ![Simulation Waveform](images/simulation_waveform.png)  
> *Figure: Signal transitions for `clk`, `x_in`, `data_valid`, and `y_out` from the testbench.*

---

## 🖼️ Input vs Output Plot

**Include a plotted graph of input and output values:**

> ![Input vs Output Plot](images/input_output_plot.png)  
> *Figure: Plot comparing filter input (`x_in`) and output (`y_out`) over time.*

---

## ▶️ Simulation Instructions

### 1. Prepare Input File
Create a file named `sin.data` with 16-bit signed binary values (1 per line):

```text
0000000000000001
0000000000000010
...
