`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.02.2023 17:25:56
// Design Name: 
// Module Name: tb_ID
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


module tb_ID
#(
    parameter PC_SIZE = 32,
    parameter INSTR_SIZE = 32, 
    parameter REG_SIZE = 32
)(

);

//inputs registers
reg i_clock,
     i_reset,
     ctrl_condition_flag,
     ctrl_jump_flag,
     write_wb_flag;
reg [4:0] addr_wr;
reg [REG_SIZE:0] data_wb;

//reg from IF module
reg [INSTR_SIZE-1:0] instruction;
reg  [PC_SIZE-1:0] pc4, pc;

//outputs wires
wire [REG_SIZE-1:0] o_data_A,
                    o_data_B;
wire [31:0] o_imm_extend; //inmediate whit sign extended
wire [4:0] o_rt; //register source 2
wire [4:0] o_rd; //register destination
wire [PC_SIZE-1:0] o_pc_next; //program counter next value
wire [31:0] o_shamt_extend; //shift amount 
wire [5:0] o_funct,o_op; //opcode in ALU 


//ID MODULE
ID ID_instace (
    .i_clock(i_clock),
    .i_reset(i_reset),
    .i_ctrl_condition_flag(ctrl_condition_flag), //condition flag (control unit)  
    .i_ctrl_jump_flag(ctrl_jump_flag), //branch(I-type)->DIRECTION=1 signal or branch(J-type)->RA=0 signal (control unit)
    .i_write_wb_flag(write_wb_flag), //write back signal
    .i_addr_wr(addr_wr), //register to write from writeback
    .i_data_wb(data_wb), //write back data
    .i_instruction(instruction),
    .i_pc4(pc4), //PC + 4
    .i_pc(pc), //PC 
    
    .o_data_A(o_data_A),
    .o_data_B(o_data_B), 
    .o_imm_extend(o_imm_extend), //inmediate whit sign extended
    .o_rt(o_rt), //register source 2
    .o_rd(o_rd), //register destination
    .o_pc_next(o_pc_next), //program counter next value
    .o_shamt_extend(o_shamt_extend), //shift amount 
    .o_funct(o_funct), //opcode in ALU
    .o_op(o_op)
);



//CLOCK
always #1000 i_clock = ~i_clock;


initial
begin
    //INIT RESET***************************
    i_clock = 0;
    i_reset = 1;   
 
    ctrl_condition_flag=0;
    ctrl_jump_flag=0;
    
    write_wb_flag=1;
    addr_wr=1;//R1
    data_wb=32'b1010101010;
    
    instruction = 32'b0;
    pc = 32'b10000000000000000000000000000000;
    pc4 = pc + 32'b100;
    
    #2000 
    i_reset = 0;
    #1000
    #1000
    #1000
    
    //SEND MODE*****************************
    
  instruction = 32'b10001100001000000000000000000000;
///instruction = 32'b00001000000000000000000000001000; // jump 8 
//    ctrl_jump_flag = 1;
    
   

    
end 
endmodule
