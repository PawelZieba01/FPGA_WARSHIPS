/**
 * AGH University of Science and Technology
 * 2023
 * Author: Pawel Zieba 
 *
 * Description:
 * The draw_ships module test enviroment.
 */

 `timescale 1 ns / 1 ps

 module draw_grid_top_test (
     input logic vga_clk,
     input logic rst,
 
     output logic vs,
     output logic hs,
     output logic [3:0] r,
     output logic [3:0] g,
     output logic [3:0] b
 );
 
 
     /**
      * Local variables and signals
      */
 
     // VGA interfaces
     vga_if tim_if();
     vga_if bg_if();
     vga_if ships_if();
 
 
     /**
      * Signals assignments
      */
 
     assign vs = ships_if.vsync;
     assign hs = ships_if.hsync;
     assign {r,g,b} = ships_if.rgb;
 
 
     /**
      * Submodules instances
      */
 
     vga_timing u_vga_timing (
         .clk(vga_clk),
         .rst,
         .out(tim_if)
     );
 
     draw_bg u_draw_bg (
         .clk(vga_clk),
         .rst,
 
         .in(tim_if),
         .out(bg_if)
     );
 
     draw_grid #(.X_POS(3), .Y_POS(3))
         u_draw_ships(
            .clk(vga_clk),
            .rst,
            .in(bg_if),
            .out(ships_if)
         );
             
 
 endmodule
 