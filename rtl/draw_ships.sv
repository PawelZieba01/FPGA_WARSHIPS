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
    vga_if vga_delayed;
    vga_if vga_nxt;

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
            out.rgb <= vga_delayed.rgb;
        end
    end


    always_comb begin : grid_addr_nxt_blk

    end


    always_comb begin : vga_if_nxt_blk

    end

    always_comb begin : rgb_nxt_blk

    end


    delay #(.WIDTH(38), .CLK_DEL(3)) u_delay_vga(    
        .clk,
        .rst,
        .din({in.hcount, in.vcount, in.hsync, in.vsync, in.hblnk, in.vblnk ,in.rgb}),
        .dout({vga_delayed.hcount, vga_delayed.vcount, vga_delayed.hsync, vga_delayed.vsync, vga_delayed.hblnk, vga_delayed.vblnk ,vga_delayed.rgb})
    );

endmodule