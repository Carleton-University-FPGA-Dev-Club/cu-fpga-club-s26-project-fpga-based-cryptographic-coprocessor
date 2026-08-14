# 1. Define paths and names
set PROJECT_NAME "cryptographic_coprocessor"
set FPGA_PART "xc7z020clg400-1" 
set REPO_ROOT [file normalize "[file dirname [info script]]/.."]
set BUILD_DIR "${REPO_ROOT}/build"

# 2. Create a project workspace
file mkdir ${BUILD_DIR}
create_project -force ${PROJECT_NAME} ${BUILD_DIR}/${PROJECT_NAME} -part ${FPGA_PART}

# 3. Link custom AXI peripheral
set_property ip_repo_paths [file normalize "${REPO_ROOT}/ip"] [current_project]
update_ip_catalog

# 4. Recreate block design after updating IP catalog
source "${REPO_ROOT}/scripts/block_design.tcl"

# 5. Generate the structural Verilog wrapper for the block design
set bd_file [get_files *[current_bd_design].bd]
make_wrapper -files $bd_file -top
add_files -norecurse [file normalize [glob ${BUILD_DIR}/${PROJECT_NAME}/${PROJECT_NAME}.srcs/sources_1/bd/*/hdl/*_wrapper.v]]
update_compile_order -fileset sources_1

# 7. Compile everything (Synthesis -> Implementation -> Bitstream)
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1

# 8. Export the .XSA file for Vitis software development
file mkdir ${BUILD_DIR}/outputs
write_hw_platform -fixed -include_bit -force -file ${BUILD_DIR}/outputs/coprocessor.xsa

puts "Build complete. Please find the .xsa file in build/output."
exit