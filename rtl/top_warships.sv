/**
 * 2023  AGH University of Science and Technology
 * Paweł Zięba 
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

    //mouse signals
    logic [11:0] mouse_x_pos, mouse_y_pos;
    logic mouse_left;

    //start button signals
    logic [11:0] rgb_pixel_start_btn;
    logic [13:0] rgb_pixel_addr_start_btn;
    logic  start_btn_enable;

    //my board memory and draw ships signals
    logic [7:0] my_board_read_addr, my_board_write_addr;
    logic [1:0] my_board_read_data, my_board_write_data;
    logic my_board_write_enable;

    //enemy board memory and draw ships signals
    logic [7:0] enemy_board_read_addr, enemy_board_write_addr;
    logic [1:0] enemy_board_read_data, enemy_board_write_data;
    logic enemy_board_write_enable;

    //text my ships signals
    logic [7:0] ms_char_pixels;
    logic [3:0] ms_char_line;
    logic [7:0] ms_char_xy;
    logic [6:0] ms_char_code;

    //text ENEMY ships signals
    logic [7:0] e_char_pixels;
    logic [3:0] e_char_line;
    logic [7:0] e_char_xy;
    logic [6:0] e_char_code;
    
    // VGA interfaces
    vga_if tim_if();
    vga_if bg_if();
    vga_if start_btn_if();
    vga_if my_ships_if();
    vga_if enemy_ships_if();
    vga_if text_my_ships_if();
    vga_if text_e_ships_if();
    vga_if mouse_if();


    /**
     * Signals assignments
     */

    assign vs = mouse_if.vsync;
    assign hs = mouse_if.hsync;
    assign {r,g,b} = mouse_if.rgb;


    /**
     * Submodules instances
     */

    //----------------------------------------TIMMING--------------------------------------------
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
        .enable(1'b1),
        .x_pos(12'd448),
        .y_pos(12'd40),
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
    draw_ships #(.X_POS(100), .Y_POS(200))
        u_draw_my_ships(
            .clk(vga_clk),
            .rst,
            .in(start_btn_if),
            .grid_status(my_board_read_data),
            .out(my_ships_if),
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

    //---------------------------------------ENEMY_SHIPS--------------------------------------------
    draw_ships #(.X_POS(538), .Y_POS(200))
        u_draw_enemy_ships(
            .clk(vga_clk),
            .rst,
            .in(my_ships_if),
            .grid_status(enemy_board_read_data),
            .out(enemy_ships_if),
            .grid_addr(enemy_board_read_addr)
        );

    board_mem #(
        .DATA_WIDTH(2),
        .X_ADDR_WIDTH(4),
        .Y_ADDR_WIDTH(4),
        .X_SIZE(12),
        .Y_SIZE(12)
    )
    u_enemy_board_mem
    (
        .read_clk(vga_clk),
        .write_clk(control_clk),
        .read_addr(enemy_board_read_addr),
        .write_addr(enemy_board_write_addr),
        .read_data(enemy_board_read_data),
        .write_data(enemy_board_write_data),
        .write_enable(enemy_board_write_enable)
    );
    
    //----------------------------------DRAW TEXT (MY BOARD)--------------------------------------------
    // for ready project - change text position - issue from e800570 commit
    draw_rect_char #(.X_POS(100), .Y_POS(172), .TEXT_SIZE(1)) u_draw_text_my_ships (
        .clk(vga_clk),
        .rst,

        .char_pixels(ms_char_pixels),
        .char_line(ms_char_line),
        .char_xy(ms_char_xy),

        .in(enemy_ships_if),
        .out(text_my_ships_if)
    );

    font_rom u_my_font_rom (
        .clk(vga_clk),
        .char_line_pixels(ms_char_pixels),
        .addr({ms_char_code, ms_char_line})
    );

    char_rom_16x16 #(.TEXT("MY BOARD")) u_char_my_rom_16x16 (
        .clk(vga_clk),
        .char_xy(ms_char_xy),
        .char_code(ms_char_code)
    );

    //----------------------------------DRAW TEXT (ENEMY BOARD)--------------------------------------------
    // for ready project - change text position - issue from e800570 commit
    draw_rect_char #(.X_POS(538), .Y_POS(172), .TEXT_SIZE(1)) u_draw_text_enemy_ships (
        .clk(vga_clk),
        .rst,

        .char_pixels(e_char_pixels),
        .char_line(e_char_line),
        .char_xy(e_char_xy),

        .in(text_my_ships_if),
        .out(text_e_ships_if)
    );

    font_rom u_e_font_rom (
        .clk(vga_clk),
        .char_line_pixels(e_char_pixels),
        .addr({e_char_code, e_char_line})
    );

    char_rom_16x16 #(.TEXT("ENEMY BOARD")) u_char_e_rom_16x16 (
        .clk(vga_clk),
        .char_xy(e_char_xy),
        .char_code(e_char_code)
    );


    //---------------------------------------MOUSE----------------------------------------------
    MouseCtl u_MouseCtl (
        .ps2_clk,
        .ps2_data,

        .clk(mouse_clk),
        .rst,

        .xpos(mouse_x_pos),
        .ypos(mouse_y_pos),
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

        .x_pos(mouse_x_pos),
        .y_pos(mouse_y_pos),

        .in(text_e_ships_if),
        .out(mouse_if)
    );


endmodule
