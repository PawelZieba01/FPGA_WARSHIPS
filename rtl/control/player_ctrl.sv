/**
 *
 * Author : Natalia Kapuscińska
 * AGH university
 * 2023  
 *
 * Description:
 * Mouse controller, this module checks if user choose any of the interfce options
 */

 `timescale 1 ns / 1 ps

 module player_ctrl(
    input logic clk,
    input logic rst,

    input logic [11:0] x_pos,
    input logic [11:0] y_pos,
    input logic left,

    output logic start_btn,
    output logic [7:0] player_cor,  //player board coordinates
    output logic [7:0] enemy_cor    //enemy board coordinates
    

 );

   import project_cfg_pkg::*;

   logic start_nxt;
   logic [7:0]pc_nxt;
   logic [7:0]ec_nxt;

   logic [11:0]xpos_enemy;
   logic [11:0]xpos_player;
   logic [11:0]ypos;

   assign xpos_player = x_pos -  PLAYER_POS;
   assign xpos_enemy = x_pos - ENEMY_POS;
   assign ypos = y_pos - GRID_YPOS;

   always_ff @(posedge clk) begin
      if(rst) begin
         start_btn <= 1'b0;
         player_cor <= 8'hff;
         enemy_cor <= 8'hff;
      end
      else begin
         start_btn <= start_nxt;
         player_cor <= pc_nxt;
         enemy_cor <= ec_nxt;
      end

      end

      //start button//
      always_comb begin
         if((x_pos >= SBtn_XPOS)&&(x_pos < SBtn_XPOS+SBtn_WIDITH)&&(y_pos >= SBtn_YPOS)&&(y_pos < SBtn_YPOS+SBtn_HEIGHT))begin
            if(left)begin
               start_nxt = 1'b1;
            end
            else begin 
               start_nxt = 1'b0;
            end
         end
         else begin
            start_nxt = 0;
         end
      end

      //player board//
      always_comb begin 
         if((x_pos >= PLAYER_POS)&&(x_pos <= PLAYER_POS + GRID_SIZE)&&(y_pos >= GRID_YPOS)&&(y_pos<= GRID_YPOS+GRID_SIZE)&&(left))begin
            pc_nxt = {xpos_player[8:5],ypos[8:5]};
         end
         else begin 
            pc_nxt = 8'hff;
         end
      end
      

      //enemy board//
      always_comb begin
         if((x_pos >= ENEMY_POS)&&(x_pos <= ENEMY_POS + GRID_SIZE)&&(y_pos >= GRID_YPOS)&&(y_pos <= GRID_YPOS+GRID_SIZE)&&(left))begin 
            ec_nxt = {xpos_enemy[8:5],ypos[8:5]};
         end
         else begin 
            ec_nxt = 8'hff;
         end
      end


 endmodule