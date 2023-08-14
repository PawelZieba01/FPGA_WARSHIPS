 `timescale 1 ns / 1 ps

 module draw_grid_tb;
 
 
 /**
  *  Local parameters
  */
 
 localparam VGA_CLK_PERIOD = 15.384;     // 65 MHz
 
 
 /**
  * Local variables and signals
  */
 
 logic vga_clk, rst;
 wire vs, hs;
 wire [3:0] r, g, b;
 
 
 /**
  * Clock generation
  */
 
 initial begin
     vga_clk = 1'b0;
     forever #(VGA_CLK_PERIOD/2) vga_clk = ~vga_clk;
 end
 
 
 
 
 /**
  * Submodules instances
  */
 
 draw_grid_top_test dut (
     .vga_clk,
     .rst(rst),
     .vs(vs),
     .hs(hs),
     .r(r),
     .g(g),
     .b(b)
 );
 
 tiff_writer #(
     .XDIM(16'd1344),
     .YDIM(16'd806),
     .FILE_DIR("../../results")
 ) u_tiff_writer (
     .clk(vga_clk),
     .r({r,r}), // fabricate an 8-bit value
     .g({g,g}), // fabricate an 8-bit value
     .b({b,b}), // fabricate an 8-bit value
     .go(vs)
 );
 
 
 /**
  * Main test
  */
 
 initial begin
     rst = 1'b0;
     # 30 rst = 1'b1;
     # 30 rst = 1'b0;
 
     $display("If simulation ends before the testbench");
     $display("completes, use the menu option to run all.");
     $display("Prepare to wait a long time...");
 
     wait (vs == 1'b0);
     @(negedge vs) $display("Info: negedge VS at %t",$time);
     @(negedge vs) $display("Info: negedge VS at %t",$time);
 
     // End the simulation.
     $display("Simulation is over, check the waveforms.");
     $finish;
 end
 
 endmodule
 