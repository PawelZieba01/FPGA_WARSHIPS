/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Paweł Zięba  
 * 
 * Description:
 * Draw rectangle.
 */

 `timescale 1 ns / 1 ps


module draw_rect #( parameter
    RECT_WIDTH = 48,
    RECT_HEIGHT = 64
)(
    input logic clk,
    input logic rst,

    input logic enable,

    input logic [11:0] x_pos,
    input logic [11:0] y_pos,

    input logic [11:0] rgb_pixel,
    output logic [13:0] pixel_addr,

    vga_if.in in,
    vga_if.out out
);


    logic [11:0] x_pos_sync;
    logic [11:0] y_pos_sync;

    logic [13:0] pixel_addr_nxt; 

    logic [10:0] hcount_nxt1, vcount_nxt1, hcount_nxt2, vcount_nxt2;
    logic hsync_nxt1, hblnk_nxt1, vsync_nxt1, vblnk_nxt1, hsync_nxt2, hblnk_nxt2, vsync_nxt2, vblnk_nxt2;
    logic [11:0] rgb_nxt1, rgb_nxt2, rgb_out_nxt;

    //clock sync block
    always_ff @(posedge clk) begin
        x_pos_sync <= x_pos;
        y_pos_sync <= y_pos;
    end

/*-------------- vga signals delay generation ---------------*/
    always_ff @(posedge clk) begin : delay_1_output_signals_blk
        if(rst) begin
            hcount_nxt1 <= '0;
            vcount_nxt1 <= '0;
            hsync_nxt1 <= '0;
            hblnk_nxt1 <= '0;
            vsync_nxt1 <= '0;
            vblnk_nxt1 <= '0;
            rgb_nxt1 <= '0;
        end
        else begin
            hcount_nxt1 <= in.hcount;
            vcount_nxt1 <= in.vcount;
            hsync_nxt1 <= in.hsync;
            hblnk_nxt1 <= in.hblnk;
            vsync_nxt1 <= in.vsync;
            vblnk_nxt1 <= in.vblnk;
            rgb_nxt1 <= in.rgb;
        end
    end

    always_ff @(posedge clk) begin : delay_2_output_signals_blk
        if(rst) begin
            hcount_nxt2 <= '0;
            vcount_nxt2 <= '0;
            hsync_nxt2 <= '0;
            hblnk_nxt2 <= '0;
            vsync_nxt2 <= '0;
            vblnk_nxt2 <= '0;
            rgb_nxt2 <= '0;
        end
        else begin
            hcount_nxt2 <= hcount_nxt1;
            vcount_nxt2 <= vcount_nxt1;
            hsync_nxt2 <= hsync_nxt1;
            hblnk_nxt2 <= hblnk_nxt1;
            vsync_nxt2 <= vsync_nxt1;
            vblnk_nxt2 <= vblnk_nxt1;
            rgb_nxt2 <= rgb_nxt1;
        end
    end
/*-----------------------------------------------------------*/


/*----------- pixer_addr output signal generation -----------*/
    always_comb begin : pixel_addr_nxt_blk
        pixel_addr_nxt = ((in.vcount - y_pos_sync)<<$clog2(RECT_WIDTH)) + (in.hcount - x_pos_sync);
    end

    always_ff @(posedge clk) begin : pixel_addr_blk
        if(rst) begin
            pixel_addr <= '0;
        end
        else begin
            pixel_addr <= pixel_addr_nxt;
        end
    end
/*-----------------------------------------------------------*/


    always_comb begin : rgb_out_blk
        if(hblnk_nxt2 || vblnk_nxt2) begin : blank_blk
            rgb_out_nxt= 12'b0;
        end
        else begin 
            if((hcount_nxt2 >= x_pos_sync)                 &&
             (hcount_nxt2 < x_pos_sync + RECT_WIDTH)       &&
             (vcount_nxt2 >= y_pos_sync)                   &&
             (vcount_nxt2 < y_pos_sync + RECT_HEIGHT)      &&
             (enable == 1'b1))     begin : rect_area_blk
                if(rgb_pixel == 12'h0f0)begin
                    rgb_out_nxt = rgb_nxt2;
                end
                else begin
                    rgb_out_nxt = rgb_pixel;
                end
            end
            else begin
                rgb_out_nxt = rgb_nxt2;
            end
        end 
    end

    always_ff @(posedge clk) begin : output_signals_blk
        if(rst) begin
            out.hcount <= '0;
            out.vcount <= '0;
            out.hsync <= '0;
            out.hblnk <= '0;
            out.vsync <= '0;
            out.vblnk <= '0;
            out.rgb <= '0;
        end
        else begin
            out.hcount <= hcount_nxt2;
            out.vcount <= vcount_nxt2;
            out.hsync <= hsync_nxt2;
            out.hblnk <= hblnk_nxt2;
            out.vsync <= vsync_nxt2;
            out.vblnk <= vblnk_nxt2;
            out.rgb <= rgb_out_nxt;
        end
    end

endmodule
