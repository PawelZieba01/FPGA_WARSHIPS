/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * 2023  AGH University of Science and Technology
 * MTM UEC2
 * Piotr Kaczmarczyk
 * 
 * 2023
 * Paweł Zięba  
 *
 * Description:
 * Top level synthesizable module including the project top and all the FPGA-referred modules.
 */

`timescale 1 ns / 1 ps

module top_warships_basys3 (
    input  wire clk,
    input  wire btnC,
    output wire Vsync,
    output wire Hsync,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue,
    output wire JA1,
    inout wire PS2Clk,
    inout wire PS2Data
);


/**
 * Local variables and signals
 */

wire locked;
wire clk_65MHz;
wire clk_65MHz_mirror;
wire clk_50MHz;

(* KEEP = "TRUE" *)
(* ASYNC_REG = "TRUE" *)
// For details on synthesis attributes used above, see AMD Xilinx UG 901:
// https://docs.xilinx.com/r/en-US/ug901-vivado-synthesis/Synthesis-Attributes


/**
 * Signals assignments
 */

assign JA1 = clk_65MHz_mirror;


/**
 * FPGA submodules placement
 */

 clk_wiz_0 u_clk_wiz_0 (
    .clk(clk),
    .locked(locked),
    .clk_65MHz(clk_65MHz),
    .clk_50MHz(clk_50MHz)
 );

 ODDR pclk_oddr (
    .Q(clk_65MHz_mirror),
    .C(clk_65MHz),
    .CE(1'b1),
    .D1(1'b1),
    .D2(1'b0),
    .R(1'b0),
    .S(1'b0)
);

/**
 *  Project functional top module
 */

top_warships u_top_warships (
    .vga_clk(clk_65MHz),
    .mouse_clk(clk_50MHz),
    .rst(btnC),

    .ps2_clk(PS2Clk),
    .ps2_data(PS2Data),

    .r(vgaRed),
    .g(vgaGreen),
    .b(vgaBlue),
    .hs(Hsync),
    .vs(Vsync)
);

endmodule
