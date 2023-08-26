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
 * NAtalia Kapuscinska
 *
 * Description:
 * Testbench for player_ctrl module.
 */

`timescale 1 ns / 1 ps

module player_ctrl_tb;


/**
 *  Local parameters
 */

localparam VGA_CLK_PERIOD = 15.384;     // 65 MHz


/**
 * Local variables and signals
 */

logic clk, rst, left;
logic [11:0] x_pos, y_pos;
logic [7:0] player_cor,  enemy_cor;
wire start_btn;



/**
 * Clock generation
 */

initial begin
    clk = 1'b0;
    forever #(VGA_CLK_PERIOD/2) clk = ~clk;
end
initial begin
    rst = 1'b0;
    # 40 rst = 1'b1;
    # 40 rst = 1'b0;

    #240 x_pos = 12'h014A;
    y_pos = 12'h014A;
    #30 left = 1;

    #240 x_pos = 12'h0258;
    y_pos = 12'h0FA;
    #30 left = 1;

    #240 x_pos = 12'h03E8;
    y_pos = 12'h0258;
    #30 left = 1;


    // End the simulation.
    $display("Simulation is over, check the waveforms.");
    $finish;
end

player_ctrl dut(
    .clk,
    .rst,
    .x_pos,
    .y_pos,
    .left,

    .start_btn,
    .player_cor, //player board coordinates
    .enemy_cor

);


endmodule