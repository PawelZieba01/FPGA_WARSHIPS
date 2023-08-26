/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Pawel Zieba
 *
 *
 * Description:
 * Package all parameters for playboard.
 */

package pb_cfg_pkg;

    localparam GRID_ROWS = 12;
    localparam GRID_COLUMNS = 12;
    localparam GRID_ELEMENT_HEIGHT = 32;
    localparam GRID_ELEMENT_WIDTH = 32;
    localparam GRID_BORDER_WIDTH = 2;
    localparam GRID_SIZE = GRID_ROWS*GRID_ELEMENT_HEIGHT;

    localparam GRID_STATUS_EMPTY = 2'b00;
    localparam GRID_STATUS_MYSHIP = 2'b01;
    localparam GRID_STATUS_MISS = 2'b10;
    localparam GRID_STATUS_HIT = 2'b11;

endpackage
