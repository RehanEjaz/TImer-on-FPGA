`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.02.2022 21:10:21
// Design Name: 
// Module Name: tb_timer
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


module tb_timer#(parameter APB_ADDR_WIDTH = 12,
  APB_DATA_WIDTH = 32 )(

    );
    
    logic clk_in1=0,reset=1;
    
  timer_controller #(.APB_ADDR_WIDTH(APB_ADDR_WIDTH),
      .APB_DATA_WIDTH(APB_DATA_WIDTH)) DUT(
        .clk_in1(clk_in1),  
        .reset(reset)
        );
        
        always
        #5 clk_in1 = ~clk_in1;
        
        
        initial 
        #20 reset = 0;
        
endmodule
