/**
 * 2023  AGH University of Science and Technology
 * Paweł Zięba & Natalia Kapuscinska
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

    output logic [15:0] led,

    input logic ready2,
    input logic hit2,
    output logic ready1,
    output logic hit1,
    input logic [7:0] ship_cords_in,
    output logic [7:0] ship_cords_out,
    
    output logic [6:0] sseg,
    output logic [3:0] an,

    output logic vs,
    output logic hs,
    output logic [3:0] r,
    output logic [3:0] g,
    output logic [3:0] b
);

    import project_cfg_pkg::*;

    /**
     * Local variables and signals
     */

    //mouse signals
    logic [11:0] mouse_x_pos, mouse_y_pos;
    logic mouse_left, mouse_left_db;

  
    //start button signals
    logic [11:0] rgb_pixel_start_btn;
    logic [13:0] rgb_pixel_addr_start_btn;
    logic  start_btn;
    logic  start_btn_en;

  
    //my board memory and draw ships signals
    logic [7:0] my_board_read2_addr, my_board_read1_write1_addr;
    logic [1:0] my_board_read2_data, my_board_read1_data, my_board_write1_data;
    logic my_board_write_nread;

  
    //enemy board memory and draw ships signals
    logic [7:0] enemy_board_read2_addr, enemy_board_read1_write1_addr;
    logic [1:0] enemy_board_read2_data, enemy_board_read1_data, enemy_board_write1_data;
    logic enemy_board_write_nread;

  
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

  
    //ship counters
    logic [3:0] en_ctr;
    logic [3:0] my_ctr;

  
    //coordinates signals from player_ctrl
    logic [7:0] my_grid_cords, en_grid_cords;

  
    //fsm state for debug
    logic [3:0] state_fsm;

  
    //led debug
    assign led[3:0] = state_fsm;
    assign led[11:4] = 8'(my_ctr);
    assign led[15] = start_btn_en;
    assign led[14] = start_btn;
    assign led[13] = mouse_left;
    assign led[12] = ready2;
  
  
    //7seg display signals
    logic [3:0]num_1 ;
    logic [3:0]num_2 ;
    assign num_1 = my_ctr;  //numboer of left ships (my)
    assign num_2 = en_ctr;  //numboer of left ships (enemy)

    
    // VGA interfaces
    vga_if tim_if();
    vga_if bg_if();
    vga_if start_btn_if();
    vga_if my_grid_if();
    vga_if enemy_grid_if();
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
    //----------------------------------------MAIN_FSM--------------------------------------------
    main_fsm u_main_fsm(
        .clk(control_clk),
        .rst,
        .en_ctr,
        .my_ctr,

        .en_grid_cords,
        .en_mem_addr(enemy_board_read1_write1_addr),
        .en_mem_data_in(enemy_board_read1_data),
        .en_mem_data_out(enemy_board_write1_data),
        .en_mem_w_nr(enemy_board_write_nread),
        
        .my_grid_cords,
        .my_mem_addr(my_board_read1_write1_addr),
        .my_mem_data_in(my_board_read1_data),
        .my_mem_data_out(my_board_write1_data),
        .my_mem_w_nr(my_board_write_nread),

        .ready1,
        .ready2,

        .hit1,
        .hit2,

        .ship_cords_in,
        .ship_cords_out,
        .start_btn,
        .start_btn_en,

        .state_out(state_fsm),

        .en_turn(),
        .my_turn(),
        .lose(),
        .win()
    );

    //----------------------------------------PLAYER CONTROL--------------------------------------------
    player_ctrl u_player_ctrl(
        .clk(control_clk),
        .rst,
        .enemy_cor(en_grid_cords),
        .player_cor(my_grid_cords),
        .start_btn,
        .left(mouse_left_db),
        .x_pos(mouse_x_pos),
        .y_pos(mouse_y_pos)
    );


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
    #(  .RECT_HEIGHT(SBtn_HEIGHT),
        .RECT_WIDTH(SBtn_WIDITH)
    )
    u_draw_start_btn(
        .clk(vga_clk),
        .rst,
        .enable(start_btn_en),
        .x_pos(12'(SBtn_XPOS)),
        .y_pos(12'(SBtn_YPOS)),
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
    draw_grid #(
        .X_POS(PLAYER_POS),
        .Y_POS(GRID_YPOS)
    )
    u_draw_my_grid(
        .clk(vga_clk),
        .rst,
        .in(start_btn_if),
        .out(my_grid_if)
    );

    draw_ships #(.X_POS(PLAYER_POS), .Y_POS(GRID_YPOS))
        u_draw_my_ships(
            .clk(vga_clk),
            .rst,
            .in(my_grid_if),
            .grid_status(my_board_read2_data),
            .out(my_ships_if),
            .grid_addr(my_board_read2_addr)
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
        .rst,
        .clk2(vga_clk),
        .clk1(control_clk),
        .addr2(my_board_read2_addr),
        .addr1(my_board_read1_write1_addr),
        .read_data2(my_board_read2_data),
        .write_data1(my_board_write1_data),
        .read_data1(my_board_read1_data),
        .w_nr(my_board_write_nread)
    );

    //---------------------------------------ENEMY_SHIPS--------------------------------------------
    draw_grid #(
        .X_POS(ENEMY_POS),
        .Y_POS(GRID_YPOS)
    )
    u_draw_enemy_grid(
        .clk(vga_clk),
        .rst,
        .in(my_ships_if),
        .out(enemy_grid_if)
    );

    draw_ships #(.X_POS(ENEMY_POS), .Y_POS(GRID_YPOS))
        u_draw_enemy_ships(
            .clk(vga_clk),
            .rst,
            .in(enemy_grid_if),
            .grid_status(enemy_board_read2_data),
            .out(enemy_ships_if),
            .grid_addr(enemy_board_read2_addr)
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
        .rst,
        .clk2(vga_clk),
        .clk1(control_clk),
        .addr2(enemy_board_read2_addr),
        .addr1(enemy_board_read1_write1_addr),
        .read_data2(enemy_board_read2_data),
        .write_data1(enemy_board_write1_data),
        .read_data1(enemy_board_read1_data),
        .w_nr(enemy_board_write_nread)
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

    debounce u_mouse_debounce(
        .clk(control_clk),
        .reset(rst),
        .sw(mouse_left),
        .db_level(),
        .db_tick(mouse_left_db)
    );


//---------------------------------------------7_SEG DISPLAY---------------------------------------//
    disp_hex_mux u_disp_hex_mux(
    .clk(vga_clk),
    .rst,
    .num_1,
    .num_2,
    .sseg,
    .an
   );
endmodule