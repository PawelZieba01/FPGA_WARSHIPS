/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Modified by:
 * 2023 Paweł Zięba  
 * 
 * Description:
 * Draw background.
 */


`timescale 1 ns / 1 ps

module draw_bg (
    input  logic clk,
    input  logic rst,

    vga_if.in in,
    vga_if.out out
);


import vga_pkg::*;


/**
 * Local variables and signals
 */

logic [11:0] rgb_nxt;


/**
 * Internal logic
 */

always_ff @(posedge clk) begin : bg_ff_blk
    if (rst) begin
        out.vcount <= '0;
        out.vsync  <= '0;
        out.vblnk  <= '0;
        out.hcount <= '0;
        out.hsync  <= '0;
        out.hblnk  <= '0;
        out.rgb    <= '0;
    end else begin
        out.vcount <= in.vcount;
        out.vsync  <= in.vsync;
        out.vblnk  <= in.vblnk;
        out.hcount <= in.hcount;
        out.hsync  <= in.hsync;
        out.hblnk  <= in.hblnk;
        out.rgb    <= rgb_nxt;
    end
end

always_comb begin : bg_comb_blk
    if (in.vblnk || in.hblnk) begin             // Blanking region:
        rgb_nxt = 12'h0_0_0;                    // - make it it black.
    end else begin                              // Active region:
        if (in.vcount == 0)                     // - top edge:
            rgb_nxt = 12'hf_f_0;                // - - make a yellow line.
        else if (in.vcount == VER_PIXELS - 1)   // - bottom edge:
            rgb_nxt = 12'hf_0_0;                // - - make a red line.
        else if (in.hcount == 0)                // - left edge:
            rgb_nxt = 12'h0_f_0;                // - - make a green line.
        else if (in.hcount == HOR_PIXELS - 1)   // - right edge:
            rgb_nxt = 12'h0_0_f;                // - - make a blue line.

        //My letters
        //P
        else if(in.vcount >= 124    &&    in.vcount <= 474    &&    in.hcount >= 64    &&    in.hcount <= 154) rgb_nxt = 12'ha_a_a;
        else if(in.vcount >= 124    &&    in.vcount <= 199    &&    in.hcount >= 155    &&    in.hcount <= 244) rgb_nxt = 12'ha_a_a;
        else if(in.vcount >= 259    &&    in.vcount <= 334    &&    in.hcount >= 155    &&    in.hcount <= 244) rgb_nxt = 12'ha_a_a;
        else if(in.vcount >= 124    &&    in.vcount <= 334    &&    in.hcount >= 245    &&    in.hcount <= 334) rgb_nxt = 12'ha_a_a;
        //Z
        else if(in.vcount >= 124    &&    in.vcount <= 214    &&    in.hcount >= 464    &&    in.hcount <= 734) rgb_nxt = 12'ha_a_a;
        else if(in.vcount >= 384    &&    in.vcount <= 474    &&    in.hcount >= 464    &&    in.hcount <= 734) rgb_nxt = 12'ha_a_a;
        else if(in.vcount >= 215    &&    in.vcount <= 274    &&    in.hcount >= 644    &&    in.hcount <= 734) rgb_nxt = 12'ha_a_a;
        else if(in.vcount >= 269    &&    in.vcount <= 329    &&    in.hcount >= 553    &&    in.hcount <= 643) rgb_nxt = 12'ha_a_a;
        else if(in.vcount >= 324    &&    in.vcount <= 383    &&    in.hcount >= 464    &&    in.hcount <= 554) rgb_nxt = 12'ha_a_a;

        else                                    // The rest of active display pixels:
            rgb_nxt = 12'h8_8_8;                // - fill with gray.
    end
end

endmodule
