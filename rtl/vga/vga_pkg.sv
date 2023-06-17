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
localparam HOR_PIXELS = 800;
localparam VER_PIXELS = 600;

// Add VGA timing parameters here and refer to them in other modules.
localparam V_TOTAL_TIME = 628;
localparam V_ADDR_TIME = 600;
localparam V_BLANK_START = 600;
localparam V_BLANK_TIME = 28;
localparam V_SYNC_START = 601;
localparam V_BOTTOM_BORDER = 0;
localparam V_RIGHT_BORDER = 0;
localparam V_FRONT_PORCH = 1;
localparam V_BACK_PORCH = 23;
localparam V_SYNC_TIME = 4;

localparam H_TOTAL_TIME = 1056;
localparam H_ADDR_TIME = 800;
localparam H_BLANK_START = 800;
localparam H_BLANK_TIME = 256;
localparam H_SYNC_START = 840;
localparam H_RIGHT_BORDER = 0;
localparam H_LEFT_BORDER = 0;
localparam H_FRONT_PORCH = 40;
localparam H_BACK_PORCH = 88;
localparam H_SYNC_TIME = 128;

//local parameters for rectangle drawing
localparam RECT_WIDTH = 48;
localparam RECT_HEIGHT = 64;

//local parameters for text drawing
localparam TEXT_COLOR = 12'h0_0_0;
localparam FONT_RECT_WIDTH = 128;
localparam FONT_RECT_HEIGHT = 256;
localparam CHAR_NUMBER = 256;
localparam CHAR_BIT_LENGTH = 8;
localparam HOR_CHAR_NUMBER = 16;
endpackage
