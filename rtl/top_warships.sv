/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * 2023  AGH University of Science and Technology
 * MTM UEC2
 * Piotr Kaczmarczyk
 * 
 * Modified by:
 * 2023 Paweł Zięba  
 *
 * Description:
 * The project top module.
 */

`timescale 1 ns / 1 ps

module top_warships (
    input logic vga_clk,
    input logic clk100MHz,
    input logic rst,

    inout logic ps2_clk,
    inout logic ps2_data,

    output logic vs,
    output logic hs,
    output logic [3:0] r,
    output logic [3:0] g,
    output logic [3:0] b
);


    /**
     * Local variables and signals
     */

    // Mouse position signals
    logic [11:0] x_pos, y_pos;
    logic [11:0] x_pos_ctl, y_pos_ctl;

    //rom_pixel
    logic [11:0] pixel_addr;
    logic [11:0] rgb_pixel;

    //font_signals
    logic [7:0] char_pixels;
    logic [7:0] char_xy;
    logic [3:0] char_line;
    logic [6:0] char_code;


    logic mouse_left;

    // VGA interfaces
    vga_if tim_if();
    vga_if bg_if();
    vga_if rect_if();
    vga_if mouse_if();
    vga_if font_if();


    /**
     * Signals assignments
     */

    assign vs = font_if.vsync;
    assign hs = font_if.hsync;
    assign {r,g,b} = font_if.rgb;


    /**
     * Submodules instances
     */

    vga_timing u_vga_timing (
        .clk(vga_clk),
        .rst,
        .out(tim_if)
    );

    draw_bg u_draw_bg (
        .clk(vga_clk),
        .rst,

        .in(tim_if),
        .out(bg_if)
    );

    draw_rect u_draw_rect (
        .clk(vga_clk),
        .rst,

        .x_pos(x_pos_ctl),
        .y_pos(y_pos_ctl),

        .rgb_pixel,
        .pixel_addr,

        .in(bg_if),
        .out(rect_if)
    );

    logic clk_50Hz;

    simple_clk_div u_simple_clk_div (
        .clk(vga_clk),
        .clk_out(clk_50Hz)
    );

    draw_rect_ctl u_draw_rect_ctl (
        .clk(clk_50Hz),
        .rst(rst),

        .mouse_xpos(x_pos),
        .mouse_ypos(y_pos),
        .mouse_left(mouse_left),
        .xpos(x_pos_ctl),
        .ypos(y_pos_ctl),
        .stop()
    );
    

    image_rom u_image_rom (
        .clk(vga_clk),
        .address(pixel_addr),
        .rgb(rgb_pixel)
    );

    MouseCtl u_MouseCtl (
        .ps2_clk,
        .ps2_data,

        .clk(clk100MHz),
        .rst,

        .xpos(x_pos),
        .ypos(y_pos),
        .zpos(),
        .left(mouse_left),
        .middle(),
        .right(),
        .new_event(),

        .value(12'b0),
        .setx(1'b0),
        .sety(1'b0),
        .setmax_x(1'b0),
        .setmax_y(1'b0)
    );

    draw_mouse u_draw_mouse (
        .clk(vga_clk),
        .rst,

        .x_pos(x_pos),
        .y_pos(y_pos),

        .in(rect_if),
        .out(mouse_if)
    );

    draw_rect_char #(.X_POS(48), .Y_POS(64)) u_draw_rect_char (
        .clk(vga_clk),
        .rst,

        .char_pixels(char_pixels),
        .char_line(char_line),
        .char_xy(char_xy),

        .in(mouse_if),
        .out(font_if)
    );

    font_rom u_font_rom (
        .clk(vga_clk),
        .char_line_pixels(char_pixels),
        .addr({char_code, char_line})
    );

    char_rom_16x16 u_char_rom_16x16 (
        .clk(vga_clk),
        .char_xy(char_xy),
        .char_code(char_code)
    );

endmodule
