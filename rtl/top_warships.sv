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
 * FPGA_WARSHIPS_2023
 */

`timescale 1 ns / 1 ps

module top_warships (
    input logic vga_clk,
    input logic mouse_clk,
    input logic control_clk,
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
    logic mouse_left;

    //rom_pixel
    logic [13:0] pixel_addr;
    logic [11:0] rgb_pixel;

    logic [11:0] rgb_pixel_start_btn;
    logic [13:0] rgb_pixel_addr_start_btn;

    //font_signals
    logic [7:0] char_pixels;
    logic [7:0] char_xy;
    logic [3:0] char_line;
    logic [6:0] char_code;

    //my board memory and draw ships signals
    logic [7:0] my_board_read_addr, my_board_write_addr;
    logic [1:0] my_board_read_data, my_board_write_data;
    logic my_board_write_enable;
    

    // VGA interfaces
    vga_if tim_if();
    vga_if bg_if();
    vga_if start_btn_if();
    vga_if ships_if();
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

    //---------------------------------------BACKGROUND------------------------------------------

    draw_bg u_draw_bg (
        .clk(vga_clk),
        .rst,

        .in(tim_if),
        .out(bg_if)
    );

    //--------------------------------------START BUTTON-----------------------------------------

    draw_rect 
    #(  .RECT_HEIGHT(64),
        .RECT_WIDTH(128)
    )
    u_draw_start_btn(
        .clk(vga_clk),
        .rst,
        .x_pos(12'd200),
        .y_pos(12'd200),
        .in(bg_if),
        .out(start_btn_if),

        .rgb_pixel(rgb_pixel_start_btn),
        .pixel_addr(rgb_pixel_addr_start_btn)
    );
    
    image_rom #(.IMG_DATA_PATH("../../rtl/rect/start_btn_png.dat"))
    u_image_rom_btn_start(
        .clk(vga_clk),
        .address(rgb_pixel_addr_start_btn),
        .rgb(rgb_pixel_start_btn)
    );    

    //-----------------------------------------MY_SHIPS----------------------------------------------

    draw_ships #(.X_POS(500), .Y_POS(200))
        u_draw_my_ships(
            .clk(vga_clk),
            .rst,
            .in(start_btn_if),
            .grid_status(my_board_read_data),
            .out(ships_if),
            .grid_addr(my_board_read_addr)
        );

    board_mem #(
        .DATA_WIDTH(2),
        .X_ADDR_WIDTH(4),
        .Y_ADDR_WIDTH(4),
        .X_SIZE(12),
        .Y_SIZE(12)
    )
    u_my_board_mem
    (
        .read_clk(vga_clk),
        .write_clk(control_clk),
        .read_addr(my_board_read_addr),
        .write_addr(my_board_write_addr),
        .read_data(my_board_read_data),
        .write_data(my_board_write_data),
        .write_enable(my_board_write_enable)
    );

    //--------------------------------------DRAW LOGO AGH-------------------------------------------

    draw_rect u_draw_rect (
        .clk(vga_clk),
        .rst,

        .x_pos(x_pos_ctl),
        .y_pos(y_pos_ctl),

        .rgb_pixel,
        .pixel_addr,

        .in(ships_if),
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

    //---------------------------------------MOUSE----------------------------------------------

    MouseCtl u_MouseCtl (
        .ps2_clk,
        .ps2_data,

        .clk(mouse_clk),
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

    //-------------------------------------DRAW TEXT-----------------------------------------------

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

    //-------------------------------------------------------------------------------------------

endmodule
