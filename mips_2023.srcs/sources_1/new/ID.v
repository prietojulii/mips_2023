`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.02.2023 18:38:28
// Design Name: 
// Module Name: ID
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


//MIPS Instruction decode stage
module ID
#(
    parameter PC_SIZE = 32,
    parameter INSTR_SIZE = 32, 
    parameter REG_SIZE = 32
)
(
    input wire i_clock,
    input wire i_reset,
    input wire [1:0] i_ctrl_next_pc_sel,  //01-> pc4, 00-> jump(direction), 11 jump(A), 10-> branch
    input wire [INSTR_SIZE-1:0]  i_instruction,
    input wire i_write_wb_flag, //write back signal
    input wire [4:0] i_addr_wr, //register to write from writeback
    input wire [REG_SIZE-1:0] i_data_wb, //write back data
    input wire [PC_SIZE-1:0] i_pc4, //PC + 4

    
    output wire [4:0] o_rs, //register source 1
    output wire [4:0] o_rt, //register source 2
    output wire [4:0] o_rd, //register destination
    output wire [REG_SIZE-1:0] o_shamt_extend, //shift amount 
    output wire [REG_SIZE-1:0] o_imm_extend, //inmediate whit sign extended
    output wire [REG_SIZE-1:0] o_data_A,
    output wire [REG_SIZE-1:0] o_data_B, 
    output wire [PC_SIZE-1:0] o_pc_next, //program counter next value
    output wire [5:0] o_funct, //opcode in ALU
    output wire [5:0] o_op, //opcode in ALU
    output wire o_is_A_B_equal_flag
    );

    // Define next pc selector
    localparam SELECT_JUMP_DIRECTION = 2'b01; //offset
    localparam SELECT_PC4 = 2'b00;
    localparam SELECT_BRANCH = 2'b10;
    localparam SELECT_JUMP_DATA_A = 2'b11;

    //***************** Declaration of signals ******************************************************
    reg [31:0] imm_extend, inm_to_byte, shamt_extend, jump_direction, branch_address, pc_next;

    reg [15:0] inm;
    reg [25:0] offset;
    reg [5:0] funct, op;
    reg [4:0] shamt, rd, rt, rs;

    wire [31:0] data_A, data_B;

    // ***************** Architecture DLX ***********************************************************
     
    always @(*) rs     = i_instruction[25:21]; //source register
    always @(*) rt     = i_instruction[20:16]; //source2 register
    always @(*) rd     = i_instruction[15:11]; //destination register
    always @(*) inm    = i_instruction[15:0]; //inmediate (number of intruction to jump)
    always @(*) shamt  = i_instruction[10:6]; //shift amount
    always @(*) offset = i_instruction[25:0]; //jump destination address
    always @(*) funct  = i_instruction[5:0];  //select the arithmetic operation
    always @(*) op     = i_instruction[31:26];  //select the arithmetic operation

    // ******************* Convinational logic *******************************************************
    //registers logic : o_data_A , o_data_B (data)
    REG_MEMORY REG_MEMORY_instance
    (
        .i_clock(i_clock),
        .i_reset(i_reset),
        .i_wr_flag(i_write_wb_flag ), // 1 for write, 0 for read
        .i_addr_A(rs),
        .i_addr_B(rt),
        .i_addr_wr(i_addr_wr),
        .i_data_in( i_data_wb),
        .o_data_A(data_A),
        .o_data_B(data_B)
    );

    //o_pc_next logic 
    always @(*)  begin
        imm_extend = ( { { 16{inm[15] } } , inm } ); //immediate with extended sign
        inm_to_byte =  ( { { 16{inm[15] } } , inm } ) << 2; // inmediate with extended sign and shifted 2 bits (for mapping a byte)
        jump_direction = { i_pc4[31:28] , offset, 2'b00 }; //addr to jump
        branch_address = inm_to_byte + i_pc4; //branch address
        case (i_ctrl_next_pc_sel)
            SELECT_JUMP_DIRECTION: pc_next = jump_direction;  //jump
            SELECT_PC4:  pc_next = i_pc4;      //pc4
            SELECT_BRANCH:  pc_next = branch_address;  //branch
            SELECT_JUMP_DATA_A:  pc_next = data_A;     //jump register
        endcase
    end

    //o_shamt_extend logic
    always @(*) begin
    shamt_extend = { {27{1'b0}}  , shamt}; //unsigned extended shift amount
    end
    
    //******************* OUTPUT ****************************************************************
    assign o_rs = rs;
    assign o_rt = rt;
    assign o_rd = rd;
    assign o_imm_extend = imm_extend ;
    assign o_shamt_extend = shamt_extend;
    assign o_data_A = data_A;
    assign o_data_B = data_B;
    assign o_pc_next = pc_next;
    assign o_funct = funct;
    assign o_op = op;
    assign o_is_A_B_equal_flag = data_A == data_B;
endmodule


//BIBLIOGRAPHY
//J-type: https://www.youtube.com/watch?v=XzHMdWJtw3A
