/**
 * AGH Krakow
 * 2023
 * Author: Pawel Zieba
 * 
 * Testbench for board_mem module.
 */

`timescale 1 ns / 1 ps

module main_fsm_tb;


/**
 *  Local parameters
 */

 //clk setup
localparam CLK1_FREQ     = 10_000_000;
localparam CLK1_PERIOD = (1.0/CLK1_FREQ) * 1_000_000_000;

localparam SHIPS_NUMBER = 10;




/**
 * Local variables and signals
 */

logic clk;
logic rst;
logic [7:0] en_grid_cords;
logic [7:0] en_mem_addr;
logic [1:0] en_mem_data_in;
logic [1:0] en_mem_data_out;
logic en_mem_w_nr;
logic hit1;
logic hit2;
logic [7:0] my_grid_cords;
logic [7:0] my_mem_addr;
logic [1:0] my_mem_data_in;
logic [1:0] my_mem_data_out;
logic my_mem_w_nr;
logic ready1;
logic ready2;
logic [7:0] ship_cords_in;
logic [7:0] ship_cords_out;
logic start_btn;
logic [3:0] my_ctr;
logic [3:0] en_ctr;


/**
 * Clock generation
 */

initial begin
    clk = 1'b0;
    forever #(CLK1_PERIOD/2) clk = ~clk;
end


/**
 * Submodules instances
 */

main_fsm dut(
    .clk,
    .en_grid_cords,
    .en_mem_addr,
    .en_mem_data_in,
    .en_mem_data_out,
    .en_mem_w_nr,
    .hit1,
    .hit2,
    .my_grid_cords,
    .my_mem_addr,
    .my_mem_data_in,
    .my_mem_data_out,
    .my_mem_w_nr,
    .ready1,
    .ready2,
    .rst,
    .ship_cords_in,
    .ship_cords_out,
    .start_btn,
    .my_ctr,
    .en_ctr,
    .start_btn_en(),
    .en_turn(),
    .my_turn(),
    .lose(),
    .win(),
    .state_out()
);

function void list_outputs();
    $display("----- OUTPUT SIGNALS -----");
    $display("en_mem_data_out %b", en_mem_data_out);
    $display("en_mem_addr %b", en_mem_addr);
    $display("en_mem_w_nr %b", en_mem_w_nr);
    $display("my_mem_data_out %b", my_mem_data_out);
    $display("my_mem_addr %b", my_mem_addr);
    $display("my_mem_w_nr %b", my_mem_w_nr);
    $display("ready1 %b", ready1);
    //$display("ready2 %b", ready2);
    $display("hit1 %b", hit1);
    //$display("hit2 %b", hit2);
    $display("ship_cords_out %h", ship_cords_out);
    $display("my_ctr %d", my_ctr);
    $display("en_ctr %d", en_ctr);
    $display("...");
    $display("...");
    $display("...");
    $display("...");
endfunction
/**
 * Main test
 */
initial begin
    rst = 1;
    $display("Simulation start.");
    #(10*CLK1_PERIOD);
    rst = 0;

    $display("Initial values:");
    list_outputs();


    $display("State: WAIT_FOR_BEGIN");
    $display("Start deploying ships");

    for(int ships_nr = 0; ships_nr < SHIPS_NUMBER; ships_nr++) begin
        $display("Ship nr: %d", ships_nr+1);
        my_grid_cords = ships_nr;
        #CLK1_PERIOD;
        my_grid_cords = 8'hff;
        list_outputs();
        #(10*CLK1_PERIOD);
    end

    $display("Deployed ships...");
    $display("START BUTTON + READY2=1");
    $display("State: WAIT_FOR_ENEMY");
    ready2 = 1;
    start_btn = 1;
    #CLK1_PERIOD;
    start_btn = 0; 
    #(10*CLK1_PERIOD);
    list_outputs();

    $display("Shot from enemy -> 1,1 cords + hit2=1, ready2=1");
    $display("State: MEM_READ");
    hit2 = 1;
    ready2 = 1;
    ship_cords_in = 8'h11;
    #CLK1_PERIOD;
    ready2 = 0;
    list_outputs();

    $display("State: MEM_CHECK");
    my_mem_data_in = 2'b01;  //my ship code
    #CLK1_PERIOD;
    list_outputs();

    $display("State: COMPARE_AND_SAVE");
    #CLK1_PERIOD;
    list_outputs();
    
    $display("Set ready2=1");
    ready2 = 1;
    hit2 = 0;
    #CLK1_PERIOD;
    ready2 = 0;
    $display("State: WAIT_FOR_SHOT");
    list_outputs();

    $display("State: SHOT");
    en_grid_cords = 8'h11;
    #CLK1_PERIOD;
    en_grid_cords = 8'hff;
    list_outputs();

    $display("State: WAIT_FOR_ANSWER");
    #CLK1_PERIOD;
    list_outputs();

    $display("State: SAVE_RESULTS");
    ready2 = 1;
    hit2 = 0;
    #CLK1_PERIOD;
    list_outputs();

    $display("State: WAIT_FOR_ENEMY");
    #CLK1_PERIOD;
    ready2 = 0;
    hit2 = 0;
    list_outputs();

    // End the simulation.
    $display("Simulation is over, check the waveforms.");
    $finish;
end

endmodule
