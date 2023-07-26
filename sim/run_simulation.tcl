# FPGA device
set target xc7a35tcpg236-1


# Print how to use the script
proc usage {} {
    puts "usage: vivado -mode tcl -source run_simulation -tclargs module_name show_gui"
}


# Create project
proc create_new_project {project_name target top_module files} {
    file mkdir build
    create_project ${project_name} build -part ${target} -force
    
    # Read sources
    source $files

    set_property top $top_module [get_filesets sim_1]
    set_property top_lib xil_defaultlib [get_filesets sim_1]
   #  set_property top ${top_module} [current_fileset]
   #  update_compile_order -fileset sim_1
}


# Simulation
proc simulation {} {

    #set_property top $test_top [get_filesets sim_1]
    #set_property top_lib xil_defaultlib [get_filesets sim_1]
    
    launch_simulation
    # If simulation needs more time than defult, enable run all
    #run all
    # relaunch ... TODO
    # add_wave ... TODO
}


## MAIN
if {${argc} != 2} {
    usage
    exit 1
} else {
    set test_module [lindex ${argv} 0]
    set show_gui [lindex ${argv} 1]
    set project_name ${test_module}_sim
    set test_files ${test_module}/${test_module}.tcl
    set top_module ${test_module}_tb
    create_new_project $project_name $target $top_module $test_files   
    simulation
    
    if {${show_gui} == 1} {
        start_gui
    } else {
        exit
    }
}
