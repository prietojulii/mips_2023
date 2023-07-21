//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Julieta Prieto
// Create Date: 15.02.2023 18:38:28
// Design Name: 
// Module Name: ID
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description:  Latch ID-EX.
// Dependencies: 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//////////////////////////////////////////////////////////////////////////////////

module IDEX 
#(
    parameter REG_SIZE= 32,
    parameter PC_SIZE= 32
)
(
    input wire i_clock,
    input wire i_reset,
    input wire i_enable,
    
    //* Signals from ID to EX
    input wire i_enable_risk_unit,
    input wire [4:0] i_rs,                      // Register source 1
    input wire [4:0] i_rt,                      // Register source 2
    input wire [4:0] i_rd,                      // Register destination
    input wire [REG_SIZE-1:0] i_shamt_extend,   // shift amount 
    input wire [REG_SIZE-1:0] i_imm_extend,     // Inmediate whit sign extended
    input wire [REG_SIZE-1:0] i_data_A,         // Data from register A
    input wire [REG_SIZE-1:0] i_data_B,         // Data from register B
    input wire [PC_SIZE-1:0] i_pc4,             // PC + 4
    input wire [5:0] i_op,                      // Opcode in ALU
    input wire i_flag_first_ex_instruction,     // Flag to know if is the first instruction in EX

    output wire [4:0] o_rs,
    output wire [4:0] o_rt,
    output wire [4:0] o_rd,
    output wire [REG_SIZE-1:0] o_shamt_extend,
    output wire [REG_SIZE-1:0] o_imm_extend,
    output wire [REG_SIZE-1:0] o_data_A,
    output wire [REG_SIZE-1:0] o_data_B, 
    output wire [PC_SIZE-1:0] o_pc4,
    output wire [5:0] o_op,
    output wire o_flag_first_ex_instruction,
    output wire o_enable_risk_unit,

    //* Signals from Unit Control
    //to EX
    input   wire [1:0] i_ctrl_EX_regDEST_flag,      // Select register destination
    input   wire [1:0] i_ctrl_EX_ALU_source_B_flag, // Select ALU source B
    input   wire       i_ctrl_EX_ALU_source_A_flag, // ALU source A
    output   wire [1:0] o_ctrl_EX_regDEST_flag,
    output   wire [1:0] o_ctrl_EX_ALU_source_B_flag,
    output   wire       o_ctrl_EX_ALU_source_A_flag,

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
reg [4:0] rs;                   
reg [4:0] rt;                    
reg [4:0] rd;                    
reg [REG_SIZE-1:0] shamt_extend; 
reg [REG_SIZE-1:0] imm_extend; 
reg [REG_SIZE-1:0] data_A;   
reg [REG_SIZE-1:0] data_B;       
reg [PC_SIZE-1:0] pc4;         
reg [5:0] op;             
reg flag_first_ex_instruction;
//to EX
reg [1:0] ctrl_EX_regDEST_flag;   
reg [1:0] ctrl_EX_ALU_source_B_flag;
reg       ctrl_EX_ALU_source_A_flag;
//to MEM
reg        ctrl_MEM_mem_write_or_read_flag;
reg [1:0]  ctrl_MEM_store_mask;
reg [2:0]  ctrl_MEM_load_mask;
//to WB
reg ctrl_WB_memToReg_flag;
reg ctrl_WB_wr_flag;

reg enable_risk_unit;

//SECUENTIAL LOGIC ************************************************
always @(posedge i_clock )
begin
    if (i_reset)
    begin
        rs <= 0;
        rt <= 0;
        rd <= 0;
        shamt_extend <= 0;
        imm_extend <= 0;
        data_A <= 0;
        data_B <= 0;
        pc4 <= 0;
        op <= 0;
        flag_first_ex_instruction <= 0;
        ctrl_EX_regDEST_flag <= 0;
        ctrl_EX_ALU_source_B_flag  <= 0;
        ctrl_EX_ALU_source_A_flag  <= 0;
        ctrl_MEM_mem_write_or_read_flag <= 0;
        ctrl_MEM_store_mask <= 0;
        ctrl_MEM_load_mask <= 0;
        ctrl_WB_memToReg_flag  <= 0;
        ctrl_WB_wr_flag <= 0;
        enable_risk_unit <= 0;
    end
    else
    begin
        if(i_enable == 1) begin
            rs <= i_rs;
            rt <= i_rt;
            rd <= i_rd;
            shamt_extend <= i_shamt_extend;
            imm_extend <= i_imm_extend;
            data_A <= i_data_A;
            data_B <= i_data_B;
            pc4 <= i_pc4;
            op <= i_op;
            flag_first_ex_instruction <= i_flag_first_ex_instruction;
            ctrl_EX_regDEST_flag <= i_ctrl_EX_regDEST_flag;
            ctrl_EX_ALU_source_B_flag  <= i_ctrl_EX_ALU_source_B_flag ;
            ctrl_EX_ALU_source_A_flag  <= i_ctrl_EX_ALU_source_A_flag ;
            ctrl_MEM_mem_write_or_read_flag <= i_ctrl_MEM_mem_write_or_read_flag;
            ctrl_MEM_store_mask <= i_ctrl_MEM_store_mask;
            ctrl_MEM_load_mask <= i_ctrl_MEM_load_mask;
            ctrl_WB_memToReg_flag  <= i_ctrl_WB_memToReg_flag ;
            ctrl_WB_wr_flag <= i_ctrl_WB_wr_flag;
            enable_risk_unit <= i_enable_risk_unit;
        end
    end
end

//OUTPUTS
assign o_rs = rs;
assign o_rt = rt;
assign o_rd = rd;
assign o_shamt_extend = shamt_extend;
assign o_imm_extend = imm_extend;
assign o_data_A = data_A;
assign o_data_B = data_B;
assign o_pc4 = pc4;
assign o_op = op;
assign o_flag_first_ex_instruction = flag_first_ex_instruction;
assign o_ctrl_EX_regDEST_flag = ctrl_EX_regDEST_flag;
assign o_ctrl_EX_ALU_source_B_flag  = ctrl_EX_ALU_source_B_flag ;
assign o_ctrl_EX_ALU_source_A_flag  = ctrl_EX_ALU_source_A_flag ;
assign o_ctrl_MEM_mem_write_or_read_flag = ctrl_MEM_mem_write_or_read_flag;
assign o_ctrl_MEM_store_mask = ctrl_MEM_store_mask;
assign o_ctrl_MEM_load_mask = ctrl_MEM_load_mask;
assign o_ctrl_WB_memToReg_flag  = ctrl_WB_memToReg_flag ;
assign o_ctrl_WB_wr_flag = ctrl_WB_wr_flag;
assign o_enable_risk_unit = enable_risk_unit;

endmodule
