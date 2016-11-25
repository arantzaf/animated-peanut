`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/29/2016 02:12:45 PM
// Design Name: 
// Module Name: Base
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
//module PWM(
//input clk, 
//input reset, 
//input [19:0] pulseWidth, 
//input [19:0] pulsePeriod, 
//output reg pwm
//);

//reg[19:0] counter;
//always @(posedge clk)
//begin
//	if(reset) counter <=0;
//	else begin
//		counter <= counter +1;
//		if(counter >= pulsePeriod) counter <= 0;

//	end
//end
//always@ (counter or pulseWidth)
//	if(counter<pulseWidth) pwm=1;
//	else pwm=0;
	
//endmodule

module SongPlayer(
    input clk, 
    input reset, 
    output reg audioOut,
    output wire audSD
);
	reg[19:0] counter;
	reg[26:0] time1, noteTime;
	reg[9:0] number;
	wire[4:0] duration;
	wire[19:0] notePeriod;
	parameter clockFrequency = 100_000_000; // 100 MHZ
	
	assign audSD = 1'b1;

    MusicSheet song(.number(number),.note(notePeriod),.duration(duration));
    
//    PWM pulse(.clk(clk),.reset(reset),
//              .pulseWidth(counter),.pulsePeriod(notePeriod),.pwm(audioOut));

always @(posedge clk)
begin
	if(reset) 
	begin
	counter <=0; 
	time1 <=0; 	
	number <=0; 
	audioOut <=1;
	end

	else 
	begin
		counter<=counter+1; time1<=time1+1;
	if(counter >= notePeriod) 
	begin
		counter <=0;
		audioOut <= ~audioOut;
	end   //toggle audio output
	
	if(time1 >= noteTime) begin
		time1<=0;
		number <=number+1;end
	end
end
    always@(duration) 
    
    noteTime = notePeriod*clockFrequency/16;// number of FPGRA clock periods in one note
    
endmodule


//always@(duration) noteTime = notePeriod*clockFrequency/16;// number of FPGRA clock periods in one note

