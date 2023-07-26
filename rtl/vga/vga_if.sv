/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Paweł Zięba  
 * 
 * Description:
 * VGA interface.
 */

 `timescale 1 ns / 1 ps

interface vga_if ();
    logic [10:0] hcount;
    logic hsync;
    logic hblnk;
    logic [10:0] vcount;
    logic vsync;
    logic vblnk;
    logic [11:0] rgb;

    modport in (input hcount, hsync, hblnk, vcount, vsync, vblnk, rgb);
    modport out (output hcount, hsync, hblnk, vcount, vsync, vblnk, rgb);

endinterface
