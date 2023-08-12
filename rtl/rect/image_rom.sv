/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Robert Szczygiel
 * Modified: Piotr Kaczmarczyk
 * 
 * Modified: Pawel Zieba   
 *
 * Description:
 * The input 'address' is a 12-bit number, composed of the concatenated
 * 7-bit y and 7-bit x pixel coordinates.
 * The output 'rgb' is 12-bit number with concatenated
 * red, green and blue color values (4-bit each)
 */

 module image_rom #( parameter
    IMG_DATA_PATH = "../../rtl/rect/image_rom.data"
)(
    input  logic clk ,
    input  logic [13:0] address,  // address = {addry[6:0], addrx[6:0]}
    output logic [11:0] rgb
);


/**
 * Local variables and signals
 */

reg [11:0] rom [0:16383];


/**
 * Memory initialization from a file
 */

/* Relative path from the simulation or synthesis working directory */
initial $readmemh(IMG_DATA_PATH, rom);
//initial $readmemh("./image_rom.data", rom);


/**
 * Internal logic
 */

always @(posedge clk)
    rgb <= rom[address];

endmodule
