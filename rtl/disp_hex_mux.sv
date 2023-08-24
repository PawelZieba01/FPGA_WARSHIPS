// author Natalia Kapuścńska
module disp_hex_mux(
      input wire clk, rst,
      input wire[0:3] num_1, num_2,
      output reg [3:0] an,  // enable 1-out-of-4 asserted low
      output reg [7:0] sseg // led segments
   );

   localparam [7:0] sseg_nxt;
   localparam [3:0] an_nxt;
   localparam[7:0]h_0, h_1, h_2, h_3, h_in;
   localparam[1:0]count;

   assign count = count+1;


   always_ff @(posedge clk) begin : bg_ff_blk
      if (rst) begin
         an <= 0;
         sseg <= 7'b1111111;
      end else begin
         an <= an_nxt;
         sseg <= sseg_nxt;
      end
  end


   always_comb begin
      if(num_1>=10)begin
         h_0 = 1;
         h_1 = num_1 - 10;
      end
      else begin 
         h_0 = 0;
         h_1 = num_1;
      end
   end

   always_comb begin
      if(num_2>=10)begin
         h_0 = 1;
         h_1 = num_2 - 10;
      end
      else begin
         h_0 = 0;
         h_1 = num_2;
      end
   end

   always_comb begin
      case(count)
         2'b00 :
            h_in = h_0;
         2'b01 :
            h_in = h_1;
         2'b10 : 
            h_in = h_2;
         2'b11: 
            h_in = h_3;
         default:
            h_in = 0;
      endcase

   end


   always_comb begin
      case(h_in)
         4'h0: sseg[6:0] = 7'b1000000;
         4'h1: sseg[6:0] = 7'b1111001;
         4'h2: sseg[6:0] = 7'b0100100;
         4'h3: sseg[6:0] = 7'b0110000;
         4'h4: sseg[6:0] = 7'b0011001;
         4'h5: sseg[6:0] = 7'b0010010;
         4'h6: sseg[6:0] = 7'b0000010;
         4'h7: sseg[6:0] = 7'b1111000;
         4'h8: sseg[6:0] = 7'b0000000;
         4'h9: sseg[6:0] = 7'b0010000;
         4'ha: sseg[6:0] = 7'b0001000;
         4'hb: sseg[6:0] = 7'b0000011;
         4'hc: sseg[6:0] = 7'b1000110;
         4'hd: sseg[6:0] = 7'b0100001;
         4'he: sseg[6:0] = 7'b0000110;
         default: 
               sseg[6:0] = 7'b0001110;  //4'hf
     endcase
   end

endmodule