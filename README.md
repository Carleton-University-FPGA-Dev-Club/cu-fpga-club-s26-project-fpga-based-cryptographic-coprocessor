# FPGA-Based Cryptographic Coprocessor
A hardware accelerated AES-128 encryption module targetting Zynq-7000 SoCs. Comes with a software interface written in C, allowing applications to easily integrate data encryption with a simple function call.

Part of the Carleton University FPGA Summer Club 2026.

## Description
A cryptographic coprocessor is hardware in a larger system that offloads cryptographic operations off the *main CPU*. This helps the *main CPU* focus on other tasks, which improves system responsiveness.

The cryptographic operation for this project is the AES-128 algorithm. Etching the encryption logic into the FPGA has the benefit of reusing hardware modules and parallelizing specific aspects of the algorithm, which leads to a higher throughput compared to a pure-software implementation.

The *main CPU* in our system will be the ARM CPU provided on the Digilent Zybo Z7-20 System-on-Chip (SoC). It runs a demo banking app written in C and when password encryption is required, it is offloaded to the FPGA fabric. When the FPGA finishes executing the AES-128 algorithm, the application resumes with the encrypted data.

This naturally forces the hard cores (ARM - PS) to interact with the soft cores (FPGA - PL). AXI-4 Lite was chosen for this communication due to its simplicity.

> [!WARNING]  
> **You should not use this project's AES implementation officially.** While our implementation passes test vectors mentioned in [FIPS 197](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.197-upd1.pdf), it may contain other vulnerabilities. AES-128 is a U.S. federal government standard, only use trusted implementations if security matters.

## Specification
* **Development Target:** Digilent Zybo Z7-20 FPGA board
* **Hardware Development Environment:** Xilinx Vivado 2023.1 
* **Software Development Environment:** Vitis 2023.1
* **Technologies:** Verilog HDL, AXI-4 Lite Communication Protocol, Git / GitHub 

## Organization
```
├───docs         # Implementation documentation
├───ip           # AES-128 module wrapped as an AXI-4 peripheral
├───rtl          # Verilog source code for AES-128 
├───scripts      # Project build / regeneration scripts
├───sim          # Verilog testbenches for AES-128
└───software     # Coprocessor interface and demo app in C
```

## Build
This project tracks minimal source code files using Git and uses `.tcl` scripts to regenerate Vivado and Vitis projects. This method prevents tracking large binaries and other illegible files.

Clone the repository. Open Vivado, and use the Tcl console to navigate to this project's `scripts` directory and run:
```
source create_vivado_project.tcl
```

This command will initialize the Vivado project. Now, you can use the Flow Navigator on the left to:
1. Run Simulation ► Test #1 and Test #2 should pass (you may need to click `Run For` to give them ample simulation time)
2. Run Synthesis
3. Run Implementation
4. Generate Bitstream
5. File ► Export ► Export Hardware ► Include Bitstream

After the export has generated the `.xsa` file, you can use our [Methodology documentation](https://github.com/Carleton-University-FPGA-Dev-Club/cu-fpga-club-s26-project-fpga-based-cryptographic-coprocessor/blob/main/docs/methodology.md#software-development---vitis) to get started with the Vitis IDE or debug Vivado-related issues.

## Additional Information
For more information, please check out the documentation in the `docs` directory [here](https://github.com/Carleton-University-FPGA-Dev-Club/cu-fpga-club-s26-project-fpga-based-cryptographic-coprocessor/tree/main/docs). 

#### Documentation Quick Links
* [AES](https://github.com/Carleton-University-FPGA-Dev-Club/cu-fpga-club-s26-project-fpga-based-cryptographic-coprocessor/blob/main/docs/aes.md)
* [System Architecture](https://github.com/Carleton-University-FPGA-Dev-Club/cu-fpga-club-s26-project-fpga-based-cryptographic-coprocessor/blob/main/docs/architecture.md)
* [Methodology](https://github.com/Carleton-University-FPGA-Dev-Club/cu-fpga-club-s26-project-fpga-based-cryptographic-coprocessor/blob/main/docs/methodology.md)

#### Future Improvements
* Switch to an interrupt approach, rather than polling to trigger when the FPGA finishes executing AES-128 
* Look into DMA as the communication between PS-PL to scale for higher demand applications 
* Instead of software generating the encryption key, the coprocessor has one pre-installed in a ROM to increase security
* Investigate a pipeline-approach for the AES-128 algorithm to increase throughput, rather than an iterative FSM approach
