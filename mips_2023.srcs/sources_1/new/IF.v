`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.02.2023 17:51:44
// Design Name: 
// Module Name: IF
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


module IF #
(
    parameter SIZE_REG= 32,
   parameter SIZE_PC= 32
)
(
    //IF INPUTS
    input wire i_clk,                                   
    input wire  i_reset,                                
    input wire i_flag_start_program,
    input wire i_flag_new_inst_ready,
    input wire [(SIZE_REG-1):0] i_instruction_data,
    input wire i_is_halt,
    input wire i_no_load,
    input wire [(SIZE_PC-1):0] i_next_pc,
    
    //IF OUTPUTS
    output wire [(SIZE_REG-1):0] o_instruction_data,
    output wire  [(SIZE_PC-1):0] o_pc,
    output wire  [(SIZE_PC-1):0] o_next_pc

    );

    wire [(SIZE_PC-1):0] wire_pc_to_memory;


    PROGRAM_MEMORY program_memory (

    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_pc(wire_pc_to_memory),
    .i_flag_new_inst_ready(i_flag_new_inst_ready),
    .i_instruction_data(i_instruction_data),
    .i_flag_start_program(i_flag_start_program),
    .o_instruction_data(o_instruction_data)
    ); 

    PC pc (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_next_pc(i_next_pc),
        .i_is_halt(i_is_halt),
        .i_no_load(i_no_load),
        .i_flag_start_program(i_flag_start_program),
        .o_pc(wire_pc_to_memory),
        .o_next_pc(o_next_pc)
    );

    assign o_pc=wire_pc_to_memory;
    
endmodule
