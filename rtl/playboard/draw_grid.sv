/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Natalia Kapuscinska
 *
 * Description:
 * Draws grid which is a playboard for the game.
 */


 `timescale 1 ns / 1 ps

 module draw_grid #(parameter 
    X_POS = 0,
    Y_POS = 0
    ) 
    (
     input  logic clk,
     input  logic rst,
     vga_if.in in,
 
     vga_if.out out
 );
 
 
 import pb_cfg_pkg::*;
 
 
 /**
  * Local variables and signals
  */
 
 logic [11:0] rgb_nxt;
 logic [10:0] vcount;
 logic [10:0] hcount;

 assign hcount = in.hcount-11'(X_POS);
 assign vcount = in.vcount-11'(Y_POS);
 
 
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
     end
     else begin
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
         if ((vcount >= 0) && (hcount >= 0) && (vcount < GRID_SIZE+GRID_BORDER_WIDTH) && (hcount < GRID_SIZE+GRID_BORDER_WIDTH)) begin  
            if(((vcount[4:0] >= 0)&&(vcount[4:0] < GRID_BORDER_WIDTH)) || ((hcount[4:0] >= 0)&&(hcount[4:0] < GRID_BORDER_WIDTH )))begin        
             rgb_nxt = 12'h0_0_0;  //black
            end
            else begin
                rgb_nxt = in.rgb;
            end
        end
        else begin
            rgb_nxt = in.rgb;
        end         
     end
    end
 endmodule
 