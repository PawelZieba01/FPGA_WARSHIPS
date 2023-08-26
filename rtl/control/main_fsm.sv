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
    output logic start_btn_en,

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
    output logic [3:0] en_ctr,

    output logic [3:0] state_out,

    output logic win,
    output logic lose,
    output logic my_turn,
    output logic en_turn
);

import project_cfg_pkg::*;
//------------------------------------------------------------------------------
// local parameters
//------------------------------------------------------------------------------
localparam STATE_BITS = 4; // number of bits used for state register

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
logic start_btn_en_nxt;
logic win_nxt, lose_nxt;
logic my_turn_nxt, en_turn_nxt;

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

assign state_out = state;

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
            else begin
                if(start_btn && my_ctr==0) begin
                    state_nxt = ready2 ? WAIT_FOR_ENEMY : WAIT_FOR_SHOT;
                end
                else begin
                    state_nxt = WAIT_FOR_BEGIN;
                end
            end
        end

        PUT_SHIP:           state_nxt = WAIT_FOR_BEGIN;
        WAIT_FOR_ENEMY:     begin
            if(my_ctr == 0) begin   //loose_state
                state_nxt = LOSE;
            end
            else begin
                if(en_ctr == 0) begin   //win_state
                    state_nxt = WIN;
                end
                else begin
                    if(hit2 && ready2) begin    //mem_read_state
                        state_nxt = MEM_READ;
                    end
                    else begin      //wait_for_enemy_state
                        state_nxt = WAIT_FOR_ENEMY;
                    end
                end
            end
        end
        WAIT_FOR_SHOT:      begin
            if(en_ctr == 0) begin       //win_state
                state_nxt = WIN;
            end
            else begin
                if(my_ctr == 0) begin   //lose state
                    state_nxt = LOSE;
                end
                else begin              //shot or wait_for_shot state
                    state_nxt = (en_grid_cords!=8'hff && ready2) ? SHOT : WAIT_FOR_SHOT;
                end
            end
            
        end
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
        start_btn_en    <= '1;
        win             <= '0;
        lose            <= '0;
        my_turn         <= '0;
        en_turn         <= '0;
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
        start_btn_en        <= start_btn_en_nxt;
        win                 <= win_nxt;
        lose                <= lose_nxt;
        my_turn             <= my_turn_nxt;
        en_turn             <= en_turn_nxt;
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
    start_btn_en_nxt = start_btn_en;
    win_nxt = win;
    lose_nxt = lose;
    my_turn_nxt = my_turn;
    en_turn_nxt = en_turn;


    case(state)
        WAIT_FOR_BEGIN:     begin
            if(my_grid_cords!=8'hff && my_ctr!=0) begin     //put_ship_state
                my_ctr_nxt = my_ctr-1;
                my_mem_w_nr_nxt = '1;
                my_mem_addr_nxt = my_grid_cords;
                my_mem_data_out_nxt = GRID_STATUS_MYSHIP; 
            end
            else begin
                if(start_btn && my_ctr==0) begin
                     if(ready2) begin   //wait_for_enemy_state
                        ready1_nxt = '1;
                        hit1_nxt = '0;
                        my_ctr_nxt = SHIPS_NUMBER;
                        en_ctr_nxt = SHIPS_NUMBER;
                        start_btn_en_nxt = 1'b0;
                        {my_turn_nxt, en_turn_nxt} = {1'b0, 1'b1};
                     end
                     else begin         //wait_for_shot_state
                        ready1_nxt = '1;
                        hit1_nxt = '0;
                        my_ctr_nxt = SHIPS_NUMBER;
                        en_ctr_nxt = SHIPS_NUMBER;
                        start_btn_en_nxt = 1'b0;
                        {my_turn_nxt, en_turn_nxt} = {1'b1, 1'b0};
                    end
                end
                else begin      //wait_for_begin_state
                    ready1_nxt = '0;
                    my_ctr_nxt = my_ctr;
                end
            end
        end

        PUT_SHIP:           {ready1_nxt, my_mem_w_nr_nxt, my_ctr_nxt} = {1'b0, 1'b0, my_ctr};
        WAIT_FOR_ENEMY:     begin
            if(my_ctr == 0) begin   //loose_state
               {win_nxt, lose_nxt} = {1'b0, 1'b1};
            end
            else begin
                if(en_ctr == 0) begin   //win_state
                    {win_nxt, lose_nxt} = {1'b1, 1'b0};
                end
                else begin
                    if(hit2 && ready2) begin    //mem_read_state
                        my_mem_addr_nxt = ship_cords_in;
                        my_mem_w_nr_nxt = '0;
                        ready1_nxt = '0;
                    end
                    else begin      //wait_for_enemy_state
                        ready1_nxt = '1;
                        hit1_nxt = '0;
                        {my_turn_nxt, en_turn_nxt} = {1'b0, 1'b1};
                    end
                end
            end
        end
        WAIT_FOR_SHOT:      begin
            if(en_ctr == 0) begin       //win state
                {win_nxt, lose_nxt} = {1'b1, 1'b0};
            end
            else begin                  
                if(my_ctr == 0) begin   //lose state
                    {win_nxt, lose_nxt} = {1'b0, 1'b1};
                end
                else begin              //shot or wait_for_shot state
                    {ready1_nxt, hit1_nxt, ship_cords_out_nxt} = (en_grid_cords!=8'hff && ready2) ? {1'b1, 1'b1, en_grid_cords} : {1'b1, 1'b0, ship_cords_out};
                    {my_turn_nxt, en_turn_nxt} = {1'b1, 1'b0};
                end
            end
        end
        MEM_READ:           ready1_nxt = 1'b0;
        MEM_CHECK:          begin
                            {hit1_nxt, my_ctr_nxt, my_mem_data_out_nxt} = ((my_mem_data_in == GRID_STATUS_MYSHIP) || (my_mem_data_in == GRID_STATUS_HIT)) ? {1'b1, 4'(my_ctr-1), GRID_STATUS_HIT} : {1'b0, my_ctr, GRID_STATUS_MISS};
                            ready1_nxt = 1'b1;
                            my_mem_addr_nxt = ship_cords_in;
                            my_mem_w_nr_nxt = 1'b1;
                            end
        COMPARE_AND_SAVE:   begin
                            {ready1_nxt, hit1_nxt, my_mem_w_nr_nxt} = ready2 ? {1'b1, 1'b0, 1'b0} : {1'b1, hit1, 1'b0};
                            my_ctr_nxt = my_ctr;
                            {my_turn_nxt, en_turn_nxt} = {1'b1, 1'b0};
                            end
        SHOT:               {ready1_nxt, hit1_nxt, ship_cords_out_nxt} = {1'b1, 1'b1, ship_cords_out};
        WAIT_FOR_ANSWER:    begin
                                if(ready2) begin
                                    {en_mem_addr_nxt, en_mem_w_nr_nxt, ready1_nxt} = {ship_cords_out, 1'b1, 1'b1};
                                    {en_mem_data_out_nxt, en_ctr_nxt} = hit2 ? {GRID_STATUS_HIT, 4'(en_ctr-1)} : {GRID_STATUS_MISS, en_ctr};
                                end
                            end
        SAVE_RESULT:        begin
            {ready1_nxt, hit1_nxt, en_mem_w_nr_nxt, en_ctr_nxt} = ready2 ? {1'b1, 1'b0, 1'b0, en_ctr} : {ready1, hit1, en_mem_w_nr, en_ctr};
            {my_turn_nxt, en_turn_nxt} = {1'b0, 1'b1};
        end
        WIN:                {ready1_nxt, hit1_nxt} = {ready1, hit1};
        LOSE:               {ready1_nxt, hit1_nxt} = {ready1, hit1};
        default:            {ready1_nxt, hit1_nxt} = {ready1, hit1};
    endcase
end

endmodule
