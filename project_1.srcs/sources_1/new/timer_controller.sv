`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.02.2022 21:05:50
// Design Name: 
// Module Name: timer_controller
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

module timer_controller #(parameter APB_ADDR_WIDTH = 12,
  APB_DATA_WIDTH = 32 )(
    input  clk_in1,  
    input  reset,
    output interrupt
    );
    
    
    
    
    logic clk_i; // Use for FPGA
  logic                      HCLK;
  logic                      HRESETn;
  logic [APB_ADDR_WIDTH-1:0] PADDR=0;
  logic               [31:0] PWDATA=0;
  logic                      PWRITE=0;
  logic                      PSEL;
  logic                      PENABLE;
  logic               [31:0] PRDATA;
  logic                      PREADY;
  logic                      PSLVERR;
  logic                      irq_o; //  cmp interrupt
    assign HRESETn = ~reset;
    assign interrupt = irq_o;

   clk_wiz_0  clk_gen  // Use for FPGA
     (
      // Clock out ports
      .clk_out1(clk_i),
     // Clock in ports
      .clk_in1(clk_in1)
     );
     
     

    assign HCLK = clk_i; //use for FPGA
//    assign HCLK = clk_in1; // Use for Simulation
    enum {  IDLE, DISABLE_CTRL, SET_CFG, SET_CMP_UPPER , SET_CMP_LOWER, SET_INTR_ENABLE, ENABLE_CTRL} currState, nextState;
   
    apb_timer #(
        .APB_ADDR_WIDTH(APB_ADDR_WIDTH), 
        .APB_DATA_WIDTH(APB_DATA_WIDTH)) timer_peripheral   
          ( 
            .HCLK   (HCLK   ) ,
            .HRESETn(HRESETn) ,
            .PADDR  (PADDR  ) ,
            .PWDATA (PWDATA ) ,
            .PWRITE (PWRITE ) ,
            .PSEL   (PSEL   ) ,
            .PENABLE(PENABLE) ,
            .PRDATA (PRDATA ) ,
            .PREADY (PREADY ) ,
            .PSLVERR(PSLVERR) ,
            .irq_o  (irq_o) //  cmp interrupt
            );
    
    
    logic [7:0] clk_cnt=0;

    always @(posedge HCLK or negedge HRESETn) begin    
        if (!HRESETn) begin
            currState <= IDLE;
            clk_cnt <=0;
        end
        else begin
        case (currState)

            IDLE:           begin 
                                PADDR    <= 'd0;
                                PWDATA   <= 'd0; 
                                PWRITE   <= 'd0; 
                            end                                    

            DISABLE_CTRL:   begin 
                                PADDR    <= 'd0;  // Disabling CTRL
                                PWDATA   <= 'd0; // Disabling CTRL
                                PWRITE   <= 'd1; 
                            end                                    

            SET_CFG:        begin // Setting prescale and step
                                PADDR    <= 12'h100;
                                PWDATA   <= {8'd0,8'd1,4'd0,12'd0}; 
                                PWRITE   <= 'd1; 
                            end                                    


            SET_CMP_UPPER:  begin 
                                PADDR    <= 12'h110;
                                PWDATA   <= 'd0; 
                                PWRITE   <= 'd1; 
                            end                                    


            SET_CMP_LOWER:  begin 
                                PADDR    <= 'h10c;
                                PWDATA   <=  'd50000000;
                                PWRITE   <= 'd1; 
                            end                                    


            SET_INTR_ENABLE:begin 
                                PADDR    <= 'h114;
                                PWDATA   <=  'h1;
                                PWRITE   <= 'd1; 
                            end                                    


            ENABLE_CTRL:    begin 
                                PADDR    <= 'h0;
                                PWDATA   <= 'd1; 
                                PWRITE   <= 'd1; 
                            end                                    

        endcase
            currState <= nextState;
            if (clk_cnt < 13)
            clk_cnt <= clk_cnt + 'd1;
//            else if (irq_o == 1)
//            clk_cnt <= 0;
            else 
            clk_cnt <= clk_cnt;
        end
    end    

    always_comb begin
        case(clk_cnt)
            1  : nextState = IDLE;
            2  : nextState = DISABLE_CTRL;
            3  : nextState = IDLE;
            4  : nextState = SET_CFG;
            5  : nextState = IDLE;
            6  : nextState = SET_CMP_UPPER;
            7  : nextState = IDLE;
            8  : nextState = SET_CMP_LOWER;
            9  : nextState = IDLE;
            10 : nextState = ENABLE_CTRL;
            11 : nextState = IDLE;
            12 : nextState = SET_INTR_ENABLE;
            13 : nextState = IDLE;
    endcase 

   end
       
   assign PSEL    = 1'b1;        
   assign PENABLE = 1'b1;        
    
endmodule
