`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/08/2016 01:51:58 PM
// Design Name: 
// Module Name: vga_sync
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

module Top_System(
    input wire clk, reset,reset_clk,
    input wire ps2c,ps2d,
    output wire hsync, vsync,
    output wire [11:0] rgb,
    output reg [7:0] scan_out,
    output reg led
);

    wire clk_50m;
    wire video_on,pixel_tick;
    wire [9:0] pixel_x, pixel_y;
    
    wire [11:0] rgb_next;
    reg [11:0] rgb_reg;
    wire scan_done_tick;
    wire [7:0] scan_data;
        
    
    clk_50m_generator myclk(.clk(clk),.reset_clk(reset_clk),.clk_50m(clk_50m));
    // instantiate graphic
    game_screen screen(.clk(clk),.reset(reset),.video_on(video_on),
                    .pix_x(pixel_x),.pix_y(pixel_y),.scan_done_tick(scan_dont_tick),.scan_data(scan_data),
                    .graph_rgb(rgb_next));
    // vga sync circuit                
    vga_sync vsync_unit (.clk(clk_50m), .reset(reset), .hsync(hsync), .vsync(vsync),
                        .video_on(video_on), .p_tick(pixel_tick),
                        .pixel_x(pixel_x), .pixel_y(pixel_y));                    
    kb_code CodeGetter(.clk(clk), .reset(reset), .ps2d(ps2d),
                                .ps2c(ps2c), .scan_code(scan_data), .scan_done_tick(scan_done_tick));
                                
    always @*
           begin 
           scan_out = scan_data;
           if(scan_done_tick)  
              led = 1;
           else
              led = 0;
           end

   // rgb buffer
   always @(posedge clk)
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
