`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/25/2016 05:45:58 PM
// Design Name: 
// Module Name: MusicPlayer
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
module MusicSheet(
input [9:0] number, 
output reg [19:0] note, 
output reg [4:0] duration
);
localparam freq = 25000000;
parameter HALF = 5'b00100;
parameter ONE = 2*HALF;
parameter TWO = 2*ONE;
parameter FOUR = 2*TWO;

parameter C4 = freq/262, D4=freq/294, E4=freq/330, F4=freq/350, G4=freq/392; //number of FPGA clock periods.

//c4 =100_000_000/264 (????)
always @(number) begin
	case(number) //mary had a little lamb
	
0: 	    begin note = E4;  duration = ONE;	end	//Mar
1:  	begin note = D4; duration = ONE; 	end	//y
2:  	begin note = C4; duration = ONE; 	end	//had
3: 	    begin note = D4;  duration = ONE;	end	//a	
4:  	begin note = E4; duration = ONE; 	end	//lit
5:  	begin note = E4; duration = ONE; 	end	//tle
6:  	begin note = E4; duration = TWO; 	end	//lamb

7:  	begin note = D4; duration = ONE; 	end	//lit
8:  	begin note = D4; duration = ONE; 	end	//tle
9:  	begin note = D4; duration = TWO; 	end	//lamb

10: 	begin note = E4; duration = ONE; 	end	//lit
11: 	begin note = G4; duration = ONE; 	end	//tle
12: 	begin note = G4; duration = TWO; 	end	//lamb
13: 	begin note = E4;  duration = ONE;	end	//Mar
14: 	begin note = D4; duration = ONE; 	end	//y
15: 	begin note = C4; duration = ONE; 	end	//had
16: 	begin note = D4;  duration = ONE;	end	//a	
17: 	begin note = E4; duration = ONE; 	end	//lit
18: 	begin note = E4; duration = ONE; 	end	//tle
19: 	begin note = E4; duration = TWO; 	end	//lamb

20: 	begin note = E4; duration = ONE; 	end	//whose
21: 	begin note = D4; duration = ONE; 	end	//fleece
22: 	begin note = D4; duration = ONE; 	end	//was

23: 	begin note = E4; duration = ONE; 	end	//white
24: 	begin note = D4; duration = ONE; 	end	//as
25: 	begin note = C4; duration = FOUR; 	end	//snow
default: 	begin note = C4; duration = FOUR; 	end

endcase
end
endmodule