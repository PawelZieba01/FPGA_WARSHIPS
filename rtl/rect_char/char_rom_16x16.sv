/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Paweł Zięba  
 * 
 * Description:
 * 256 characters in rom.
 */

module char_rom_16x16 #( parameter
    TEXT = "Basic text"
    )(
    input   logic       clk,
    input   logic [7:0] char_xy,    //[7:4] y, [3:0] x
    output  logic [6:0] char_code
);
    import text_cfg_pkg::*;
    
    logic [3:0] x_pos;
    logic [3:0] y_pos;
    logic [7:0] char_code_nxt;

    logic [CHAR_NUMBER-1:0][CHAR_BIT_LENGTH-1:0] rom = {<<8{TEXT}};

    assign x_pos             =   char_xy[3:0];
    assign y_pos             =   char_xy[7:4];
    
    assign char_code_nxt   =  rom[x_pos + y_pos*HOR_CHAR_NUMBER][CHAR_BIT_LENGTH-1:0];
    always_ff @(posedge clk) begin : char_code_blk
        char_code <= char_code_nxt[6:0];
    end

endmodule