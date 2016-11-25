`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2015 01:25:29 PM
// Design Name: 
// Module Name: System
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


module System(
    input wire clk, reset_clk, reset,
    input wire ps2c, ps2d,
    output wire hsync, vsync,
    output wire [11:0] rgb,
    output reg [7:0] scan_out,
    output reg led,
    output wire miss
   );

   // signal declaration
  // reg [1:0] btn;
   wire [9:0] pixel_x, pixel_y;
   wire video_on, pixel_tick;
   reg [11:0] rgb_reg;
   wire [11:0] rgb_next;
   wire scan_done_tick;
   wire [7:0] scan_data;
   wire clk_50m; 
   
    //Slow clock
    clk_50m_generator myclk(clk,reset_clk,clk_50m);

   // body
   // instantiate vga sync circuit
   vga_sync vsync_unit
      (.clk(clk_50m), .reset(reset), .hsync(hsync), .vsync(vsync),
       .video_on(video_on), .p_tick(pixel_tick),
       .pixel_x(pixel_x), .pixel_y(pixel_y));
    
//    //instantiate the ps2 receiver
//    ps2_rx ps2_rx_unit
//          (.clk(clk_50m), .reset(reset), .rx_en(1'b1),
//           .ps2d(ps2d), .ps2c(ps2c),
//           .rx_done_tick(scan_done_tick), .dout(scan_data));   
    
    kb_code CodeGetter(.clk(clk), .reset(reset), .ps2d(ps2d),
            .ps2c(ps2c), .scan_code(scan_data), .scan_done_tick(scan_done_tick));
           
   // instantiate graphic generator
   pong_graph_animate pong_graph_an_unit
      (.clk(clk), .reset(reset), 
       .video_on(video_on), .pix_x(pixel_x),
       .pix_y(pixel_y), .scan_done_tick(scan_done_tick), .scan_data(scan_data),
       .miss(miss),.graph_rgb(rgb_next)); 
    
    always @*
    begin 
       scan_out = scan_data;
        if(scan_done_tick)  
            led = 1;
        else
            led = 0;
    end

//    reg [7:0] data_old;
//    reg [7:0] data_new;

//    always @(scan_done_tick)
//    begin
//        scan_code[15:8] <= data_old;
//        scan_code[7:0] <= scan_data;
//        data_old <= scan_data;
//    end
    
   // rgb buffer
   always @(posedge clk_50m)
      if (pixel_tick)
         rgb_reg <= rgb_next;
   // output
   assign rgb = rgb_reg;
    
    

endmodule


module clk_50m_generator(
    input clk,
    input reset_clk,
    output wire reg clk_50m
    );
    
    reg [1:0] counter;
    reg clk_reg;
    wire clk_next;
    
    always @(posedge clk, posedge reset_clk)
      if (reset_clk)
         begin
            clk_reg <= 1'b0;
         end
      else
         begin
            clk_reg <= clk_next;
         end
    
    assign clk_next = ~clk_reg;
    assign clk_50m = clk_reg;

    
endmodule

