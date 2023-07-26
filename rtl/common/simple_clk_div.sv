    /* -------------------------------------------------------------
     * Simple clock divider
     * input clk: 40MHz
     * output clk: 50Hz
     * -------------------------------------------------------------*/
    
module simple_clk_div (
    input logic clk,
    output logic clk_out
);

     logic [18:0] clk_div_ctr, clk_div_ctr_nxt;
     logic clk_out_nxt;
 
     always_ff @(posedge clk) begin : clk_div_blk
         // if(rst) begin
         //     clk_1kHz <= 1'b0;
         //     clk_div_ctr <= 1'b0;
         // end
         // else begin
             clk_out <= clk_out_nxt;
             clk_div_ctr <= clk_div_ctr_nxt;
         //end
     end
 
     always_comb begin : clk_signals_nxt
         if(clk_div_ctr == (400_000 - 1)) begin
             clk_div_ctr_nxt = 1'b0;
             clk_out_nxt = ~clk_out;
         end
         else begin
             clk_div_ctr_nxt = clk_div_ctr + 1;
             clk_out_nxt = clk_out;
         end
     end
endmodule
