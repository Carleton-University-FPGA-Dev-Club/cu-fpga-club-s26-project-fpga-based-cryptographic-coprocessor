# Methodology 
This file goes over a step-by-step guide on creating this project and getting it ready for testing on the Digilent Zybo Z7-20 FPGA board. It will also cover some of the concepts behind the design in the appropriate sections.

The project's `README` comes with [build scripts](https://github.com/Carleton-University-FPGA-Dev-Club/cu-fpga-club-s26-project-fpga-based-cryptographic-coprocessor/tree/main#build), which automatically executes the Vivado-related steps below. Feel free to read through if the script fails or if you are curious about the underlying implementation, specific issues, or contexts!

# Hardware Development - Vivado
## Vivado Project Creation

1. In Vivado, click Create Project ► Select Name & Project Location ► Project Type is RTL Project.

> [!NOTE]
> If you are cloning this repository and placing your Vivado project in the same directory, make sure your folder name is less than 80 characters long. Vivado will run into errors during the synthesizing stage if your directory structure exceeds specific character limits. 

2. On the Default Part screen, select `Boards` and search for `Zybo Z7-20`. You may have to refresh your catalog for the option to show up. You may have to click on the Download button to be able to select it. 
<img width="959" height="563" alt="image" src="https://github.com/user-attachments/assets/eebbf249-767b-482e-8e34-cc0e71cd3951" />

*Figure 1: Vivado Default Part Selection*

## Vivado Sources 
1. In the `Sources` tab, use the `Add Sources` button and select `Add Design Sources` ► `Add or create design sources`. This is where our Verilog source code files for the AES-128 module will go. 

<img width="959" height="564" alt="image" src="https://github.com/user-attachments/assets/874e56c1-ef0c-493f-97f6-c3fd21d1ba9c" />

*Figure 2: Vivado Project Screen*

2. Click on `Add Files` and select all the source files from this repository's `rtl` folder. If your project directory is different from your Git repository, then you can check `Copy sources into project`. Click `Finish`.

<img width="959" height="563" alt="image" src="https://github.com/user-attachments/assets/65ae13bc-272b-43f6-9daa-cb39b08a2641" />

*Figure 3: Adding Vivado Design Sources*

3. Steps 1-2 can also be used to add simulation sources (i.e. testbenches). After clicking `Add Design Sources` ► `Add or create simulation sources`. Then, select all the files from this repository's `sim` folder. All of the testbenches end in `_tb.v`

## Vivado Simulation
1. Ensure that Vivado set the compilation order properly for both design sources and simulation sources. `aes.v` and `aes_tb.v` should be the top-level sources, respectively.
2. Using the Flow Navigator on the left, click `Run Simulation`.
3. Observing the outputs, near the end when the `ready` flag is high, we can see that the `ciphertext` is equal to the `expected_ciphertext`. Expanding the TCL console will show a message such as "Test case #1 passed" and "Test case #2 passed".

> [!NOTE]
> You may have to click the `Run For` button, near the `20000 ns` UI box in Figure 4. This is because multiple simulations exceed the default behaviour where simulations stop at 1000ns, which is not necessarily when the AES module finishes.

<img width="959" height="564" alt="image" src="https://github.com/user-attachments/assets/dc6b2349-3586-4361-93b7-6767caf5a1a8" />

*Figure 4: Vivado Testbench Simulation*

## Vivado IP
Now, we are ready to wrap our AES-128 module as a custom intellectual property (IP). More specifically, it will be AXI-4 peripheral...but why?

### PS-PL Communication
The goal of this project is for an application running on the processing system (PS) to offload an encryption algorithm to the programmable logic (PL). As seen in Figure 5, the connection between these two components is provided by the AMBA bus. More specifically, data transfer happens in accordance with the AXI protocol, for which there are two dedicated ports (General-Ports & High-Performance Ports). 

This leads to quite a few choices about how the communication should happen. AXI itself has three flavours, namely AXI-4 Lite, AXI-4 Full, and AXI-4 Stream. A Direct Memory Access (DMA) engine could also be set up to allow for maximum efficiency within the processing system. Ultimately, AXI-4 Lite was chosen due to its simplicity and project demonstration needs, as it works exactly like memory-mapped I/O.

<img width="795" height="870" alt="image" src="https://github.com/user-attachments/assets/c633fcd1-92a9-4c5e-b982-272bcdd66fb6" />

*Figure 5: Zybo Z7-20 Board Block Diagram*

Memory-mapped I/O is essentially giving the CPU an address, which it believes it will use to read from or write to main memory. The trick is however, the address and data bus stretch beyond the main memory. They can go to any I/O device, and the CPU can communicate with them by using its native `LOAD` and `STORE` instructions.  

Our synthesized AES-128 module will be treated exactly like an I/O device from Figure 6. For example, each register that is synthesized in the PL, will be given a unique address that the PS can access.

Note that following Figure 6, the processing system (PS) is the master device and the programmable logic (PL) is the slave device. Data never flows from the PL ► PS. Instead, PS invokes functions within the PL and reads from its registers.

<img width="628" height="247" alt="image" src="https://github.com/user-attachments/assets/ae2fcd88-7693-4623-a276-b074a973fca7" />

*Figure 6: Memory Mapped I/O*

### Vivado Implementation
1. From the top menu, select `Tools` ► `Create and Package New IP...`
2. Click `Next` ► `Create a new AXI4 Peripheral`  
  a. What we called **I/O** in the previous section, Vivado calls a **Peripheral**

<img width="959" height="563" alt="image" src="https://github.com/user-attachments/assets/ddfec79e-bb91-4363-a428-76e7a5876de9" />

*Figure 7: Creating a new AXI4 Peripheral*

3. Feel free to give the IP a descriptive name and description. Vivado will create a new folder `ip_repo` where it will keep your custom peripherals.
4. Please note the following settings:

* **Interface Type:** AXI-4 Lite
* **Mode:** Slave (As discussed in [PS-PL Communication](#ps-pl-communication))
* **Data Width:** 32-bits
* **Number of Registers:** 16

> [!NOTE]
> 16 registers are required to work around the limitation of the 32-bit data width. Since our plaintext, key, and ciphertext registers hold 128-bit data, they each need to be chunked into 4x 32-bit registers. For the full register map, please check our [Architecture](https://github.com/Carleton-University-FPGA-Dev-Club/cu-fpga-club-s26-project-fpga-based-cryptographic-coprocessor/blob/main/docs/architecture.md#register-map) documentation.

<img width="959" height="563" alt="image" src="https://github.com/user-attachments/assets/45f4c076-c974-46ec-82ad-a3b580d8d12f" />

*Figure 8: AXI-4 Peripheral Settings*

5. After clicking `Next` ► `Edit IP`, Vivado will open the IP packager which we need to edit. 

### The PS-PL Link
1. The IP packager has a very similar interface to the Vivado project manager. Since I named my IP `coprocessor_build`, I have the following design sources:  `coprocessor_build_v1_0.v` and `coprocessor_build_v1_0_S00_AXI.v`. 
2. To explicitly connect our AES-128 peripheral and the processing system according to our register map, we need to edit `coprocessor_build_v1_0_S00_AXI.v`.
<img width="959" height="563" alt="image" src="https://github.com/user-attachments/assets/da68bda3-0d83-4f71-ba8c-8295977df351" />

*Figure 9: Vivado IP Packager*

3. You can take a look at the files and they are essentially an implementation of the AXI-4 Lite protocol. Utilizing AXI-4 Lite in this manner enables IP reuse, because as part of the design process, we are only concerned with *what* data we send, not *how* we send it.
4. Scroll down to the bottom of the file where it mentions `Add user logic here` and instantiate our AES-128 module.

> [!NOTE]
> This instantiation is in accordance with our [Register Map](https://github.com/Carleton-University-FPGA-Dev-Club/cu-fpga-club-s26-project-fpga-based-cryptographic-coprocessor/blob/main/docs/architecture.md#register-map). For example, the processing system will send the plaintext chunked into 4x 32-bit registers, but for our AES-128 module, it will be concatenated into a 128-bit value.

<img width="959" height="563" alt="image" src="https://github.com/user-attachments/assets/767beb8c-725b-4d83-aee3-e746118d312f" />

*Figure 9: Linking our AES Module Ports to the Memory-Mapped Registers*

5. *But...where are `ciphertext` and `ready` defined?* Since these two outputs are registers in the AES-128 module, these values will be driven onto a *net* when they are instantiated. Scrolling a bit up in the file, we can see where the AXI-4 Lite latches onto the outputs, which we can edit for our use case.
6. Note that the resultant file is similar to `hdl` in the [IP directory](https://github.com/Carleton-University-FPGA-Dev-Club/cu-fpga-club-s26-project-fpga-based-cryptographic-coprocessor/blob/main/ip/coprocessor_ip_1_0/hdl/coprocessor_ip_v1_0_S00_AXI.v) of this repository.

<img width="959" height="563" alt="image" src="https://github.com/user-attachments/assets/6e64f4bd-6fbc-4f1d-b60d-5d344aef7236" />

*Figure 10: Linking our AES Module Outputs*

> [!IMPORTANT]
> Since we instantiated the AES-128 module in the IP packager, we need to add all the source code files as `Design sources`. It follows the same steps as mentioned in [Vivado Sources](#vivado-sources).

7. Now we are ready to package the IP. In `File Groups`, click `Merge changes from File Group Wizard`. In `Review and Package`, click `Re-package IP`. Once finished, you can close the IP packager when the prompt shows up.

<img width="959" height="564" alt="image" src="https://github.com/user-attachments/assets/01f2f463-ef58-4159-a0fb-50651920049d" />

*Figure 11: Packaging our IP*

## Block Design
Now we are ready to integrate all our required IPs into a block design. Block designs in Vivado provide a graphical environment to visualize and connect different hardware subsystems. For this project, it allows us to connect the processing system (PS) with the AES-128 module (PL), which we just packaged an IP for.

1. Click `Create Block Design` in the Flow Navigator. 
2. Feel free to change the design name, and keep other settings default.

<img width="959" height="564" alt="image" src="https://github.com/user-attachments/assets/41eaa057-aa69-4130-9f77-589729a394db" />

*Figure 12: Creating a Block Design*

3. Click `+` ► Search for `ZYNQ7 Processing System` ► Click `Run Block Automation`

<img width="1918" height="1126" alt="image" src="https://github.com/user-attachments/assets/f40f0402-f04a-439c-87a8-8f1ebb0a0a01" />

*Figure 13: Adding the Processing System (PS) to the Block Design*

4. Next, add the custom AES-128 IP to the block design by searching for the name you declared it with.
<img width="959" height="563" alt="image" src="https://github.com/user-attachments/assets/57e056ee-f51c-405d-8ea2-38cc56f48b13" />

*Figure 14: Adding the AES-128 IP to the Block Design*

5. Click `Run Connection Automation`. This will invoke the required AXI-4 Lite IP blocks and automatically make the required connections.
6. You can `Regenerate Layout` to end up with a more organized design. You should also `Validate Design` with the checkbox icon to ensure there are no errors. You may get a few *Clock Skew* errors but they are fine - it is mostly because we did not provide constraints for our board.

<img width="959" height="564" alt="image" src="https://github.com/user-attachments/assets/56c4c998-0482-4c8f-90df-d8a3661d55bb" />

*Figure 15: Connected Block Design*

7. To make sure the PS-PL communication will work as intended, double click the `ZYNQ7 Processing System`. Under `PS-PL Configuration` ► `AXI Non Secure Enhancement` ► `GP Master AXI Interface` ► Check `M AXI GP 0 interface` if it is not checked already.

<img width="959" height="564" alt="image" src="https://github.com/user-attachments/assets/dc7ea11b-8b33-4f9f-bf09-31578e12745c" />

*Figure 16: Ensuring M_AXI_GP_0 Checked (PS is the Master Device)*

## Exporting Hardware
With a functional block design, we are almost ready to export our hardware and work on the `Coprocessor Interface` and `Application` layers in the Vitis IDE. Instead of having to write Verilog that bridges the block design and the AES-128 module, Vivado can generate an HDL wrapper automatically. This wrapper instantiates all of the components present in our block design and describes the connections between them.

1. Find your block design in `Sources` ► Right Click ► `Create HDL Wrapper...` ► `Let Vivado manage wrapper and auto-update`
2. On the wrapper that is generated ► Right Click ► `Set as Top`

<img width="1918" height="1128" alt="image" src="https://github.com/user-attachments/assets/2d274a94-eceb-4954-9b53-a835a007e692" />

*Figure 17: Creating an HDL Wrapper from Block Design*

3. With the new design wrapper set as the top-level module, we can use the Flow Navigator to:  
  a. **Run Synthesis**  
  b. **Run Implementation**  
  c. **Generate Bitstream**  
4. In the top menu, select `File` ► `Export` ► `Export Hardware...` ► `Include Bitstream`
5. Choose a name and location for the export, and find the `.xsa` file on your computer. 

The `.xsa` file will be used by Vitis IDE to identify the platform we are programming for. It contains a description of the entire hardware specification that the software developers will need to know. For instance, it describes the IP blocks from our block design, the memory map that was linked in the IP packager, and the bitstream data that will be used to program the FPGA fabric.

# Software Development - Vitis

## Vitis Platform
1. Open Vitis and on the landing page, click `Create Platform Project` ► `Create a new platform from hardware (XSA)`
2. Navigate to the directory where your Vivado-generated `.xsa` file is stored and select it. 
3. Leave other defaults, especially `standalone` as this is a bare-metal project and no operating systems are involved. Click `Finish`.
<img width="959" height="563" alt="image" src="https://github.com/user-attachments/assets/ca7eaea6-3703-4595-8185-7174cc6c2d97" />

*Figure 1: Create Platform Project on Vitis Landing Page*

2. On the Vitis project page, click the hammer icon to `Build` the platform.
<img width="959" height="563" alt="image" src="https://github.com/user-attachments/assets/5cbe3f00-84ff-48a0-a16b-d947c097a67e" />

*Figure 2: Building the Platform (i.e. Hardware)*

> [!IMPORTANT]
> You may see errors such as the following when building the platform. These are caused by faulty Makefiles inside the platform files.  
> ```cc1.exe: fatal error: *.c: Invalid argument```  
> 
> You need to edit the following two files, pay attention to your **xsa filename**:
> 1. ```/zynq_fsbl/zynq_fsbl_bsp/ps7_cortexa9_0/libsrc/<xsa filename>/src/Makefile```     
> 2. ```/ps7_cortexa9_0/standalone_domain/bsp/ps7_cortexa9_0/libsrc/<xsa filename>/src/Makefile```   
> 
> Find `OUTS = *.o` in both Makefiles.  
> Replace it with `OUTS = $(addsuffix .o, $(basename $(wildcard *.c)))`.  
>
> Find `LIBSOURCES=*.c` in both Makefiles.  
> Replace it with `LIBSOURCES=$(wildcard *.c)`.  
> Re-build the platform.

3. Next, click `File` ► `New` ► `Application Project...` ► Select the `coprocessor` platform built above.
<img width="959" height="563" alt="image" src="https://github.com/user-attachments/assets/f1f9c47a-5b95-4173-b18f-5d3fcfa99b27" />

*Figure 3: Creating an Application Project*

4. Give the application a name, leave all else as default, and select the `Hello World` template when prompted.
5. In the `src` subdirectory, you can add all the `.c` files present in the `software` folder of this repository. This can be done by right clicking `src` ► `New` ► `file`.

<img width="959" height="563" alt="image" src="https://github.com/user-attachments/assets/cd562f7b-4e7f-47ae-96ad-f0258e0b523f" />

*Figure 4: Coprocessor Application Created*

6. From the top menu, select `Window` ► `Show view...`  ► `Vitis` ► `Vitis Serial Terminal`
7. Connect the Digilent Zybo Z7-20 FPGA board to your computer using the USB cable.
8. Using the `+` button in the Vitis Serial Terminal ► Select `COM Port` (the number may vary) ► Click `OK`

<img width="959" height="563" alt="image" src="https://github.com/user-attachments/assets/3a127530-e170-4ca5-b5b6-541a6450b66b" />

*Figure 5: Source Files Added (See Explorer Tab on the Left), FPGA Board Connected via COM Port*

9. Click the hammer icon again to build the application.
10. In the `Explorer` on the left ► Right click on `<application name> [standalone on ps7_cortex9_0]` ► `Run As` ► `1 Launch Hardware (Single Application Debug)`

<img width="959" height="563" alt="image" src="https://github.com/user-attachments/assets/b743d71f-80ec-4a2b-a8f4-819d5b1014cc" />

*Figure 6: Running the Application*

11. Interact with the bank application in the Vitis Terminal, enjoy!

> [!NOTE]
> Once you exit the application, you can press the `PS-SRST` button on the FPGA board before starting over again. If you get errors when clicking `Run As`, you may want to head into the `Debug` tab (top right corner of Vitis) and press the `Disconnect` icon to stop the existing debug session and then try again.

## Resources
This implementation was inspired from several resources and projects, which you can check out here:

1. Implementation of Hardware Accelerators on Zynq: https://backend.orbit.dtu.dk/ws/portalfiles/portal/125849853/tr16_07_Nannarelli_A.pdf.   
  a. The `Monte Carlo processor` implementation covers register maps and block designs.  
  b. Power, area, and performance metrics are also covered.  
2. Zynq Training - Creating a simple Axi-Lite accelerator #02: https://www.youtube.com/watch?v=_F124UaZ-d0.     
  a. Walks through PS-PL interaction for a simple multiplier module.
