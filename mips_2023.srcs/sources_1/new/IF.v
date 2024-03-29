`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mateo Merino
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
    input wire i_no_load,
    input wire i_is_halt,
    input wire [(SIZE_PC-1):0] i_next_pc,
    input wire i_enable,
    //IF OUTPUTS
    output wire [(SIZE_REG-1):0] o_instruction_data,
    output wire  [(SIZE_PC-1):0] o_next_pc,
    output wire [3:0] o_wire_state_program_memory,
    output wire o_wire_new_inst_program_memory

    );

    wire [(SIZE_PC-1):0] wire_pc_to_memory, next_pc;
    wire [(SIZE_REG-1):0] instruction_data;
    wire [3:0] wire_state_program_memory;
    wire wire_new_inst_program_memory;

    PC pc (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_enable(i_enable),
        .i_next_pc(i_next_pc),
        .i_is_halt(i_is_halt),
        .i_no_load(i_no_load),
        .i_flag_start_program(i_flag_start_program),
        .o_pc(wire_pc_to_memory),
        .o_next_pc(next_pc)
    );

    PROGRAM_MEMORY program_memory (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_pc(wire_pc_to_memory),
    .i_flag_new_inst_ready(i_flag_new_inst_ready),
    .i_instruction_data(i_instruction_data),
    .i_flag_start_program(i_flag_start_program),
    .o_instruction_data(instruction_data),
    .o_state_prueba(wire_state_program_memory),
    .o_flag_new_inst_ready_prueba(wire_new_inst_program_memory)
    ); 

    // assign o_pc = wire_pc_to_memory;
    assign o_next_pc = next_pc >> 3; //mapping bits a bytes
    assign o_instruction_data = instruction_data;
    assign  o_wire_state_program_memory = wire_state_program_memory;
    assign o_wire_new_inst_program_memory=wire_new_inst_program_memory;
endmodule
