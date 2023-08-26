////////////////////////////////////////////////////////
// Author: Natalia Kapuścńska                         //
// Module name: disp_hex_mux                          //
//                                                    //
// Description:                                       //
// This module converts two decimal numbers to format //
// for 7seg display                                   //
////////////////////////////////////////////////////////
module disp_hex_mux(
      input wire clk, rst,
      input wire[0:3] num_1, num_2,
      output reg [3:0] an,  // enable 1-out-of-4 asserted low
      output reg [6:0] sseg // led segments
   );

   logic [6:0] sseg_nxt;
   logic [3:0] an_nxt;
   logic [3:0]h_0, h_1, h_2, h_3, h_in;
   logic[16:0]count, count_nxt;

   assign count_nxt = count+1;


   always_ff @(posedge clk) begin : bg_ff_blk
      if (rst) begin
         an <= 0;
         sseg <= 7'b1111111;
         count <= count_nxt;
      end else begin
         an <= an_nxt;
         sseg <= sseg_nxt;
         count <= count_nxt;
      end
  end


   always_comb begin
      if(num_1>=10)begin
         h_3 = 1;
         h_2 = num_1 - 10;
      end
      else begin 
         h_3 = 0;
         h_2 = num_1;
      end
   end

   always_comb begin
      if(num_2>=10)begin
         h_1 = 1;
         h_0 = num_2 - 10;
      end
      else begin
         h_1 = 0;
         h_0 = num_2;
      end
   end

   always_comb begin
      case(count[15:14])
         2'b00 : begin 
            an_nxt = 4'b1110;
            h_in = h_0;
         end
         2'b01 : begin
            an_nxt = 4'b1101;
            h_in = h_1;
         end
         2'b10 : begin
            an_nxt = 4'b1011;
            h_in = h_2;
         end
         2'b11: begin
            h_in = h_3;
            an_nxt = 4'b0111;
         end
         default: begin
            h_in = 0;
            an_nxt = 4'b1111;
         end
      endcase

   end


   always_comb begin
      case(h_in)
         4'h0: sseg_nxt[6:0] = 7'b1000000;
         4'h1: sseg_nxt[6:0] = 7'b1111001;
         4'h2: sseg_nxt[6:0] = 7'b0100100;
         4'h3: sseg_nxt[6:0] = 7'b0110000;
         4'h4: sseg_nxt[6:0] = 7'b0011001;
         4'h5: sseg_nxt[6:0] = 7'b0010010;
         4'h6: sseg_nxt[6:0] = 7'b0000010;
         4'h7: sseg_nxt[6:0] = 7'b1111000;
         4'h8: sseg_nxt[6:0] = 7'b0000000;
         4'h9: sseg_nxt[6:0] = 7'b0010000;
         4'ha: sseg_nxt[6:0] = 7'b0001000;
         4'hb: sseg_nxt[6:0] = 7'b0000011;
         4'hc: sseg_nxt[6:0] = 7'b1000110;
         4'hd: sseg_nxt[6:0] = 7'b0100001;
         4'he: sseg_nxt[6:0] = 7'b0000110;
         default: 
               sseg_nxt[6:0] = 7'b0001110;  //4'hf
     endcase
   end

endmodule