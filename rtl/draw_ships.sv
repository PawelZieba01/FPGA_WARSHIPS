//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   draw_ships
 Author:        Pawel Zieba
 Version:       1.0
 Last modified: 2023-07-29
 Coding style: Xilinx recommended + ANSI ports
 Description:  VGA module for drawing ships on grid.
 */
//////////////////////////////////////////////////////////////////////////////

 module draw_ships #(
    parameter X_POS = 0,
              Y_POS = 0
 )(
    input logic clk,
    input logic rst,
    input logic [1:0] grid_status,
    vga_if.in in,

    output logic [7:0] grid_addr,
    vga_if.out out
 );

    localparam GRID_ROWS = 12;
    localparam GRID_COLUMNS = 12;
    localparam GRID_ELEMENT_HEIGHT = 32;
    localparam GRID_ELEMENT_WIDTH = 32;
    localparam GRID_BORDER_WIDTH = 2;

    logic [7:0] grid_addr_nxt;
    logic [11:0] rgb_nxt;
    vga_if vga_delayed();

    logic [10:0] ships_origin_x;
    logic [10:0] ships_origin_y;

    assign ships_origin_x = {vga_delayed.hcount-11'(X_POS)};
    assign ships_origin_y = {vga_delayed.vcount-11'(Y_POS)};

    always_ff @(posedge clk) begin : output_signals_registers_blk
        if(rst) begin
            grid_addr <= '0;
            out.hcount <= '0;
            out.vcount <= '0;
            out.hblnk <= '0;
            out.vblnk <= '0;
            out.hsync <= '0;
            out.vsync <= '0;
            out.rgb <= '0;
        end
        else begin
            grid_addr <= grid_addr_nxt;
            out.hcount <= vga_delayed.hcount;
            out.vcount <= vga_delayed.vcount;
            out.hblnk <= vga_delayed.hblnk;
            out.vblnk <= vga_delayed.vblnk;
            out.hsync <= vga_delayed.hsync;
            out.vsync <= vga_delayed.vsync;
            out.rgb <= rgb_nxt;
        end
    end


    always_comb begin : grid_addr_nxt_blk
        grid_addr_nxt = 8'({in.hcount[8:5], in.vcount[8:5]});
    end


    always_comb begin : rgb_nxt_blk
        //if vga pixel is in grid space 
        if((ships_origin_x[10:5] >= 0 && ships_origin_x[10:5] < GRID_COLUMNS)   &&
            (ships_origin_y[10:5] >= 0 && ships_origin_y[10:5] < GRID_ROWS)) begin
                //draw ships if pixel is between grid lines
                if((ships_origin_x[4:0] >= 0+GRID_BORDER_WIDTH && ships_origin_x[4:0] < GRID_ELEMENT_WIDTH)   &&
                    (ships_origin_y[4:0] >= 0+GRID_BORDER_WIDTH && ships_origin_y[4:0] < GRID_ELEMENT_HEIGHT)) begin
                        rgb_nxt = 12'h0_F_0;    //print green color for test
                    end
                    else begin
                        rgb_nxt = vga_delayed.rgb;
                    end
            end
            else begin
                rgb_nxt = vga_delayed.rgb;
            end
    end


    delay #(.WIDTH(38), .CLK_DEL(3)) u_delay_vga(    
        .clk,
        .rst,
        .din({in.hcount, in.vcount, in.hsync, in.vsync, in.hblnk, in.vblnk ,in.rgb}),
        .dout({vga_delayed.hcount, vga_delayed.vcount, vga_delayed.hsync, vga_delayed.vsync, vga_delayed.hblnk, vga_delayed.vblnk ,vga_delayed.rgb})
    );

endmodule