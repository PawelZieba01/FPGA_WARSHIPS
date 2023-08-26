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
 * 2023  AGH University of Science and Technology
 * MTM UEC2
 * Pawel Zieba
 *
 * Description:
 * Testbench for top_warships.
 * Thanks to the tiff_writer module, an expected image
 * produced by the project is exported to a tif file.
 * Since the vs signal is connected to the go input of
 * the tiff_writer, the first (top-left) pixel of the tif
 * will not correspond to the vga project (0,0) pixel.
 * The active image (not blanked space) in the tif file
 * will be shifted down by the number of lines equal to
 * the difference between VER_SYNC_START and VER_TOTAL_TIME.
 */

`timescale 1 ns / 1 ps

module top_warships_tb;


/**
 *  Local parameters
 */

localparam VGA_CLK_PERIOD = 15.384;     // 65 MHz
localparam PS2_CLK_PERIOD = 20;     // 50 MHz


/**
 * Local variables and signals
 */

logic vga_clk, ps2_clk, rst;
wire vs, hs;
wire [3:0] r, g, b;


/**
 * Clock generation
 */

initial begin
    vga_clk = 1'b0;
    forever #(VGA_CLK_PERIOD/2) vga_clk = ~vga_clk;
end

initial begin
    ps2_clk = 1'b0;
    forever #(PS2_CLK_PERIOD/2) ps2_clk = ~ps2_clk;
end



/**
 * Submodules instances
 */

top_warships dut (
    .vga_clk,
    .mouse_clk(ps2_clk),
    .rst(rst),
    .vs(vs),
    .hs(hs),
    .r(r),
    .g(g),
    .b(b),
    .an(),
    .control_clk(),
    .hit1(),
    .hit2(),
    .led(),
    .ps2_clk(),
    .ps2_data(),
    .ready1(),
    .ready2(),
    .ship_cords_in(),
    .ship_cords_out(),
    .sseg()
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
