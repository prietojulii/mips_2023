`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.06.2023 17:57:10
// Design Name: 
// Module Name: WB
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


module WB #(
    parameter SIZE_REG=32
    )(
   input wire [SIZE_REG-1:0] i_data_mem,
   input wire i_ctrl_WB_memToReg_flag,
   input wire [SIZE_REG-1:0] i_alu_result,
   output wire [SIZE_REG-1:0] o_data_to_wb
    );

    reg [SIZE_REG-1:0] data_to_wb ;
    always @(*)
    begin
        if(i_ctrl_WB_memToReg_flag == 1) begin
            data_to_wb = i_data_mem;
        end
        else if(i_ctrl_WB_memToReg_flag == 0)  begin
            data_to_wb = i_alu_result;
        end
        else begin
            data_to_wb = 1;
        end
    end


assign o_data_to_wb = data_to_wb;
endmodule
