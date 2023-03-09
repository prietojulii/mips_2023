`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.02.2023 15:16:35
// Design Name: 
// Module Name: tb_risk_unit
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


module tb_risk_unit#(
    parameter SIZE_REG = 32,
    parameter SIZE_MEMORY= 320
)
();

    reg i_clock, i_reset, i_flag_first_ex_instruction;
    reg [4:0] i_rs_ex, i_rt_ex, i_rd_ex;
    reg [SIZE_REG-1:0] i_instruction_id;
    reg [5:0] i_op_ex;
    wire o_arithmetic_risk_flag, o_load_flag, o_no_load_pc_flag; 
    
    risk_unit my_risk_unit(
    .i_clk(i_clock),
    .i_reset(i_reset),
    .i_flag_first_ex_instruction(i_flag_first_ex_instruction),
    
    .i_rs_ex(i_rs_ex),
    .i_rd_ex(i_rd_ex),
    .i_rt_ex(i_rt_ex),
    .i_op_ex(i_op_ex),
    
    .i_instruction_id(i_instruction_id),
    
    .o_arithmetic_risk_flag(o_arithmetic_risk_flag),
    .o_load_flag(o_load_flag),
    .o_no_load_pc_flag(o_no_load_pc_flag)
//    .o_flag_bne(o_flag_bne),
//    .o_flag_beq(o_flag_beq)
    );
    
 always #500 i_clock=~i_clock;
 
 initial begin
 
    //ARRANCA TODO
    i_clock = 0;
    #1000
    i_reset = 1; 
    #1000
    i_reset = 0;
    
    //LOAD TEST
    i_flag_first_ex_instruction=1;
    #1000
    i_flag_first_ex_instruction=0;
    i_op_ex=6'b100000;
    
    i_rt_ex=6;
    i_instruction_id=32'b00000000110000000000000000000000;
    
//    i_instruction_id= 32'b00000000110000000000000000000000;
//    #1000
//    //ARITHMETIC RISK TEST
//    i_op_ex=5'b00000;
//    i_rd_ex=6;
//    i_instruction_id= 32'b00000000110000000000000000000000;
//    #1000
//    #1000
//    //BRANCH TEST
//    i_op_ex=6'b000101;
//    #1000
//    i_op_ex=6'b000100;
    
 end
 
 
 endmodule
    