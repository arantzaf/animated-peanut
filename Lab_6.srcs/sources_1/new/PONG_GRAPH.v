`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2015 01:30:14 PM
// Design Name: 
// Module Name: pong_graph_an_unit - pong_graph_animate
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pong_graph_animate(
    input wire clk, reset,
    input wire video_on,
 //   input wire [1:0] btn,
    input wire [9:0] pix_x, pix_y,
    input wire scan_done_tick,
    input wire [7:0] scan_data,
    output wire miss,
    output reg [11:0] graph_rgb
   );
    
    reg [1:0] btn = 0;
    reg miss_reg;
//    reg [15:0] read =0;
    wire dig0,dig1;
    reg [6:0] count =0;
    wire [11:0] rgb_num;
    reg[1:0] state;
    reg [1:0] next_state;
    
    always @ *
    if (reset) state = 0;
    else state = next_state;
    
     //Determine which key is pressed
    always @(state)
    case(state)
        0: begin
            if(scan_done_tick) begin
//            //move bottom half to top, and move scan_data to bottom halfs
//            read <= {read[7:0] , scan_data[7:0]};
            next_state =1; 
            end
        end
        
        1: begin
            //if "A" is pressed go left
           if(scan_data[7:4] == 4'h1 && scan_data[3:0] == 4'hc)
           begin
                btn[0] = 1;
                btn[1] = 0;
            end
               
           //if "D" is pressed go right
           else if(scan_data[7:4] == 4'h2 && scan_data[3:0] == 4'h3)
            begin
                btn[0] = 0;
                btn[1] = 1;
            end   
           //if F0 is received, btn is 0, stop movement
           else if(scan_data[7:4] == 4'hf && scan_data[3:0] == 4'h0)
            begin
                btn[0] = 0;
                btn[1] = 0;
            end
            next_state =0;
        end
    endcase

   // constant and signal declaration
   // x, y coordinates (0,0) to (639,479)
   localparam MAX_X = 640;
   localparam MAX_Y = 480;
   wire refr_tick;
   //--------------------------------------------
   // vertical stripe as a wall
   //--------------------------------------------
   // wall top, bottom boundary
   localparam WALL_Y_T = 35;
   localparam WALL_Y_B = 45;
   //--------------------------------------------
   // bottom horizontal bar
   //--------------------------------------------
   // bar top, bottom boundary
   localparam BAR_Y_T = 440;
   localparam BAR_Y_B = 443;
   // bar left, right boundary
   wire [9:0] bar_x_l, bar_x_r;
   localparam BAR_X_SIZE = 72;
   // register to track boundary  (y position is fixed)
   reg [9:0] bar_x_reg, bar_x_next;
   // bar moving velocity when a button is pressed
   localparam BAR_V = 4;
   //--------------------------------------------
   // square ball
   //--------------------------------------------
   localparam BALL_SIZE = 16;
   // ball left, right boundary
   wire [9:0] ball_x_l, ball_x_r;
   // ball top, bottom boundary
   wire [9:0] ball_y_t, ball_y_b;
   // reg to track left, top position
   reg [9:0] ball_x_reg, ball_y_reg;
   wire [9:0] ball_x_next, ball_y_next;
   // reg to track ball speed
   reg [9:0] x_delta_reg, x_delta_next;
   reg [9:0] y_delta_reg, y_delta_next;
   // ball velocity can be pos or neg)
   localparam BALL_V_P = 1;
   localparam BALL_V_N = -1;
   //--------------------------------------------
   // round ball
   //--------------------------------------------
   wire [3:0] rom_addr, rom_col;
   reg [15:0] rom_data;
   wire rom_bit;
   //--------------------------------------------
   // object output signals
   //--------------------------------------------
   wire wall_on, bar_on, sq_ball_on, rd_ball_on;
   wire [11:0] wall_rgb, bar_rgb, ball_rgb;

   // body
   //--------------------------------------------
   // round ball image ROM
   //--------------------------------------------
   always @*
      case (rom_addr)
           4'h0: rom_data = 16'b0000000110000000;
           4'h1: rom_data = 16'b0000001111000000;
           4'h2: rom_data = 16'b0000111111110000;
           4'h3: rom_data = 16'b0001111111111000;
           4'h4: rom_data = 16'b0011111001111100;
           4'h5: rom_data = 16'b0011110000111100;
           4'h6: rom_data = 16'b0111100000011110;
           4'h7: rom_data = 16'b1111000000001111;
           4'h8: rom_data = 16'b1111000000001111;
           4'h9: rom_data = 16'b0111100000011110;
           4'hA: rom_data = 16'b0011110000111100;
           4'hB: rom_data = 16'b0011111001111100;
           4'hC: rom_data = 16'b0001111111111000;
           4'hD: rom_data = 16'b0000111111110000;
           4'hE: rom_data = 16'b0000001111000000;
           4'hF: rom_data = 16'b0000000110000000;
       endcase

   // registers
   always @(posedge clk, posedge reset)
      if (reset)
         begin
            bar_x_reg <= 0;
            ball_x_reg <= 0;
            ball_y_reg <= 0;
            x_delta_reg <= 10'h004;
            y_delta_reg <= 10'h004;
         end
      else
         begin
            bar_x_reg <= bar_x_next;
            ball_x_reg <= ball_x_next;
            ball_y_reg <= ball_y_next;
            x_delta_reg <= x_delta_next;
            y_delta_reg <= y_delta_next;
         end

   // refr_tick: 1-clock tick asserted at start of v-sync
   //            i.e., when the screen is refreshed (60 Hz)
   assign refr_tick = (pix_y==481) && (pix_x==0);

   //--------------------------------------------
   // (wall) left vertical strip
   //--------------------------------------------
   // pixel within wall
   assign wall_on = (WALL_Y_T<=pix_y) && (pix_y<=WALL_Y_B);
   // wall rgb output
   assign wall_rgb = 12'b000011110000; // blue
   //--------------------------------------------
   // right vertical bar
   //--------------------------------------------
   // boundary
   assign bar_x_l = bar_x_reg;
   assign bar_x_r = bar_x_l + BAR_X_SIZE - 1;
   // pixel within bar
   assign bar_on = (bar_x_l<=pix_x) && (pix_x<=bar_x_r) &&
                   (BAR_Y_T<=pix_y) && (pix_y<=BAR_Y_B);
   // bar rgb output
   assign bar_rgb = 12'b111100000000;    // green
   // new bar y-position
   always @*
   begin
      bar_x_next = bar_x_reg; // no move             //Check here if theres  a problem
      if (refr_tick)
         if (btn[1] & (bar_x_r < (MAX_X-1-BAR_V)))
            bar_x_next = bar_x_reg + BAR_V; // move down
         else if (btn[0] & (bar_x_l > BAR_V))
            bar_x_next = bar_x_reg - BAR_V; // move up
   end

   //--------------------------------------------
   // square ball
   //--------------------------------------------
   // boundary
   assign ball_x_l = ball_x_reg;
   assign ball_y_t = ball_y_reg;
   assign ball_x_r = ball_x_l + BALL_SIZE - 1;
   assign ball_y_b = ball_y_t + BALL_SIZE - 1;
   // pixel within ball
   assign sq_ball_on =
            (ball_x_l<=pix_x) && (pix_x<=ball_x_r) &&
            (ball_y_t<=pix_y) && (pix_y<=ball_y_b);
            
   // map current pixel location to ROM addr/col
   assign rom_addr = pix_y[3:0] - ball_y_t[3:0];
   assign rom_col = pix_x[3:0] - ball_x_l[3:0];
   assign rom_bit = rom_data[rom_col];
   
   // pixel within ball
   assign rd_ball_on = sq_ball_on & rom_bit;
   // ball rgb output
   assign ball_rgb = 12'b000000000011;   // red
   
   // new ball position
   assign ball_x_next = (refr_tick) ? ball_x_reg+x_delta_reg :
                        ball_x_reg ;
   assign ball_y_next = (refr_tick) ? ball_y_reg+y_delta_reg :
                        ball_y_reg ;
                        
   // new ball velocity
   always @*
   begin
      x_delta_next = x_delta_reg;
      y_delta_next = y_delta_reg;
      if (ball_x_l < 1) // reach top
         x_delta_next = BALL_V_P;
      else if (ball_x_r > (MAX_X-1)) // reach bottom
         x_delta_next = BALL_V_N;
      else if (ball_y_t <= WALL_Y_B) // reach wall
         y_delta_next = BALL_V_P;    // bounce back
      else if ((BAR_Y_T<=ball_y_b) && (ball_y_b<=BAR_Y_B) &&   //This is where we at 
               (bar_x_l<=ball_x_r) && (ball_x_l<=bar_x_r))
         // reach x of right bar and hit, ball bounce back
         y_delta_next = BALL_V_N;
   end
   
   always@*
        begin
        if(BAR_Y_B+2 == ball_y_t)
        begin
            miss_reg <= 1;
        end
        else if (BAR_Y_B > ball_y_b)
            miss_reg <= 0;
        end
        
   assign miss = miss_reg;
   
   always @ (posedge miss)
   begin
        if(miss)
         count = count +1;
        else
         count = count;
    end

    text_number num(video_on,reset,pix_x,pix_y,count,rgb_num,dig0,dig1);    
   //--------------------------------------------
   // rgb multiplexing circuit
   //--------------------------------------------
   always @*
      if (~video_on)
         graph_rgb = 12'b00000000000; // blank
      else
         if (wall_on)
            graph_rgb = wall_rgb;
         else if (bar_on)
            graph_rgb = bar_rgb;
         else if (rd_ball_on)
           graph_rgb = ball_rgb;
         else if (dig0)
           graph_rgb=rgb_num;
         else if (dig1)
           graph_rgb=rgb_num;
         else
            graph_rgb = 12'b000000000000; // yellow background

endmodule
