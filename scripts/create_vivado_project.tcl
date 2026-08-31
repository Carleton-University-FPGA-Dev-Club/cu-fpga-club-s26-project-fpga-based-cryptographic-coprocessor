#*******************************************************************************
# Minimal project-recreation script for "cryptographic_coprocessor"
# Target: Digilent Zybo Z7-20 (xc7z020clg400-1), Vivado 2023.1
#
# Trimmed from Vivado's auto-exported system.tcl: dashboard gadgets, report
# configs, and cosmetic project properties removed. PS7 configuration now
# comes from apply_board_preset instead of a hardcoded PCW_* property dict.
#*******************************************************************************

set origin_dir "./.."
if { [info exists ::origin_dir_loc] } {
  set origin_dir $::origin_dir_loc
}

set _xil_proj_name_ "coprocessor"
if { [info exists ::user_project_name] } {
  set _xil_proj_name_ $::user_project_name
}

# --------------------
# Project Creation
# --------------------
create_project ${_xil_proj_name_} ./${_xil_proj_name_} -part xc7z020clg400-1
set_property board_part digilentinc.com:zybo-z7-20:part0:1.1 [current_project]

# --------------------
# Filesets and Sources
# --------------------
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# IP repository must be registered before adding sources
set_property ip_repo_paths [file normalize "$origin_dir/ip/coprocessor_ip_1_0"] [current_project]
update_ip_catalog -rebuild

# Fail loudly and early if the custom IP isn't visible in the catalog,
# rather than silently producing an empty block design later.
set required_ip xilinx.com:user:coprocessor_ip:1.0
if { [get_ipdefs -all $required_ip] eq "" } {
  puts "ERROR: $required_ip not found in IP catalog. Check ip_repo_paths above."
  return
}

import_files -fileset sources_1 [list \
  [file normalize "$origin_dir/rtl/key_expansion.v"] \
  [file normalize "$origin_dir/rtl/mix_columns.v"] \
  [file normalize "$origin_dir/rtl/sbox.v"] \
  [file normalize "$origin_dir/rtl/shift_rows.v"] \
  [file normalize "$origin_dir/rtl/sub_bytes.v"] \
  [file normalize "$origin_dir/rtl/aes.v"] \
]
set_property top_auto_set 0 [get_filesets sources_1]

if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}
import_files -fileset sim_1 [list \
  [file normalize "$origin_dir/sim/aes_tb.v"] \
  [file normalize "$origin_dir/sim/key_expansion_tb.v"] \
  [file normalize "$origin_dir/sim/shift_rows_tb.v"] \
  [file normalize "$origin_dir/sim/sub_bytes_tb.v"] \
  [file normalize "$origin_dir/sim/mix_columns_tb.v"] \
  [file normalize "$origin_dir/sim/sbox_tb.v"] \
]
set_property top aes_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# --------------------
# Block Design
# --------------------
proc cr_bd_coprocessor_design { parentCell } {

  set design_name coprocessor_design
  create_bd_design $design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }
  set parentObj [get_bd_cells $parentCell]
  set oldCurInst [current_bd_instance .]
  current_bd_instance $parentObj

  # Create instances
  set processing_system7_0 [create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0]
  set coprocessor_ip_0 [create_bd_cell -type ip -vlnv xilinx.com:user:coprocessor_ip:1.0 coprocessor_ip_0]
  set ps7_0_axi_periph [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 ps7_0_axi_periph]
  set_property CONFIG.NUM_MI {1} $ps7_0_axi_periph
  set rst_ps7_0_50M [create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_ps7_0_50M]

  # PS7 config derived from the board file (replaces the hardcoded PCW_* dict)
  apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 \
      -config {make_external "FIXED_IO, DDR" apply_board_preset "1"} \
      [get_bd_cells processing_system7_0]
  set_property CONFIG.PCW_USE_M_AXI_GP0 {1} $processing_system7_0

  # Interface connections
  connect_bd_intf_net [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins ps7_0_axi_periph/S00_AXI]
  connect_bd_intf_net [get_bd_intf_pins ps7_0_axi_periph/M00_AXI] [get_bd_intf_pins coprocessor_ip_0/S00_AXI]

  # Clock/reset connections
  connect_bd_net [get_bd_pins processing_system7_0/FCLK_CLK0] \
      [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] \
      [get_bd_pins ps7_0_axi_periph/S00_ACLK] \
      [get_bd_pins ps7_0_axi_periph/M00_ACLK] \
      [get_bd_pins ps7_0_axi_periph/ACLK] \
      [get_bd_pins rst_ps7_0_50M/slowest_sync_clk] \
      [get_bd_pins coprocessor_ip_0/s00_axi_aclk]
  connect_bd_net [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_ps7_0_50M/ext_reset_in]
  connect_bd_net [get_bd_pins rst_ps7_0_50M/peripheral_aresetn] \
      [get_bd_pins ps7_0_axi_periph/S00_ARESETN] \
      [get_bd_pins ps7_0_axi_periph/M00_ARESETN] \
      [get_bd_pins ps7_0_axi_periph/ARESETN] \
      [get_bd_pins coprocessor_ip_0/s00_axi_aresetn]

  # Address map
  assign_bd_address -offset 0x43C00000 -range 0x00010000 \
      -target_address_space [get_bd_addr_spaces processing_system7_0/Data] \
      [get_bd_addr_segs coprocessor_ip_0/S00_AXI/S00_AXI_reg] -force

  current_bd_instance $oldCurInst
  validate_bd_design
  save_bd_design
}
cr_bd_coprocessor_design ""

# --------------------
# HDL Wrapper
# --------------------
set wrapper_path [make_wrapper -fileset sources_1 -files [get_files -norecurse coprocessor_design.bd] -top]
add_files -norecurse -fileset sources_1 $wrapper_path
set_property top coprocessor_design_wrapper [get_filesets sources_1]
update_compile_order -fileset sources_1

# --------------------
# Runs
# --------------------
if {[string equal [get_runs -quiet synth_1] ""]} {
  create_run -name synth_1 -part xc7z020clg400-1 -flow {Vivado Synthesis 2023} \
      -strategy "Vivado Synthesis Defaults" -constrset constrs_1
}
current_run -synthesis [get_runs synth_1]

if {[string equal [get_runs -quiet impl_1] ""]} {
  create_run -name impl_1 -part xc7z020clg400-1 -flow {Vivado Implementation 2023} \
      -strategy "Vivado Implementation Defaults" -constrset constrs_1 -parent_run synth_1
}
current_run -implementation [get_runs impl_1]

puts "INFO: Project created: ${_xil_proj_name_}"
