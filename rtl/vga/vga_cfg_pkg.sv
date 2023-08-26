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

package vga_cfg_pkg;

// Parameters for VGA Display 1024 x 768 @ 60fps using a 65 MHz clock;
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

endpackage
