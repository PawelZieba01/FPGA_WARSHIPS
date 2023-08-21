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
 * FPGA_WARSHIPS_2023
 */

`timescale 1 ns / 1 ps

module top_warships_basys3 (
    input  logic clk,

    input  logic btnC,

    output logic Vsync,
    output logic Hsync,
    output logic [3:0] vgaRed,
    output logic [3:0] vgaGreen,
    output logic [3:0] vgaBlue,
    
    output logic [15:0] led,

    input logic [1:0] JA_in,
    output logic [1:0] JA_out,
    input logic [7:0] JB,
    output logic [7:0] JC,
    output logic JA1,

    output logic [6:0] seg,
    output logic [3:0] an,

    inout logic PS2Clk,
    inout logic PS2Data
);


/**
 * Local variables and signals
 */

logic locked;
logic clk_65MHz;
logic clk_65MHz_mirror;
logic clk_10MHz;

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
    .clk_10MHz(clk_10MHz) 
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
    .mouse_clk(clk_65MHz),
    .control_clk(clk_10MHz),
    .rst(btnC),

    .ps2_clk(PS2Clk),
    .ps2_data(PS2Data),

    .r(vgaRed),
    .g(vgaGreen),
    .b(vgaBlue),
    .hs(Hsync),
    .vs(Vsync),

    .led,

    .ready2(JA_in[0]),
    .hit2(JA_in[1]),
    .ready1(JA_out[1]),
    .hit1(JA_out[0]),

    .ship_cords_in(JB),
    .ship_cords_out(JC),

    .seg,
    .an
);

endmodule
