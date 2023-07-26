/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Paweł Zięba  
 * 
 * Description:
 * Vertical counter.
 */

`timescale 1 ns / 1 ps


module v_counter (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [10:0] v_cnt,
    output logic v_sync,
    output logic v_blank
);

    import vga_pkg::*;

    logic [10:0] v_cnt_nxt;
    logic v_sync_nxt;
    logic v_blank_nxt;


    always_ff @(posedge clk) begin : counter_blk
        if(rst) begin
            v_cnt <= '0;
        end
        else begin
            v_cnt <= v_cnt_nxt;
        end
         
    end

    always_comb begin : counter_nxt_blk
        if(enable == '1) begin
            if(v_cnt == V_TOTAL_TIME-1) begin
                v_cnt_nxt = '0;
            end
            else begin
                v_cnt_nxt = v_cnt + 1;
            end
        end
        else begin
            v_cnt_nxt = v_cnt;
        end
    end
        
    //----------------------------------------------

    always_ff @(posedge clk) begin : v_sync_blk
        if(rst) begin
            v_sync <= '0;
        end
        else begin
            v_sync <= v_sync_nxt;
        end
    end

    always_comb begin : v_sync_nxt_blk
        if(enable) begin
            if((v_cnt >= V_SYNC_START-1)    &&    (v_cnt < (V_SYNC_START + V_SYNC_TIME-1))) begin
                v_sync_nxt = '1;
            end
            else begin
                v_sync_nxt = '0;
            end
        end
        else begin
            v_sync_nxt = v_sync;
        end
    end

    //-----------------------------------------------

    always_ff @(posedge clk) begin : v_blank_blk
        if(rst) begin
            v_blank <= '0;
        end
        else begin
            v_blank <= v_blank_nxt;
        end
    end

    always_comb begin : v_blank_nxt_blk
        if( (((v_cnt >= V_BLANK_START)    &&    (v_cnt < (V_BLANK_START + V_BLANK_TIME)))    ||    ((v_cnt == V_BLANK_START-1) && (enable == '1)) )    &&    ~((v_cnt == (V_BLANK_START + V_BLANK_TIME-1))    &&    (enable == '1)) ) begin
            v_blank_nxt = '1;
        end
        else begin
            v_blank_nxt = '0;
        end
    end

endmodule
