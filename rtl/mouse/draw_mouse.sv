/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Paweł Zięba  
 * 
 * Description:
 * Draw mouse.
 */

 `timescale 1 ns / 1 ps



module draw_mouse (
    input logic clk,
    input logic rst,

    input logic [11:0] x_pos,
    input logic [11:0] y_pos,

    vga_if.in in,
    vga_if.out out
);


    logic [11:0] x_pos_sync;
    logic [11:0] y_pos_sync;

    logic [10:0] hcount_nxt, vcount_nxt;
    logic hsync_nxt, hblnk_nxt, vsync_nxt, vblnk_nxt;
    logic [11:0] rgb_nxt;

    //clock sync block
    always_ff @(posedge clk) begin
        x_pos_sync <= x_pos;
        y_pos_sync <= y_pos;
    end


    MouseDisplay u_MouseDisplay (
        .pixel_clk(clk),
        .xpos(x_pos_sync),     
        .ypos(y_pos_sync),     

        .hcount(in.hcount),   
        .vcount(in.vcount),   
        .blank(in.vblnk | in.hblnk),   

        .rgb_in(in.rgb),

        .rgb_out(rgb_nxt),

        .enable_mouse_display_out()
    );

    always_ff @(posedge clk) begin : delay_1_signals_blk
        if(rst) begin
            hsync_nxt <= '0;
            vsync_nxt <= '0;

            hblnk_nxt <= '0;
            vblnk_nxt <= '0;

            hcount_nxt <= '0;
            vcount_nxt <= '0;
        end
        else begin
            hsync_nxt <= in.hsync;
            vsync_nxt <= in.vsync;

            hblnk_nxt <= in.hblnk;
            vblnk_nxt <= in.vblnk; 

            hcount_nxt <= in.hcount;
            vcount_nxt <= in.vcount;
        end
    end

    always_ff @(posedge clk) begin : output_signals_blk
        if(rst) begin
            out.hsync <= '0;
            out.vsync <= '0;

            out.hblnk <= '0;
            out.vblnk <= '0;

            out.hcount <= '0;
            out.vcount <= '0;

            out.rgb <= '0;
        end
        else begin
            out.hsync <= hsync_nxt;
            out.vsync <= vsync_nxt;

            out.hblnk <= hblnk_nxt;
            out.vblnk <= vblnk_nxt; 

            out.hcount <= hcount_nxt;
            out.vcount <= vcount_nxt;

            out.rgb <= rgb_nxt;
        end
    end


endmodule
