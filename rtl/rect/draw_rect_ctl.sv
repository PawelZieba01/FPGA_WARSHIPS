/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Paweł Zięba  
 * 
 * Description:
 * Draw rectangle control.
 * 
 * INput frequency: 50Hz
 */

 `timescale 1 ns / 1 ps

// localparam RECT_WIDTH = 48;
// localparam RECT_HEIGHT = 64;
// localparam RECT_COLOUR = 12'hf_0_0;

localparam BOUNCE_COEFICIENT = 16'b0000_0000_0000_1011;      //1/2 + 1/4 + 1/8
localparam ACCEL = 16'b0000_0000_0000_1100;                 //0.75
localparam LAST_SPEED = 6;


module draw_rect_ctl (
    input logic clk,
    input logic rst,

    input logic [11:0] mouse_xpos,
    input logic [11:0] mouse_ypos,

    input logic mouse_left,

    output logic [11:0] xpos,
    output logic [11:0] ypos,
    output logic stop
);

    import vga_pkg::*;

    typedef enum bit [1:0] {
        MOUSE_FOLLOW = 2'b00,
        FALL_DOWN = 2'b01,
        RISE_UP = 2'b11,
        BOTTOM = 2'b10
        } STATE_T;

    STATE_T state, state_nxt;

    logic [15:0] speed, speed_nxt;        //fixed point numbers - 4bit precision
    logic [11:0] xpos_nxt, ypos_nxt;

    assign stop = (state == BOTTOM  ?  1'b1  :  1'b0);

    always_ff @(posedge clk or posedge rst) begin : state_blk
        if(rst) begin
            state <= MOUSE_FOLLOW;
        end
        else begin
            state <= state_nxt;
        end
    end
    
    always_comb begin : state_nxt_blk
        case (state)
            MOUSE_FOLLOW:   state_nxt = mouse_left ? FALL_DOWN : MOUSE_FOLLOW;
            FALL_DOWN: begin
                if(((ypos+RECT_HEIGHT) >= VER_PIXELS - 1) && (speed[15:4] <= LAST_SPEED))    state_nxt = BOTTOM;
                else if((ypos+RECT_HEIGHT) >= VER_PIXELS - 1)       state_nxt = RISE_UP;
                else                                                state_nxt = FALL_DOWN;
            end
            RISE_UP:        state_nxt  =   (speed[15:4] <= 0 ? FALL_DOWN : RISE_UP);
            BOTTOM:         state_nxt   =   BOTTOM;
            default:        state_nxt  =   MOUSE_FOLLOW;
        endcase
    end


    always_ff @(posedge clk or posedge rst) begin : data_blk
        if(rst) begin
            ypos <= '0;
            xpos <= '0;
            speed <= '0;
        end
        else begin
            ypos <= ypos_nxt;
            xpos <= xpos_nxt;
            speed <= speed_nxt;
        end
    end


    always_comb begin : ypos_nxt_blk       // VER_PIXELS - max_height[15:4] + 12'(tick_ctr_square>>9);
        case (state)
            MOUSE_FOLLOW:   ypos_nxt =      mouse_ypos;
            FALL_DOWN:      ypos_nxt =      ((ypos + speed[15:4]) >= VER_PIXELS-RECT_HEIGHT-1)  ?  (VER_PIXELS-RECT_HEIGHT-1)  :  (ypos + speed[15:4]) ;
            RISE_UP:        ypos_nxt =      ypos - speed[15:4];
            BOTTOM:         ypos_nxt =      VER_PIXELS - RECT_HEIGHT - 1;
            default:        ypos_nxt =      ypos;
        endcase
    end

    always_comb begin : xpos_nxt_blk
        case (state)
            MOUSE_FOLLOW:   xpos_nxt =      mouse_xpos;
            FALL_DOWN:      xpos_nxt =      xpos;
            RISE_UP:        xpos_nxt =      xpos;
            BOTTOM:         xpos_nxt =      xpos;
            default:        xpos_nxt =      xpos;
        endcase
    end


    logic [31:0] new_speed;
    assign new_speed = 32'(BOUNCE_COEFICIENT * speed);

    always_comb begin : speed_nxt_blk
        case (state)
            MOUSE_FOLLOW:   speed_nxt = speed;
            FALL_DOWN: begin
                if(((ypos+RECT_HEIGHT) >= VER_PIXELS - 1) && (speed[15:4] <= LAST_SPEED)) begin
                    speed_nxt = '0;
                end
                else if((ypos+RECT_HEIGHT) >= (VER_PIXELS - 1)) begin
                    speed_nxt = new_speed[19:4];
                end
                else speed_nxt = speed + ACCEL;
            end
            RISE_UP:        speed_nxt =    (speed[15:4] == 0)  ?  speed  :  (speed - ACCEL); 
            BOTTOM:         speed_nxt =    '0;
            default:        speed_nxt =    speed;
        endcase
    end

    
endmodule
