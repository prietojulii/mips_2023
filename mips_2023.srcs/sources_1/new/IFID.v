`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
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

    input wire [REG_SIZE-1:0] i_instruction_data,
  //  input wire [PC_SIZE-1:0] i_pc,
    input wire [PC_SIZE-1:0] i_next_pc,
    
    output wire [REG_SIZE-1:0] o_instruction_data,
   // output wire [PC_SIZE-1:0] o_pc,
    output wire [PC_SIZE-1:0] o_next_pc
);

  //SIGNALS
    reg [REG_SIZE-1:0] instruction_data;
   // reg [PC_SIZE-1:0] pc;
    reg [PC_SIZE-1:0] next_pc;


    always @(posedge i_clock )
begin
    if (i_reset)
    begin
        instruction_data <= 0;
       // pc <= 0;
        next_pc <= 0;
    end
    else
    begin
        instruction_data <= i_instruction_data;
       // pc <= i_pc;
        next_pc <= i_next_pc;
    end
end

  //OUTPUTS
  //assign o_pc = pc;
  assign o_next_pc = next_pc;
  assign o_instruction_data = instruction_data;

endmodule