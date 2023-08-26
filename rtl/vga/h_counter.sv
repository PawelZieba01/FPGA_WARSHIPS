/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Paweł Zięba  
 * 
 * Description:
 * Horizontal counter.
 */

`timescale 1 ns / 1 ps


module h_counter (
    input logic clk,
    input logic rst,
    output logic [10:0] h_cnt,
    output logic h_sync,
    output logic last_px,
    output logic h_blank
);

    import vga_cfg_pkg::*;

    logic [10:0] h_cnt_nxt;
    logic h_sync_nxt;
    logic last_px_nxt;
    logic h_blank_nxt;



    always_ff @(posedge clk) begin : counter_blk
        if(rst) begin
            h_cnt <= '0;
        end
        else begin
            h_cnt <= h_cnt_nxt;
        end    
    end

    always_comb begin : counter_nxt_blk
        if(h_cnt == H_TOTAL_TIME-1) begin
            h_cnt_nxt = 0;
        end
        else begin
            h_cnt_nxt = h_cnt + 1; 
        end
    end
        
    //----------------------------------------------

    always_ff @(posedge clk) begin : h_sync_blk
        if(rst) begin
            h_sync <= '0;
        end
        else begin
            h_sync <= h_sync_nxt;
        end       
    end

    always_comb begin : h_sync_nxt_blk
        if( (h_cnt >= H_SYNC_START-1)    &&    (h_cnt < (H_SYNC_START + H_SYNC_TIME - 1)) ) begin
            h_sync_nxt = '1;
        end
        else begin
            h_sync_nxt = '0;
        end
    end

    //-----------------------------------------------

    always_ff @(posedge clk) begin : last_px_blk
        if(rst) begin
            last_px <= '0;
        end
        else begin
            last_px <= last_px_nxt;
        end  
    end

    always_comb begin : last_px_nxt_blk
        if(h_cnt == H_TOTAL_TIME-2) begin
            last_px_nxt = '1;
        end
        else begin
            last_px_nxt = '0;
        end
    end

    //-----------------------------------------------

    always_ff @(posedge clk) begin : h_blank_blk
        h_blank <= h_blank_nxt;
    end

    always_comb begin : h_blank_nxt_blk
        if( (h_cnt >= H_BLANK_START-1)    &&    (h_cnt < (H_BLANK_START + H_BLANK_TIME-1)) ) begin
            h_blank_nxt = '1;
        end
        else begin
            h_blank_nxt = '0;
        end
    end

endmodule
