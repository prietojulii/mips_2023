`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.06.2023 17:56:58
// Design Name: 
// Module Name: MEMWB
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


module MEMWB #(
    parameter REG_SIZE=32
    )
    (
    input wire i_clock,
    input wire i_reset,
    input wire [REG_SIZE-1:0] i_data_mem,
    input wire                i_ctrl_WB_memToReg_flag,
    input wire                i_ctrl_WB_wr_flag,
    input wire [REG_SIZE-1:0] i_alu_result,
    input wire [4:0] i_addr_wb,
    output wire [4:0] o_addr_wb,
    output wire [REG_SIZE-1:0] o_data_mem,
    output wire o_ctrl_WB_memToReg_flag,
    output wire o_ctrl_WB_wr_flag,
    output wire [REG_SIZE-1:0] o_alu_result
    );


(* dont_touch = "yes" *) reg [REG_SIZE-1:0]  data_mem;
(* dont_touch = "yes" *) reg ctrl_WB_memToReg_flag;
(* dont_touch = "yes" *) reg ctrl_WB_wr_flag;
(* dont_touch = "yes" *) reg [REG_SIZE-1:0]  alu_result;


always @(posedge i_clock )
begin
    if(i_reset)
    begin
    data_mem <= 0;
    ctrl_WB_memToReg_flag <= 0;
    ctrl_WB_wr_flag <= 0;
    alu_result <= 0;
    end
    else
    begin
    data_mem <=i_data_mem;
    ctrl_WB_memToReg_flag <= i_ctrl_WB_memToReg_flag;
    ctrl_WB_wr_flag <= i_ctrl_WB_wr_flag;
    alu_result <= i_alu_result;
    end
end


assign o_data_mem = data_mem;
assign o_ctrl_WB_memToReg_flag = ctrl_WB_memToReg_flag;
assign o_ctrl_WB_wr_flag = ctrl_WB_wr_flag;
assign o_alu_result = alu_result;

endmodule
