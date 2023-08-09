/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Natalia Kapuscinska
 *
 * 
 * Description:
 * Draws grid witch is a playboard for the game.
 */


 `timescale 1 ns / 1 ps

localparam grid_size = 12;
localparam grid_width  = 32;
localparam line_width =  2;



 module draw_grid #(parameter 
    X_POS = 0,
    Y_POS = 0,
    ) 
    (
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
     if (in.vblnk || in.hblnk) begin            
         rgb_nxt = 12'h0_0_0;                    
     end 
     else begin                              
         if ((in.vcount >= X_POS) && (in.hcount >= Y_POS) && (in.vcount < X_POS+418) && (in.hcount < Y_POS+4180)) begin  
            if((X_POS+in.vcount[5:0] == 4'b00000;)||(X_POS+in.vcount[5:0] == 4'b00001)||(Y_POS+in.hcount[5:0] == 4'b00000)||(Y_POS+in.hcount[5:0] == ))begin        
             rgb_nxt = 12'hf_f_f;  
            end
            else begin
                rgb_nxt = in.rgb;
            end
         end
        end
         else begin
            rgb_nxt = in.rgb;
         end          // - fill with gray.
     end
 
 endmodule
 