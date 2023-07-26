# Copyright (C) 2023  AGH University of Science and Technology
# MTM UEC2
# Author: Piotr Kaczmarczyk
#
# Description:
# Project detiles required for generate_bitstream.tcl
# Make sure that project_name, top_module and target are correct.
# Provide paths to all the files required for synthesis and implementation.
# Depending on the file type, it should be added in the corresponding section.
# If the project does not use files of some type, leave the corresponding section commented out.

#-----------------------------------------------------#
#                   Project details                   #
#-----------------------------------------------------#
# Project name                                  -- EDIT
set project_name FPGA_WARSHIPS

# Top module name                               -- EDIT
set top_module top_warships_basys3

# FPGA device
set target xc7a35tcpg236-1

#-----------------------------------------------------#
#                    Design sources                   #
#-----------------------------------------------------#
# Specify .xdc files location                   -- EDIT
set xdc_files {
    constraints/top_warships_basys3.xdc
    constraints/clk_wiz_0.xdc
}

# Specify SystemVerilog design files location   -- EDIT
set sv_files {
    ../rtl/vga/vga_pkg.sv
    ../rtl/vga/vga_if.sv

    ../rtl/vga/vga_timing.sv
    ../rtl/vga/h_counter.sv
    ../rtl/vga/v_counter.sv

    ../rtl/draw_bg.sv
    ../rtl/common/simple_clk_div.sv
    ../rtl/rect/draw_rect.sv
    ../rtl/rect/draw_rect_ctl.sv
    ../rtl/mouse/draw_mouse.sv
    ../rtl/rect/image_rom.sv

    ../rtl/rect_char/draw_rect_char.sv
    ../rtl/rect_char/char_rom_16x16.sv
    

    ../rtl/top_warships.sv
    
    rtl/top_warships_basys3.sv
}

# Specify Verilog design files location         -- EDIT
set verilog_files {
    rtl/clk_wiz_0_clk_wiz.v
    rtl/clk_wiz_0.v
    ../rtl/common/delay.v
    ../rtl/rect_char/font_rom.v
}

# Specify VHDL design files location            -- EDIT
set vhdl_files {
    ../rtl/mouse/MouseCtl.vhd
    ../rtl/mouse/Ps2Interface.vhd
    ../rtl/mouse/MouseDisplay.vhd
}

# Specify files for a memory initialization     -- EDIT
set mem_files {
   ../rtl/rect/image_rom.data
}
