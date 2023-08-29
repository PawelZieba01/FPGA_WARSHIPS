/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Pawel Zieba
 *
 *
 * Description:
 * Package with all parameters control logic in project.
 */

package project_cfg_pkg;

    localparam SHIPS_NUMBER = 10; // number of ships to deploy on board

    //Values for memory
    localparam GRID_STATUS_EMPTY = 2'b00;
    localparam GRID_STATUS_MYSHIP = 2'b01;
    localparam GRID_STATUS_MISS = 2'b10;
    localparam GRID_STATUS_HIT = 2'b11;

    localparam SBtn_XPOS = 448;
    localparam SBtn_YPOS = 40;
    localparam SBtn_WIDITH = 128;
    localparam SBtn_HEIGHT = 64;
    localparam GRID_SIZE = 386;
    localparam PLAYER_POS = 100;
    localparam ENEMY_POS = 538;
    localparam GRID_YPOS = 200;
    localparam MY_TURN_PNG_XPOS = 749;
    localparam MY_TURN_PNG_YPOS = 116;
    localparam EN_TURN_PNG_XPOS = 261;
    localparam EN_TURN_PNG_YPOS = 116;
    localparam WIN_INFO_PNG_XPOS = 448;
    localparam WIN_INFO_PNG_YPOS = 40;
    localparam FAIL_INFO_PNG_XPOS = 448;
    localparam FAIL_INFO_PNG_YPOS = 40;


endpackage
