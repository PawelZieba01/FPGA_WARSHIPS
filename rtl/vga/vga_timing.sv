// File: vga_timing.sv
// This is the vga timing design for EE178 Lab #4.

// The `timescale directive specifies what the
// simulation time units are (1 ns here) and what 
// the simulator time step should be (1 ps here).

//Author:
//2023 Paweł Zięba  

`timescale 1 ns / 1 ps

// Declare the module and its ports. This is
// using Verilog-2001 syntax.

module vga_timing (
  input  logic clk,
  input logic rst,

  vga_if.out out
  );

  logic en_v_cnt; 

  h_counter h_counter(
    .clk(clk),
    .rst(rst),
    .h_cnt(out.hcount),
    .h_sync(out.hsync),
    .last_px(en_v_cnt),
    .h_blank(out.hblnk)
  );

  v_counter v_counter(
    .clk(clk),
    .rst(rst),
    .v_cnt(out.vcount),
    .v_sync(out.vsync),
    .enable(en_v_cnt),
    .v_blank(out.vblnk)
  );

  assign out.rgb = 12'b0;


endmodule
