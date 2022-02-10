`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.01.2022 21:30:44
// Design Name: 
// Module Name: PWM_controller
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


module timer_controller(
    input  clk_in1,
    input  reset_l,
    input  logic Speed_input0,
    input  logic Speed_input1,
    input  logic Speed_input2,
    input  EnableInput,
    output logic Digital_O1,
    output logic Digital_O2,
    input  FWD,
    input  REV,
    output PWM_O
    );
    
    
    
    
  //  logic reset_l;
//    assign reset_l = ~reset;
    logic           clk_i;
    logic           rst_ni;
    logic           write=0;                                    
    logic  [7:0]    addr_i=0;                                            
    logic  [31:0]   wdata_i=0;                                                                            
    logic  [31:0]   rdata_o;                                                                                                
    logic           o_pwm_1;
    logic           oe_pwm1;
    logic           psel;
    logic           penable;
    logic           pslverr;
    logic           pready;
    logic [7:0]     duty_cycle;
    logic           ctrl_state;
    
//   clk_wiz_0  clk_gen
//     (
//      // Clock out ports
//      .clk_out1(clk_i),
//     // Clock in ports
//      .clk_in1(clk_in1)
//     );
    assign clk_i = clk_in1;
    assign ctrl_state = EnableInput;
    assign PWM_O = o_pwm_1;
    assign rst_ni = reset_l;
    logic [31:0]    clk_cnt=1;

    enum {  IDLE, SET_PERIOD, SET_DUTY, SET_DIVISOR , SET_CTRL} currState, nextState;
   
    pwm  pwm_peripheral   ( .clk_i(clk_i),
            .rst_ni(rst_ni), // Active low reset                                                
            .write(write),    // write =1 write : write =0 read                                    
            .addr_i(addr_i),// Adress of register to set/modify                                            
            .wdata_i(wdata_i),//    
            .psel(psel),
            .penable(penable),// Peripheral select or enable signals                                                                            
            .rdata_o(rdata_o), // read channel                                                                                                 
            .o_pwm_1(o_pwm_1), // PWM output of 1st channel 
           // .oe_pwm1(oe_pwm1), // PWM valid indication 
            .pslverr(pslverr),
            .pready(pready)  );
    
    
    always @(posedge clk_i or negedge reset_l) begin    
        if (!reset_l) begin
            currState <= IDLE;
            write <=    1'b0;
            addr_i <=   8'd0;
            wdata_i <= 32'd0;
            clk_cnt <= 1;
                                                
        end
        else begin
            case (currState)
                IDLE:      begin    write <=    1'b0;
                                    addr_i <=   8'd0;
                                    wdata_i <= 32'd0;
                                  //  psel    <= 1'b0;
                                  //  penable <= 1'b0; 
                   
                                    end                                    
                                
                SET_PERIOD : begin  write <=    1'b1;
                                    addr_i <=   8'd8;
                                    wdata_i <= 32'd200;
                                    //psel    <= 1'b1;
                                    //penable <= 1'b1;
                                end

                SET_DUTY : begin    write <=    1'b1;
                                    addr_i <=   8'd12;
                                    wdata_i <= {24'd0,duty_cycle};
                                    //psel    <= 1'b1;
                                    //penable <= 1'b1;
//                                    nextState <= IDLE;
                                end                    

                SET_DIVISOR : begin write <=    1'b1;
                                    addr_i <=   8'd4;
                                    wdata_i <= 32'd2;
                                    //psel    <= 1'b1;
                                    //penable <= 1'b1;
//                                    nextState <= IDLE;
                                end

                SET_CTRL : begin    write <=    1'b1;
                                    addr_i <=   8'd0;
                                    wdata_i <= {29'd0,{3{ctrl_state}} };
                                    //psel    <= 1'b1;
                                    //penable <= 1'b1;
//                                    nextState <= IDLE;
                                end                    
                default : begin    write <=    1'b0;
                                                    addr_i <=   8'd0;
                                                    wdata_i <=0;
                                                    //psel    <= 1'b1;
                                                    //penable <= 1'b1;
                //                                    nextState <= IDLE;
                                                end                    

            endcase
          currState <= nextState;
          if(clk_cnt <9 )
          clk_cnt <= clk_cnt + 32'd1;
          else 
          clk_cnt <= 32'd5;
        end
    end    
    assign psel = 1'b1;
    assign penable = 1'b1;
    always_comb begin
    case(clk_cnt)
    1: nextState = SET_PERIOD;
    2: nextState = IDLE;
    3: nextState = SET_DIVISOR;
    4: nextState = IDLE;
    5: nextState = SET_DUTY;
    6: nextState = IDLE;
    7: nextState = SET_CTRL;
    8: nextState = IDLE;
   endcase 
//   if(EnableInput)
//   clk_cnt = 1'b1;
   end
    
    always_comb begin
        case({Speed_input2,Speed_input1,Speed_input0})
        3'b000: duty_cycle = 8'd0; 
        3'b001: duty_cycle = 8'd37; 
        3'b010: duty_cycle = 8'd74; 
        3'b011: duty_cycle = 8'd111; 
        3'b100: duty_cycle = 8'd148; 
        3'b101: duty_cycle = 8'd185; 
        3'b110: duty_cycle = 8'd222; 
        3'b111: duty_cycle = 8'd254; 
       default: duty_cycle = 8'd0;
        
        endcase
        
        if(FWD == 1'b1 && REV == 1'b0) begin
          Digital_O1 = 1'b1;
          Digital_O2 = 1'b0;
        end
        else if(FWD == 1'b0 && REV == 1'b1) begin
         Digital_O1 = 1'b0;
         Digital_O2 = 1'b1;
        end
        else begin
         Digital_O1 = 1'b0;
         Digital_O2 = 1'b0;
        end
    end         
       
        
    
endmodule
