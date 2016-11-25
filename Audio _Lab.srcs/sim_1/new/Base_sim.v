`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/29/2016 02:13:16 PM
// Design Name: 
// Module Name: Base_sim
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


module SongPlayer_tf;
reg clock;
reg reset;
wire audioOut;

SongPlayer uut(clock,reset,audioOut);
initial begin
clock =0;
repeat(1000) #1 clock =~clock;
end

initial begin
    reset =1;
    #2 reset =0;
end
endmodule
