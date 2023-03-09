module IDEX 
#(
    parameter REG_SIZE= 32,
   parameter PC_SIZE= 32
)
(
    input wire i_clock,
    input wire i_reset,
    
    //* Signals from ID to EX
    input wire [4:0] i_rs,                      //register source 1
    input wire [4:0] i_rt,                      //register source 2
    input wire [4:0] i_rd,                      //register destination
    input wire [REG_SIZE-1:0] i_shamt_extend,   //shift amount 
    input wire [REG_SIZE-1:0] i_imm_extend,     //inmediate whit sign extended
    input wire [REG_SIZE-1:0] i_data_A,         //data from register A
    input wire [REG_SIZE-1:0] i_data_B,         //data from register B
    input wire [PC_SIZE-1:0] i_pc4,             //PC + 4
    input wire [PC_SIZE-1:0] i_pc_next,         //program counter next value
    input wire [5:0] i_funct,                   //opcode in ALU
    input wire [5:0] i_op,                      //opcode in ALU
    output wire [4:0] o_rs,
    output wire [4:0] o_rt,
    output wire [4:0] o_rd,
    output wire [REG_SIZE-1:0] o_shamt_extend,
    output wire [REG_SIZE-1:0] o_imm_extend,
    output wire [REG_SIZE-1:0] o_data_A,
    output wire [REG_SIZE-1:0] o_data_B, 
    output wire [PC_SIZE-1:0] o_pc4,
    output wire [PC_SIZE-1:0] o_pc_next,
    output wire [5:0] o_funct,
    output wire [5:0] o_op,

    //* Signals from Unit Control
    //to EX
    input   wire [1:0] i_ctrl_EX_regDEST_flag,      //Select register destination
    input   wire [1:0] i_ctrl_EX_ALU_source_B_flag, //Select ALU source B
    input   wire       i_ctrl_EX_ALU_source_A_flag, //ALU source A
    input   wire [5:0] i_ctrl_EX_ALUop_flag,        //ALU 
    input   wire       i_ctrl_EX_Branch_flag,       //Select register destination
    output   wire [1:0] o_ctrl_EX_regDEST_flag,
    output   wire [1:0] o_ctrl_EX_ALU_source_B_flag,
    output   wire       o_ctrl_EX_ALU_source_A_flag,
    output   wire [5:0] o_ctrl_EX_ALUop_flag,
    output   wire       o_ctrl_EX_Branch_flag,
    
    //to MEM
    input   wire        i_ctrl_MEM_memWrite_flag,
    input   wire        i_ctrl_MEM_memRead_flag,
    input   wire [1:0]  i_ctrl_MEM_byte_half_or_word_flag,
    input   wire [1:0]  i_ctrl_MEM_wr_reg_flag, 
    output   wire       o_ctrl_MEM_memWrite_flag,
    output   wire       o_ctrl_MEM_memRead_flag,
    output   wire [1:0] o_ctrl_MEM_byte_half_or_word_flag,
    output   wire [1:0] o_ctrl_MEM_wr_reg_flag,

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
reg [PC_SIZE-1:0] pc_next;       
reg [5:0] funct;         
reg [5:0] op;             
//to EX
reg [1:0] ctrl_EX_regDEST_flag;   
reg [1:0] ctrl_EX_ALU_source_B_flag;
reg       ctrl_EX_ALU_source_A_flag;
reg [5:0] ctrl_EX_ALUop_flag;
reg       ctrl_EX_Branch_flag;      
//to MEM
reg        ctrl_MEM_memWrite_flag;
reg        ctrl_MEM_memRead_flag;
reg [1:0]  ctrl_MEM_byte_half_or_word_flag;
reg [1:0]  ctrl_MEM_wr_reg_flag;
//to WB
reg ctrl_WB_memToReg_flag;
reg ctrl_WB_wr_flag;

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
        pc_next <= 0;
        funct  <= 0;
        op <= 0;
        ctrl_EX_regDEST_flag <= 0;
        ctrl_EX_ALU_source_B_flag  <= 0;
        ctrl_EX_ALU_source_A_flag  <= 0;
        ctrl_EX_ALUop_flag <= 0;
        ctrl_EX_Branch_flag <= 0;
        ctrl_MEM_memWrite_flag <= 0;
        ctrl_MEM_memRead_flag  <= 0;
        ctrl_MEM_byte_half_or_word_flag <= 0;
        ctrl_MEM_wr_reg_flag <= 0;
        ctrl_WB_memToReg_flag  <= 0;
        ctrl_WB_wr_flag <= 0;
    end
    else
    begin
        rs <= i_rs;
        rt <= i_rt;
        rd <= i_rd;
        shamt_extend <= i_shamt_extend;
        imm_extend <= i_imm_extend;
        data_A <= i_data_A;
        data_B <= i_data_B;
        pc4 <= i_pc4;
        pc_next <= i_pc_next;
        funct  <= i_funct ;
        op <= i_op;
        ctrl_EX_regDEST_flag <= i_ctrl_EX_regDEST_flag;
        ctrl_EX_ALU_source_B_flag  <= i_ctrl_EX_ALU_source_B_flag ;
        ctrl_EX_ALU_source_A_flag  <= i_ctrl_EX_ALU_source_A_flag ;
        ctrl_EX_ALUop_flag <= i_ctrl_EX_ALUop_flag;
        ctrl_EX_Branch_flag <= i_ctrl_EX_Branch_flag;
        ctrl_MEM_memWrite_flag <= i_ctrl_MEM_memWrite_flag;
        ctrl_MEM_memRead_flag  <= i_ctrl_MEM_memRead_flag ;
        ctrl_MEM_byte_half_or_word_flag <= i_ctrl_MEM_byte_half_or_word_flag;
        ctrl_MEM_wr_reg_flag <= i_ctrl_MEM_wr_reg_flag;
        ctrl_WB_memToReg_flag  <= i_ctrl_WB_memToReg_flag ;
        ctrl_WB_wr_flag <= i_ctrl_WB_wr_flag;
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
assign o_pc_next = pc_next;
assign o_funct  = funct ;
assign o_op = op;
assign o_ctrl_EX_regDEST_flag = ctrl_EX_regDEST_flag;
assign o_ctrl_EX_ALU_source_B_flag  = ctrl_EX_ALU_source_B_flag ;
assign o_ctrl_EX_ALU_source_A_flag  = ctrl_EX_ALU_source_A_flag ;
assign o_ctrl_EX_ALUop_flag = ctrl_EX_ALUop_flag;
assign o_ctrl_EX_Branch_flag = ctrl_EX_Branch_flag;
assign o_ctrl_MEM_memWrite_flag = ctrl_MEM_memWrite_flag;
assign o_ctrl_MEM_memRead_flag  = ctrl_MEM_memRead_flag ;
assign o_ctrl_MEM_byte_half_or_word_flag = ctrl_MEM_byte_half_or_word_flag;
assign o_ctrl_MEM_wr_reg_flag = ctrl_MEM_wr_reg_flag;
assign o_ctrl_WB_memToReg_flag  = ctrl_WB_memToReg_flag ;
assign o_ctrl_WB_wr_flag = ctrl_WB_wr_flag;



endmodule
