`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mateo Merino
// 
// Create Date: 21.02.2023 17:19:11
// Design Name: 
// Module Name: IFID
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


module IFID
#(
    parameter REG_SIZE= 32,
    parameter PC_SIZE= 32
)
(
    input wire i_clock,
    input wire i_reset,
    input wire i_enable,

    input wire [REG_SIZE-1:0] i_instruction_data,
    input wire [PC_SIZE-1:0] i_next_pc,
    input wire i_flag_start_program,
    output wire [REG_SIZE-1:0] o_instruction_data,
    output wire [PC_SIZE-1:0] o_next_pc,
    output wire o_flag_start_program,
    output wire o_enable
);

  //SIGNALS
    reg [REG_SIZE-1:0] instruction_data;
    reg [PC_SIZE-1:0] next_pc;
    reg wire_flag_start_program;
    reg enable;


always @(posedge i_clock )
begin
    if (i_reset)
    begin
        instruction_data <= 0;
        next_pc <= 0;
        wire_flag_start_program <= 0;
        enable <= 0;
    end
    else
    begin
      if(i_enable == 1) begin
          instruction_data <= i_instruction_data;
          next_pc <= i_next_pc;
          wire_flag_start_program <= i_flag_start_program;
          enable <= i_enable;
      end
    end
end

  //OUTPUTS
  assign o_next_pc = next_pc;
  assign o_instruction_data = instruction_data;
  assign o_flag_start_program = wire_flag_start_program;
  assign o_enable = enable;

endmodule
