`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/08/2016 04:15:18 PM
// Design Name: 
// Module Name: game_screen
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


module game_screen(
    input wire clk, reset,
    input wire video_on,
    input wire [9:0] pix_x, pix_y,
    input wire scan_done_tick,
    input wire [7:0] scan_data,
    output reg [11:0] graph_rgb
    );
    
    
    reg [1:0] btn = 0;
    
    wire dig0,dig1;
    reg [6:0] count = 0;
    wire [11:0] rgb_num;
    reg [1:0] state;
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
   // There will be 4 platforms
   //--------------------------------------------
   // Platform 1 - starting player platform
   localparam PLAT1_Y_T = 440;
   localparam PLAT1_Y_B = 480;
   localparam PLAT1_X_R = 350;
   localparam PLAT1_X_L = 200;
   
   // Platfrom 2 - second platform with portal
   localparam PLAT2_Y_T = 450;
   localparam PLAT2_X_L = 400;
   
   // Platform 3 - hanging platform, with end of portal
   localparam PLAT3_Y_T = 250;
   localparam PLAT3_Y_B = 300;
   localparam PLAT3_X_R = 250;
   
   // Platform 4 - hanging platform with goal
   localparam PLAT4_Y_T = 280;
   localparam PLAT4_Y_B = 320;
   localparam PLAT4_X_R = 550;
   localparam PLAT4_X_L = 350;

   //--------------------------------------------
   //  aid rectangle
   //-------------------------------------------- 


   //--------------------------------------------
   //  Outside Goal Box
   //-------------------------------------------- 
    localparam G1_Size = 50;
    localparam GOut_Y_B= 279;
    localparam GOut_Y_T= GOut_Y_B - G1_Size;
    localparam GOut_X_L= 490;
    localparam GOut_X_R= GOut_X_L + G1_Size;

   //--------------------------------------------
   //  Inside Goal Box
   //-------------------------------------------- 
    localparam G2_Size = 40;
    localparam GIn_Y_B = 274;
    localparam GIn_Y_T = GIn_Y_B - G2_Size;
    localparam GIn_X_L = 495;
    localparam GIn_X_R = GIn_X_L + G2_Size;
   
   //--------------------------------------------
   //  horizontal box
   //--------------------------------------------
   // box top and bottom boundary
   localparam BOX_Y_SIZE = 40;
   localparam BOX_Y_B = 439;
   localparam BOX_Y_T = BOX_Y_B - BOX_Y_SIZE;
   // box right and left boundary
   wire [9:0] box_x_l, box_x_r;
   localparam BOX_X_SIZE = 40;
//   localparam BOX_X_L = 220;
//   localparam BOX_X_R = BOX_X_L + BOX_X_SIZE;
   reg [9:0] box_x_reg, box_x_next;
   localparam BOX_V = 2;
   

   //--------------------------------------------
   // round ball
   //--------------------------------------------
//   wire [3:0] rom_addr, rom_col;
//   reg [11:0] rom_data;
//   wire rom_bit;   
   
   //--------------------------------------------
   // object output signals
   //--------------------------------------------
   wire plat1_on,
        plat2_on,
        plat3_on,
        plat4_on,
        gout_on,
        gin_on,
        box_on;//all platforms and obkects
        
   wire [11:0] plat1_rgb,
               plat2_rgb,
               plat3_rgb,
               plat4_rgb,
               gout_rgb,
               gin_rgb,
               box_rgb;
   
   
   assign refr_tick = (pix_y == 481) && (pix_x ==0);
   
   
   //--------------------------------------------
   // pixels withing platform 1
   //--------------------------------------------
   assign plat1_on = (PLAT1_Y_T <= pix_y) && (pix_y <= PLAT1_Y_B) &&
                     (PLAT1_X_L <= pix_x) &&(pix_x <= PLAT1_X_R);
   assign plat1_rgb = 12'b0010_0010_0010;
   //--------------------------------------------
   // pixels withing platform 2
   //--------------------------------------------
   assign plat2_on = (PLAT2_Y_T <= pix_y) && (PLAT2_X_L <= pix_x);
   assign plat2_rgb =12'b0010_0010_0010;
   //--------------------------------------------
   // pixels withing platform 3
   //--------------------------------------------
   assign plat3_on = (PLAT3_Y_T <= pix_y) && (pix_y <= PLAT3_Y_B) && 
                     (pix_x <= PLAT3_X_R);
   assign plat3_rgb =12'b0010_0010_0010;
   //--------------------------------------------
   // pixels withing platform 4
   //--------------------------------------------
   assign plat4_on = (PLAT4_Y_T <= pix_y) && (pix_y <= PLAT4_Y_B) && 
                     (PLAT4_X_L <= pix_x) && (pix_x <= PLAT4_X_R);
   assign plat4_rgb = 12'b0010_0010_0010;
   //--------------------------------------------
   // pixels withing Goal box out
   //--------------------------------------------
   assign gout_on = (GOut_Y_T <= pix_y) && (pix_y <= GOut_Y_B) && 
                    (GOut_X_L <= pix_x) && (pix_x <= GOut_X_R);
   assign gout_rgb = 12'b1000_0000_1011; //yellow inside
   //--------------------------------------------
   // pixels withing goal box in
   //--------------------------------------------
   assign gin_on = (GIn_Y_T <= pix_y) && (pix_y <= GIn_Y_B) && 
                   (GIn_X_L <= pix_x) && (pix_x <= GIn_X_R);
   assign gin_rgb = 12'b0010_0010_0010;
   
   //--------------------------------------------
   //  box boundary
   //--------------------------------------------
    assign box_x_l = box_x_reg;
    assign box_x_r = box_x_l + BOX_X_SIZE -1;
   // pixel withing box
    assign box_on = (box_x_l <= pix_x) && (pix_x <= box_x_r) && 
                    (BOX_Y_T <= pix_y) && (pix_y <= BOX_Y_B);
    assign box_rgb = 12'b0000_1011_0111; // purple
    
    
   // map current pixel location to ROM addr/col
//    assign rom_addr = pix_y[3:0] - box_y_t[3:0];
//    assign rom_col = pix_x[3:0] - box_x_l[3:0];
//    assign rom_bit = rom_data[rom_col];
    
    
    always@*
    begin
        box_x_next = box_x_reg;
        if(refr_tick)
        if(btn[1] & (box_x_r < (MAX_X-1-BOX_V)))
            box_x_next = box_x_reg + BOX_V; //move right
        else if (btn[0] & (box_x_l > BOX_V))
            box_x_next = box_x_reg - BOX_V; // move left
    end        
//    score_module num(video_on,reset,pix_x,pix_y,count,rgb_num,dig0,dig1);    

    always@*
        if(~video_on)
            graph_rgb = 12'b0000_0000_0000;
        else
            if(plat1_on)
                graph_rgb = plat1_rgb; //platform 1
            else if (plat2_on)
                graph_rgb = plat2_rgb; //platform 2
            else if (plat3_on)
                graph_rgb = plat3_rgb; //platform 3
            else if(plat4_on)
                graph_rgb = plat4_rgb; //platform 4
            else if(box_on)
                graph_rgb = box_rgb;   // player box 
            else if (gout_on)
                graph_rgb = gout_rgb;
            else if (gin_on)
                graph_rgb = gin_rgb;
            else
                graph_rgb = 12'b0110_0110_0111; //gray background
//                graph_rgb = 12'b1111_1111_1111; //white background
                
        
endmodule
