/**
 * AGH Krakow
 * 2023
 * Author: Pawel Zieba
 * 
 * Testbench for board_mem module.
 */

`timescale 1 ns / 1 ps

module board_mem_tb;


/**
 *  Local parameters
 */

 //clk_write setup
localparam CLK1_FREQ     = 1_000;
localparam CLK1_PERIOD = (1.0/CLK1_FREQ) * 1_000_000_000;

 //clk_read setup
localparam CLK2_FREQ     = 65_000_000;
localparam CLK2_PERIOD = (1.0/CLK2_FREQ) * 1_000_000_000;

localparam MEM_X_SIZE = 16;
localparam MEM_Y_SIZE = 16;
localparam MEM_DATA_WIDTH = 2;
localparam MEM_X_ADDR_WIDTH = 4;
localparam MEM_Y_ADDR_WIDTH = 4;


/**
 * Local variables and signals
 */

logic clk_write, clk_read;
logic [MEM_Y_ADDR_WIDTH+MEM_X_ADDR_WIDTH-1 : 0] mem_addr_write, mem_addr_read;   
logic [MEM_DATA_WIDTH-1:0] write_data;
logic [MEM_DATA_WIDTH-1:0] read_data;
logic write_enable;




/**
 * Clock generation
 */

initial begin
    clk_write = 1'b0;
    forever #(CLK1_PERIOD/2) clk_write = ~clk_write;
end

initial begin
    clk_read = 1'b0;
    forever #(CLK2_PERIOD/2) clk_read = ~clk_read;
end

/**
 * Submodules instances
 */

board_mem #(
    .X_SIZE(MEM_X_SIZE),
    .Y_SIZE(MEM_Y_SIZE), 
    .X_ADDR_WIDTH(MEM_X_ADDR_WIDTH),
    .Y_ADDR_WIDTH(MEM_Y_ADDR_WIDTH),
    .DATA_WIDTH(MEM_DATA_WIDTH)) 
dut (
    .write_clk(clk_write),
    .read_clk(clk_read),
    .write_addr(mem_addr_write),
    .read_addr(mem_addr_read),
    .write_data,
    .read_data,
    .write_enable
);


/**
 * Main test
 */

 always @(posedge clk_write) begin
    if(write_enable) begin
        mem_addr_write++;
        mem_addr_read++;
        write_data++;
    end
 end


initial begin
    write_enable = 1'b0;
    write_data = '0;
    mem_addr_read = -1;
    mem_addr_write = '0;

    $display("Simulation start.");
    #100;
    $display("Writting into ram memory.");
    write_enable = 1'b1;

    wait(mem_addr_write == 1);
    wait(mem_addr_write == 0);

    // End the simulation.
    $display("Simulation is over, check the waveforms.");
    $finish;
end

endmodule
