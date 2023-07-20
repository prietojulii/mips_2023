`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.06.2023 05:07:48
// Design Name: 
// Module Name: EXMEM
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


module EXMEM
#(
    parameter REG_SIZE= 32
)
(
    input wire i_clock,
    input wire i_reset,

    //* Signals from EX to MEM
    input wire [(REG_SIZE-1):0] i_alu_result,      // Result of ALU
    input wire [(REG_SIZE-1):0] i_data_B,          // Data from register B
    input wire [4:0] i_addr_wb,                    // Address of register to write in WB
    output wire [(REG_SIZE-1):0] o_alu_result,
    output wire [(REG_SIZE-1):0] o_data_B,
    output wire [4:0] o_addr_wb,

    //* Signals from Unit Control
    //to MEM
    input   wire        i_ctrl_MEM_mem_write_or_read_flag,
    input   wire [1:0]  i_ctrl_MEM_store_mask,
    input   wire [2:0]  i_ctrl_MEM_load_mask,
    output   wire       o_ctrl_MEM_mem_write_or_read_flag,
    output   wire [1:0] o_ctrl_MEM_store_mask,
    output   wire [2:0] o_ctrl_MEM_load_mask,

    //to WB
    input  wire i_ctrl_WB_memToReg_flag,
    input  wire i_ctrl_WB_wr_flag,
    output  wire o_ctrl_WB_memToReg_flag,
    output  wire o_ctrl_WB_wr_flag
);

//SIGNALS ********************************************************
(* dont_touch = "yes" *) reg [(REG_SIZE-1):0] alu_result;
(* dont_touch = "yes" *) reg [(REG_SIZE-1):0] data_B;
(* dont_touch = "yes" *) reg [4:0] addr_wb;

//* Signals from Unit Control
//to MEM
(* dont_touch = "yes" *) reg        ctrl_MEM_mem_write_or_read_flag;
(* dont_touch = "yes" *) reg [1:0]  ctrl_MEM_store_mask;
(* dont_touch = "yes" *) reg [2:0]  ctrl_MEM_load_mask;

//to WB
(* dont_touch = "yes" *) reg ctrl_WB_memToReg_flag;
(* dont_touch = "yes" *) reg ctrl_WB_wr_flag;

//SECUENTIAL LOGIC *******************************************************
always @(posedge i_clock )
begin
    if(i_reset)
    begin
        alu_result <= 0;
        data_B <= 0;
        addr_wb <= 0;
        ctrl_MEM_mem_write_or_read_flag <= 0;
        ctrl_MEM_store_mask <= 0;
        ctrl_MEM_load_mask <= 0;
        ctrl_WB_memToReg_flag <= 0;
        ctrl_WB_wr_flag <= 0;
    end
    else
    begin
        alu_result <= i_alu_result;
        data_B <= i_data_B;
        addr_wb <= i_addr_wb;
        ctrl_MEM_mem_write_or_read_flag <= i_ctrl_MEM_mem_write_or_read_flag;
        ctrl_MEM_store_mask <= i_ctrl_MEM_store_mask;
        ctrl_MEM_load_mask <= i_ctrl_MEM_load_mask;
        ctrl_WB_memToReg_flag <= i_ctrl_WB_memToReg_flag;
        ctrl_WB_wr_flag <= i_ctrl_WB_wr_flag;
    end
end

//OUTPUTS *******************************************************
assign o_alu_result = alu_result;
assign o_data_B = data_B;
assign o_addr_wb = addr_wb;

assign o_ctrl_MEM_mem_write_or_read_flag = ctrl_MEM_mem_write_or_read_flag;
assign o_ctrl_MEM_store_mask = ctrl_MEM_store_mask;
assign o_ctrl_MEM_load_mask = ctrl_MEM_load_mask;

assign o_ctrl_WB_memToReg_flag = ctrl_WB_memToReg_flag;
assign o_ctrl_WB_wr_flag = ctrl_WB_wr_flag;

endmodule


