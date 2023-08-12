/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 * 
 * Modified by:
 * 2023 Paweł Zięba  
 *
 * Description:
 * Package with vga related constants.
 */

package vga_pkg;

// Parameters for VGA Display 800 x 600 @ 60fps using a 40 MHz clock;
localparam HOR_PIXELS = 1024;
localparam VER_PIXELS = 768;

// Add VGA timing parameters here and refer to them in other modules.
localparam V_ADDR_TIME = VER_PIXELS;
localparam V_FRONT_PORCH = 3;
localparam V_BACK_PORCH = 29;
localparam V_SYNC_TIME = 6;
localparam V_BOTTOM_BORDER = 0;
localparam V_RIGHT_BORDER = 0;
localparam V_BLANK_TIME = V_FRONT_PORCH + V_BACK_PORCH + V_SYNC_TIME;
localparam V_TOTAL_TIME = V_ADDR_TIME + V_BLANK_TIME;
localparam V_BLANK_START = V_ADDR_TIME;
localparam V_SYNC_START = V_ADDR_TIME + V_FRONT_PORCH;

localparam H_ADDR_TIME = HOR_PIXELS;
localparam H_FRONT_PORCH = 24;
localparam H_BACK_PORCH = 160;
localparam H_SYNC_TIME = 136;
localparam H_RIGHT_BORDER = 0;
localparam H_LEFT_BORDER = 0;
localparam H_BLANK_TIME = H_FRONT_PORCH + H_BACK_PORCH + H_SYNC_TIME;
localparam H_TOTAL_TIME = H_ADDR_TIME + H_BLANK_TIME;
localparam H_BLANK_START = H_ADDR_TIME;
localparam H_SYNC_START = H_ADDR_TIME + H_FRONT_PORCH;

//Parameters for background drawing
localparam BORDER_WIDTH = 3;
localparam BACKGROUND_COLOR = 12'hA_A_A;

//Parameters for rectangle drawing
localparam RECT_WIDTH = 48;
localparam RECT_HEIGHT = 64;

//Parameters for text drawing
localparam TEXT_COLOR = 12'h0_0_0;
localparam FONT_RECT_WIDTH = 128;
localparam FONT_RECT_HEIGHT = 256;
localparam CHAR_NUMBER = 256;
localparam CHAR_BIT_LENGTH = 8;
localparam HOR_CHAR_NUMBER = 16;
endpackage
