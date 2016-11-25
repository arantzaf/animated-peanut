`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/25/2015 09:32:09 PM
// Design Name: 
// Module Name: kb_code
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


module kb_code
    #(parameter W_SIZE = 2) //2^W_SIZE words in FIFO
    (
        input wire clk, reset,
        input wire ps2d, ps2c, 
        //rd_key_code,
      //  output wire [7:0] key_code,
        output reg [7:0] scan_code,
        output wire scan_done_tick
       // output wire kb_buf_empty
    );
    
    //constant declaration
    localparam BRK = 8'hf0; // break code
    
    //symbolic state declaration
    localparam
        wait_brk = 1'b0,
        get_code = 1'b1;
    
    // signal declaration
    reg state_reg, state_next;
    wire [7:0] scan_out;
    reg got_code_tick;
//    wire scan_done_tick;
    wire clk_50m;
    
    wire kb_not_empty, kb_buf_empty;
    
    wire [7:0] key_code;
    //body
    //==========================================================================
    // instantiation
    //==========================================================================
    
    //PS/2 receiver
    ps2_rx ps2_rx_unit
        (.clk(clk), .reset(reset), .rx_en(1'b1),
           .ps2d(ps2d), .ps2c(ps2c),
           .rx_done_tick(scan_done_tick), .dout(scan_out)); 
           
   //instantiate fifo buffer
   fifo #(.B(8), .W(W_SIZE)) fife_key_unit
   (.clk(clk), .reset(reset), .rd(kb_not_empty),
       .wr(got_code_tick) , .w_data(scan_out),
       .empty(kb_buf_empty), .full(),
       .r_data(key_code));
       
    assign kb_not_empty = ~kb_buf_empty;
       
    //reg [15:0] scan_code;
    reg [7:0] old;
   //==========================================================================
   // FSM to get the scan code after F0 received
   //==========================================================================
   // state registers
   always @(posedge clk, posedge reset)
       if (reset)
           state_reg <= wait_brk ;
       else
           state_reg <= state_next ;
   // next-state logic
    always @*
    begin
        got_code_tick = 1'b0;
        state_next = state_reg;
        case (state_reg)
            wait_brk: // wait for FO of break code
                if (scan_done_tick == 1'b1 && scan_out==BRK)
                begin
                    state_next = get_code ;
                    old = BRK;
                end
                else old = key_code;
            get_code: // get the following scan code
                if (scan_done_tick)
                begin
                    got_code_tick = 1'b1;
                    state_next = wait_brk;
                end
        endcase
    end
   always @(posedge scan_done_tick)
   begin
        if(old == 8'hf0)
            scan_code = old;
        else
            scan_code = scan_out;
//       old = key_code;
   end
   
endmodule
//Listing 9.1
module ps2_rx
   (
    input wire clk, reset,
    input wire ps2d, ps2c, rx_en,
    output reg rx_done_tick,
    output wire [7:0] dout
   );

   // symbolic state declaration
   localparam [1:0]
      idle = 2'b00,
      dps  = 2'b01,
      load = 2'b10;

   // signal declaration
   reg [1:0] state_reg, state_next;
   reg [7:0] filter_reg;
   wire [7:0] filter_next;
   reg f_ps2c_reg;
   wire f_ps2c_next;
   reg [3:0] n_reg, n_next;
   reg [10:0] b_reg, b_next;
   wire fall_edge;

   // body
   //=================================================
   // filter and falling-edge tick generation for ps2c
   //=================================================
   always @(posedge clk, posedge reset)
   if (reset)
      begin
         filter_reg <= 0;
         f_ps2c_reg <= 0;
      end
   else
      begin
         filter_reg <= filter_next;
         f_ps2c_reg <= f_ps2c_next;
      end

   assign filter_next = {ps2c, filter_reg[7:1]};
   assign f_ps2c_next = (filter_reg==8'b11111111) ? 1'b1 :
                        (filter_reg==8'b00000000) ? 1'b0 :
                         f_ps2c_reg;
   assign fall_edge = f_ps2c_reg & ~f_ps2c_next;

   //=================================================
   // FSMD
   //=================================================
   // FSMD state & data registers
   always @(posedge clk, posedge reset)
      if (reset)
         begin
            state_reg <= idle;
            n_reg <= 0;
            b_reg <= 0;
         end
      else
         begin
            state_reg <= state_next;
            n_reg <= n_next;
            b_reg <= b_next;
         end
   // FSMD next-state logic
   always @*
   begin
      state_next = state_reg;
      rx_done_tick = 1'b0;
      n_next = n_reg;
      b_next = b_reg;
      case (state_reg)
         idle:
            if (fall_edge & rx_en)
               begin
                  // shift in start bit
                  b_next = {ps2d, b_reg[10:1]};
                  n_next = 4'b1001;
                  state_next = dps;
               end
         dps: // 8 data + 1 parity + 1 stop
            if (fall_edge)
               begin
                  b_next = {ps2d, b_reg[10:1]};
                  if (n_reg==0)
                     state_next = load;
                  else
                     n_next = n_reg - 1;
               end
         load: // 1 extra clock to complete the last shift
            begin
               state_next = idle;
               rx_done_tick = 1'b1;
            end
      endcase
   end
   // output
   assign dout = b_reg[8:1]; // data bits

endmodule

// Listing 4.20
module fifo
   #(
    parameter B=8, // number of bits in a word
              W=4  // number of address bits
   )
   (
    input wire clk, reset,
    input wire rd, wr,
    input wire [B-1:0] w_data,
    output wire empty, full,
    output wire [B-1:0] r_data
   );

   //signal declaration
   reg [B-1:0] array_reg [2**W-1:0];  // register array
   reg [W-1:0] w_ptr_reg, w_ptr_next, w_ptr_succ;
   reg [W-1:0] r_ptr_reg, r_ptr_next, r_ptr_succ;
   reg full_reg, empty_reg, full_next, empty_next;
   wire wr_en;

   // body
   // register file write operation
   always @(posedge clk)
      if (wr_en)
         array_reg[w_ptr_reg] <= w_data;
   // register file read operation
   assign r_data = array_reg[r_ptr_reg];
   // write enabled only when FIFO is not full
   assign wr_en = wr & ~full_reg;

   // fifo control logic
   // register for read and write pointers
   always @(posedge clk, posedge reset)
      if (reset)
         begin
            w_ptr_reg <= 0;
            r_ptr_reg <= 0;
            full_reg <= 1'b0;
            empty_reg <= 1'b1;
         end
      else
         begin
            w_ptr_reg <= w_ptr_next;
            r_ptr_reg <= r_ptr_next;
            full_reg <= full_next;
            empty_reg <= empty_next;
         end

   // next-state logic for read and write pointers
   always @*
   begin
      // successive pointer values
      w_ptr_succ = w_ptr_reg + 1;
      r_ptr_succ = r_ptr_reg + 1;
      // default: keep old values
      w_ptr_next = w_ptr_reg;
      r_ptr_next = r_ptr_reg;
      full_next = full_reg;
      empty_next = empty_reg;
      case ({wr, rd})
         // 2'b00:  no op
         2'b01: // read
            if (~empty_reg) // not empty
               begin
                  r_ptr_next = r_ptr_succ;
                  full_next = 1'b0;
                  if (r_ptr_succ==w_ptr_reg)
                     empty_next = 1'b1;
               end
         2'b10: // write
            if (~full_reg) // not full
               begin
                  w_ptr_next = w_ptr_succ;
                  empty_next = 1'b0;
                  if (w_ptr_succ==r_ptr_reg)
                     full_next = 1'b1;
               end
         2'b11: // write and read
            begin
               w_ptr_next = w_ptr_succ;
               r_ptr_next = r_ptr_succ;
            end
      endcase
   end

   // output
   assign full = full_reg;
   assign empty = empty_reg;

endmodule
