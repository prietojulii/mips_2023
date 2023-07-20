`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.06.2023 17:42:23
// Design Name: 
// Module Name: MEM
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


module MEM # (
        parameter REG_SIZE= 32
)
(
    input wire i_clock,
    input wire i_reset,
    input wire [REG_SIZE-1:0] i_addr_mem,
    input wire [REG_SIZE-1:0] i_data_mem,
    input wire [1:0] i_ctrl_mem_store_mask,
    input wire [2:0] i_ctrl_mem_load_mask,
    input wire i_ctrl_mem_write_or_read_flag,
    output wire [REG_SIZE-1:0] o_data_mem
);


//Parameters:
//STORE
localparam MASK_STORE_NONE_MASK = 2'b00;
localparam MASK_STORE_BYTE = 2'b01;
localparam MASK_STORE_HALF = 2'b10;
localparam MASK_STORE_WORD = 2'b11;

//LOAD
localparam MASK_LOAD_NONE_MASK = 3'b00;
localparam MASK_LOAD_SIGNED_BYTE = 3'b01;
localparam MASK_LOAD_SIGNED_HALF = 3'b10;
localparam MASK_LOAD_SIGNED_WORD = 3'b11;
localparam MASK_LOAD_UNSIGNED_BYTE = 3'b100;
localparam MASK_LOAD_UNSIGNED_HALF = 3'b101; 
localparam MASK_LOAD_UNSIGNED_WORD = 3'b110;

// Registers
reg [REG_SIZE-1:0] data_to_mem, data_to_wb, reg_data_from_mem;
wire  [REG_SIZE-1:0] data_from_mem;

// Mascara STORE
always @(*) begin
case (i_ctrl_mem_store_mask)
    MASK_STORE_NONE_MASK: data_to_mem = i_data_mem;
    MASK_STORE_BYTE: data_to_mem = {24'b0, i_data_mem[7:0]};
    MASK_STORE_HALF: data_to_mem = {16'b0, i_data_mem[15:0]};
    MASK_STORE_WORD: data_to_mem = i_data_mem;
    default: data_to_mem = i_data_mem;
endcase

end
DATA_MEM(
  .i_clock(i_clock),
  .i_reset(i_reset),
  .i_ctrl_mem_rd_or_wr(i_ctrl_mem_write_or_read_flag),
  .i_data_mem(i_data_mem),
  .i_addr_mem(i_addr_mem),
  .o_data_mem(data_from_mem)
);
// Mascara LOAD
always @(*) begin
reg_data_from_mem = data_from_mem;
case (i_ctrl_mem_load_mask)
    MASK_LOAD_NONE_MASK: data_to_wb = reg_data_from_mem;
    MASK_LOAD_SIGNED_BYTE: data_to_wb = {{24{reg_data_from_mem[7]}}, reg_data_from_mem[7:0]};
    MASK_LOAD_SIGNED_HALF: data_to_wb = {{16{reg_data_from_mem[15]}}, reg_data_from_mem[15:0]};
    MASK_LOAD_SIGNED_WORD: data_to_wb = reg_data_from_mem;
    MASK_LOAD_UNSIGNED_BYTE: data_to_wb = {24'b0, reg_data_from_mem[7:0]};
    MASK_LOAD_UNSIGNED_HALF: data_to_wb = {16'b0, reg_data_from_mem[15:0]};
    MASK_LOAD_UNSIGNED_WORD: data_to_wb = reg_data_from_mem;
    default: data_to_wb = reg_data_from_mem;
endcase
end




//Assigns

assign o_data_mem = data_to_wb;

endmodule
