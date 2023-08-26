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

logic clk1, clk2, rst;
logic [MEM_Y_ADDR_WIDTH+MEM_X_ADDR_WIDTH-1 : 0] mem_addr1, mem_addr2;   
logic [MEM_DATA_WIDTH-1:0] write_data1;
logic [MEM_DATA_WIDTH-1:0] read_data2;
logic w_nr;




/**
 * Clock generation
 */

initial begin
    clk1 = 1'b0;
    forever #(CLK1_PERIOD/2) clk1 = ~clk1;
end

initial begin
    clk2 = 1'b0;
    forever #(CLK2_PERIOD/2) clk2 = ~clk2;
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
    .rst,
    .clk1(clk1),
    .clk2(clk2),
    .addr1(mem_addr1),
    .addr2(mem_addr2),
    .write_data1,
    .read_data1(),
    .read_data2,
    .w_nr
);


/**
 * Main test
 */

 always @(posedge clk1) begin
    if(w_nr) begin
        mem_addr1++;
        mem_addr2++;
        write_data1++;
    end
 end


initial begin
    rst = 1;
    #100 rst = 0;
    w_nr = 1'b0;
    write_data1 = '0;
    mem_addr2 = -1;
    mem_addr1 = '0;

    $display("Simulation start.");
    #100;
    $display("Writting into ram memory.");
    w_nr = 1'b1;

    wait(mem_addr1 == 1);
    wait(mem_addr1 == 0);

    // End the simulation.
    $display("Simulation is over, check the waveforms.");
    $finish;
end

endmodule
