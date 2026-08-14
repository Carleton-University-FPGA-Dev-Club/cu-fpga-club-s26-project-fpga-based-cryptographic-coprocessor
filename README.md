# FPGA-Based Cryptographic Coprocessor
A cryptographic coprocessor is hardware in a larger system that offloads cryptographic
operations off the main CPU. This helps the main CPU focus on other tasks, which improves system responsiveness.

The cryptographic operation for this project is the AES-128 algorithm. Executing it on an FPGA also means the 10 required rounds can execute in parallel and thus are faster compared to a pure software implementation.

The "main CPU" in our case will be the ARM CPU provided on the Zybo Z7-20 SoC. It will be running an application written in C (e.g. banking) and whenever the application needs to encrypt data, it will be offloaded to the FPGA fabric. When the FPGA finishes executing AES-128, the application can resume with the encrypted data.

This naturally forces us to have the hard cores (ARM - PS) interact with the soft cores (FPGA - PL) and vice-versa! AXI-4 (Lite) was chosen for this communication due to its simplicity. Technical documentation: [Creating a New AXI4 Peripheral](https://docs.amd.com/r/en-US/ug1118-vivado-creating-packaging-custom-ip/Creating-a-New-AXI4-Peripheral).


### To-do
*(Keeping this here temporarily)*
- [ ] Build instructions for working on it locally
   - ***Needs testing for Vivado, need to look into a script for Vitis***
- [x] AES probably has loads of bugs at the moment - write test benches to make sure the individual AES steps & the process as a whole is correct (test vectors from NIST)
   - ***Under possible rework / improvements from teammates***
- [x] Block diagrams / IP for PL-PS communication
    - [x] Decide on communication method between PS & PL
- [ ] The "main CPU" application (Vitis IDE, looking to put it in the `software/` folder)
   - ***Coprocessor code is there, needs testing. Still need a demo application***
- [ ] Documentation, detailed README, diagrams would be really nice for the FSM, architecture
