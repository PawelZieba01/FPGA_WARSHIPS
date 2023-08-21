//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   main_fsm
 Author:        Robert Szczygiel
 Version:       1.0
 Last modified: 2023-05-18
 Coding style: safe with FPGA sync reset
 Description:  Main FSM module for FPGA_WARSHIPS project
 */
//////////////////////////////////////////////////////////////////////////////
module main_fsm(
    input  logic  clk,
    input  logic  rst,

    input  logic  start_btn,
    input  logic  [7:0] my_grid_cords,
    input  logic  [7:0] en_grid_cords,
    
    output  logic  [7:0] my_mem_addr,
    input  logic  [1:0] my_mem_data_in,
    output  logic  [1:0] my_mem_data_out,
    output logic my_mem_w_nr,

    output  logic  [7:0] en_mem_addr,
    input  logic  [1:0] en_mem_data_in,
    output  logic  [1:0] en_mem_data_out,
    output logic en_mem_w_nr,

    input  logic  ready2,
    input  logic  hit2,
    output logic ready1,
    output logic hit1,

    input  logic  [7:0] ship_cords_in,
    output  logic  [7:0] ship_cords_out,

    output logic [3:0] my_ctr,
    output logic [3:0] en_ctr
);

//------------------------------------------------------------------------------
// local parameters
//------------------------------------------------------------------------------
localparam STATE_BITS = 4; // number of bits used for state register

localparam SHIPS_NUMBER = 10; // number of ships to deploy on board

localparam GRID_STATUS_EMPTY = 2'b00;
localparam GRID_STATUS_MYSHIP = 2'b01;
localparam GRID_STATUS_MISS = 2'b10;
localparam GRID_STATUS_HIT = 2'b11;

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
logic  [3:0] my_ctr_nxt;    //ship counters
logic  [3:0] en_ctr_nxt;

logic  ready1_nxt;
logic  hit1_nxt;
logic  my_mem_w_nr_nxt, en_mem_w_nr_nxt;
logic  [7:0] my_mem_addr_nxt, en_mem_addr_nxt; 
logic  [1:0] my_mem_data_out_nxt, en_mem_data_out_nxt;
logic  [7:0] ship_cords_out_nxt;

enum logic [STATE_BITS-1 :0] {
    WAIT_FOR_BEGIN      = 4'b0000, // idle state
    PUT_SHIP            = 4'b0001,
    WAIT_FOR_ENEMY      = 4'b0011,
    WAIT_FOR_SHOT       = 4'b0010,
    MEM_READ            = 4'b0110,
    MEM_CHECK           = 4'b0111,
    COMPARE_AND_SAVE    = 4'b0101,
    SHOT                = 4'b0100,
    WAIT_FOR_ANSWER     = 4'b1100,
    SAVE_RESULT         = 4'b1101,
    WIN                 = 4'b1111,
    LOSE                = 4'b1110
} state, state_nxt;

//------------------------------------------------------------------------------
// state sequential with synchronous reset
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin : state_seq_blk
    if(rst)begin : state_seq_rst_blk
        state <= WAIT_FOR_BEGIN;
    end
    else begin : state_seq_run_blk
        state <= state_nxt;
    end
end
//------------------------------------------------------------------------------
// next state logic
//------------------------------------------------------------------------------
always_comb begin : state_comb_blk
    case(state)
        WAIT_FOR_BEGIN:     begin
            if(my_grid_cords!=8'hff && my_ctr!=0) begin
                state_nxt = PUT_SHIP;
            end
            else if(start_btn && my_ctr==0 && ready2==0) begin
                state_nxt = WAIT_FOR_SHOT;
            end
            else if(start_btn && my_ctr==0 && ready2==1) begin
                state_nxt = WAIT_FOR_ENEMY;
            end
            else begin
                state_nxt = WAIT_FOR_BEGIN;
            end
        end

        PUT_SHIP:           state_nxt = WAIT_FOR_BEGIN;
        WAIT_FOR_ENEMY:     begin
            if(en_ctr==0) begin
                state_nxt = WIN;
            end
            else if(my_ctr==0) begin
                state_nxt = LOSE;
            end
            else if(hit2 && ready2) begin
                state_nxt = MEM_READ;
            end
            else begin
                state_nxt = WAIT_FOR_ENEMY;
            end
        end
        WAIT_FOR_SHOT:      state_nxt = (en_grid_cords!=8'hff) ? SHOT : WAIT_FOR_SHOT;
        MEM_READ:           state_nxt = MEM_CHECK;
        MEM_CHECK:          state_nxt = COMPARE_AND_SAVE;
        COMPARE_AND_SAVE:   state_nxt = ready2 ? WAIT_FOR_SHOT : COMPARE_AND_SAVE;
        SHOT:               state_nxt = WAIT_FOR_ANSWER;
        WAIT_FOR_ANSWER:    state_nxt = ready2 ? SAVE_RESULT : WAIT_FOR_ANSWER;
        SAVE_RESULT:        state_nxt = ready2 ? WAIT_FOR_ENEMY : SAVE_RESULT;
        WIN:                state_nxt = WIN;
        LOSE:               state_nxt = LOSE;
        default: state_nxt = state;
    endcase
end
//------------------------------------------------------------------------------
// output register
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin : out_reg_blk
    if(rst) begin : out_reg_rst_blk
        my_ctr          <= SHIPS_NUMBER;
        en_ctr          <= SHIPS_NUMBER;
        my_mem_data_out <= '0;
        my_mem_addr     <= '0;
        en_mem_data_out <= '0;
        en_mem_addr     <= '0;
        my_mem_w_nr     <= '0;
        en_mem_w_nr     <= '0;
        ship_cords_out  <= '0;
        ready1          <= '0;
        hit1            <= '0;
    end
    else begin : out_reg_run_blk
        my_ctr              <= my_ctr_nxt;
        en_ctr              <= en_ctr_nxt;
        my_mem_data_out     <= my_mem_data_out_nxt;
        en_mem_data_out     <= en_mem_data_out_nxt;
        my_mem_w_nr         <= my_mem_w_nr_nxt;
        en_mem_w_nr         <= en_mem_w_nr_nxt;
        my_mem_addr         <= my_mem_addr_nxt;
        en_mem_addr         <= en_mem_addr_nxt;
        ship_cords_out      <= ship_cords_out_nxt;
        ready1              <= ready1_nxt;
        hit1                <= hit1_nxt;
    end
end
//------------------------------------------------------------------------------
// output logic
//------------------------------------------------------------------------------
always_comb begin : out_comb_blk
    my_ctr_nxt = my_ctr;
    en_ctr_nxt = en_ctr;
    my_mem_data_out_nxt = my_mem_data_out;
    en_mem_data_out_nxt = en_mem_data_out;
    my_mem_w_nr_nxt = my_mem_w_nr;
    en_mem_w_nr_nxt = en_mem_w_nr;
    my_mem_addr_nxt = my_mem_addr;
    en_mem_addr_nxt = en_mem_addr;
    ship_cords_out_nxt = ship_cords_out;
    ready1_nxt = ready1;
    hit1_nxt = hit1;


    case(state)
        WAIT_FOR_BEGIN:     begin
            if(my_grid_cords!=8'hff && my_ctr!=0) begin //put_ship_state
                my_ctr_nxt = my_ctr-1;
                my_mem_w_nr_nxt = '1;
                my_mem_addr_nxt = ship_cords_in;
                my_mem_data_out_nxt = GRID_STATUS_MYSHIP; 
            end
            else if(start_btn && my_ctr==0 && ready2==0) begin //wait_for_shot_state
                ready1_nxt = '1;
                hit1_nxt = '0;
                my_ctr_nxt = SHIPS_NUMBER;
                en_ctr_nxt = SHIPS_NUMBER;

            end
            else if(start_btn && my_ctr==0 && ready2==1) begin //wait_for_enemy_state
                ready1_nxt = '1;
                hit1_nxt = '0;
                my_ctr_nxt = SHIPS_NUMBER;
                en_ctr_nxt = SHIPS_NUMBER;
            end
            else begin //wait_for_begin_state
                ready1_nxt = '0;
            end
        end

        PUT_SHIP:           ready1_nxt = '0;
        WAIT_FOR_ENEMY:     begin
            if(en_ctr==0) begin //win_state
                //tutaj zkonczenie gry - win
            end
            else if(my_ctr==0) begin //loose_state
                //tutaj zkonczenie gry - loose
            end
            else if(hit2 && ready2) begin //mem_read_state
                my_mem_addr_nxt = ship_cords_in;
                my_mem_w_nr_nxt = '0;
                ready1_nxt = '0;
            end
            else begin // wait_for_enemy_state
                ready1_nxt = '1;
                hit1_nxt = '0;
            end
        end
        WAIT_FOR_SHOT:      {ready1_nxt, hit1_nxt, ship_cords_out_nxt} = (en_grid_cords!=8'hff) ? {1'b1, 1'b1, en_grid_cords} : {1'b1, 1'b0, ship_cords_out};
        MEM_READ:           ready1_nxt = 1'b0;
        MEM_CHECK:          begin
                            {hit1_nxt, my_ctr_nxt, my_mem_data_out_nxt} = ((my_mem_data_in == GRID_STATUS_MYSHIP) || (my_mem_data_in == GRID_STATUS_HIT)) ? {1'b1, 4'(my_ctr-1), GRID_STATUS_HIT} : {1'b0, my_ctr, GRID_STATUS_MISS};
                            ready1_nxt = 1'b1;
                            my_mem_addr_nxt = ship_cords_in;
                            my_mem_w_nr_nxt = 1'b1;
                            end
        COMPARE_AND_SAVE:   {ready1_nxt, hit1_nxt, my_mem_w_nr_nxt} = ready2 ? {1'b1, 1'b0, 1'b0} : {1'b1, hit1, 1'b0};
        SHOT:               {ready1_nxt, hit1_nxt, ship_cords_out_nxt} = {1'b1, 1'b1, ship_cords_out};
        WAIT_FOR_ANSWER:    begin
                                if(ready2) begin
                                    {en_mem_addr_nxt, en_mem_w_nr_nxt, ready1_nxt} = {ship_cords_in, 1'b1, 1'b1};
                                    {en_mem_data_out_nxt, en_ctr_nxt} = hit2 ? {GRID_STATUS_HIT, 4'(en_ctr-1)} : {GRID_STATUS_MISS, en_ctr};
                                end
                            end
        SAVE_RESULT:        {ready1_nxt, hit1_nxt, en_mem_w_nr_nxt} = ready2 ? {1'b1, 1'b0, 1'b0} : {ready1, hit1, en_mem_w_nr};
        WIN:                {ready1_nxt, hit1_nxt} = {ready1, hit1};
        LOSE:               {ready1_nxt, hit1_nxt} = {ready1, hit1};
        default:            {ready1_nxt, hit1_nxt} = {ready1, hit1};
    endcase
end

endmodule

/*
 * my_ctr_nxt = my_ctr;
            en_ctr_nxt = en_ctr;
            my_mem_data_out_nxt = my_mem_data_out;
            en_mem_data_out_nxt = en_mem_data_out;
            my_mem_w_nr_nxt = my_mem_w_nr;
            en_mem_w_nr_nxt = en_mem_w_nr;
            my_mem_addr_nxt = my_mem_addr;
            en_mem_addr_nxt = en_mem_addr;
            ship_cords_out_nxt = ship_cords_out;
            ready1_nxt = ready1;
            hit1_nxt = hit1;
*/