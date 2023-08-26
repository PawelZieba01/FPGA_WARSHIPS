/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Paweł Zięba  
 * 
 * Description:
 * Text drawing module.
 */

 `timescale 1 ns / 1 ps

// Two text size:
// - 0 -> char 8x16
// - 1 -> char 16x32
module draw_rect_char 
#(
    parameter X_POS, Y_POS, TEXT_SIZE=0
)
(
    input logic clk,
    input logic rst,

    input logic [7:0] char_pixels,
    output logic [3:0] char_line,
    output logic [7:0] char_xy,

    vga_if.in in,
    vga_if.out out
);
    import text_cfg_pkg::*;

    logic [3:0] char_line_delayed;
    logic [7:0] char_xy_nxt;

    logic [2:0] pixel_in_line;

    logic [11:0] rgb_nxt;
    vga_if vga_delayed();


    delay #(.WIDTH(38), .CLK_DEL(3)) u_delay_vga(    
        .clk,
        .rst,
        .din({in.hcount, in.vcount, in.hsync, in.vsync, in.hblnk, in.vblnk ,in.rgb}),
        .dout({vga_delayed.hcount, vga_delayed.vcount, vga_delayed.hsync, vga_delayed.vsync, vga_delayed.hblnk, vga_delayed.vblnk ,vga_delayed.rgb})
    );

    delay #(.WIDTH(4), .CLK_DEL(1)) u_delay_char_line(    
        .clk,
        .rst,
        .din(4'((in.vcount - Y_POS)>>TEXT_SIZE)),
        .dout(char_line_delayed)
    );

    always_ff @(posedge clk) begin : output_signal_blk
        if(rst) begin
            out.hcount  <= '0;
            out.vcount  <= '0;
            out.hblnk   <= '0;
            out.vblnk   <= '0;
            out.hsync   <= '0;
            out.vsync   <= '0;
            out.rgb     <= '0;

            char_line   <= '0;
            char_xy     <= '0;
        end
        else begin
            out.hcount  <= vga_delayed.hcount;
            out.vcount  <= vga_delayed.vcount;
            out.hblnk   <= vga_delayed.hblnk;
            out.vblnk   <= vga_delayed.vblnk;
            out.hsync   <= vga_delayed.hsync;
            out.vsync   <= vga_delayed.vsync;
            out.rgb     <= rgb_nxt;

            char_line   <= char_line_delayed;
            char_xy     <= char_xy_nxt;
        end
    end

    assign char_xy_nxt = {4'((in.vcount - Y_POS) >> (4+TEXT_SIZE)), 4'((in.hcount - X_POS) >> (3+TEXT_SIZE))};
    assign pixel_in_line = 3'((vga_delayed.hcount - X_POS)>>TEXT_SIZE);


    always_comb begin : rgb_nxt_blk
        if(vga_delayed.hblnk || vga_delayed.vblnk) begin
            rgb_nxt = 12'b0_0_0;
        end
        else begin
            if((vga_delayed.hcount >= X_POS && vga_delayed.hcount < (FONT_RECT_WIDTH<<TEXT_SIZE) + X_POS)    &&    (vga_delayed.vcount >= Y_POS && vga_delayed.vcount < (FONT_RECT_HEIGHT<<TEXT_SIZE) + Y_POS))   begin
                if(char_pixels[CHAR_BIT_LENGTH-1 - pixel_in_line] == 1'b1) begin
                    rgb_nxt = TEXT_COLOR;
                end
                else begin
                    rgb_nxt = vga_delayed.rgb;
                end
            end
            else begin
                rgb_nxt = vga_delayed.rgb;
            end
        end
    end

endmodule
