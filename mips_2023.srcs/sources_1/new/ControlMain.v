`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.02.2023 19:41:11
// Design Name: 
// Module Name: ControlMain
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


module ControlMain
#(
    localparam REG_SIZE = 32,
    localparam INSTRUCTION_SIZE = 32
)(
    //!TODO: el nombre de las grag : <etapa destino>_<nombre de la señal>
    input wire [INSTRUCTION_SIZE-1:0] i_instruction,
    input wire i_is_A_B_equal_flag,
    output wire [1:0] o_next_pc_select, // 01 - offset, 00 - PC+4, 10 - branch, 11 - jump data A
    output wire o_ex_alu_src_a,
    output wire [1:0] o_ex_alu_src_b, // 00 - B , 01 - inmediate, 10 - return address, 11 - not used
    output wire [1:0] o_ex_reg_dest_sel, // 00 - rd, 01 - rt, 10 - GPR 31, 11 - not used
    
    output wire o_mem_write_to_register_flag, //write in the register memory 
    
    
    output wire o_mem_write_read_flag, //read o write in memory data
    //output wire o_mem_write_flag,
    //output wire o_mem_read_flag,
    
    //TODO: output wire [1:0] o_mem_byte_half_or_word, // 00 - word, 01 - byte, 10 - halfword
    output wire [2:0] o_mem_load_mask,
    output wire  o_mem_store_mask,

    output wire o_wb_mem_to_reg_sel,//selector of the font to use to write the register
    output wire o_wb_write_back_flag //1- there is wrtieback , 0-there is no writeback
    );
    
    // Index of bits in instruction
    localparam MSB_OPCODE = 31; // MSB of 6 bits for opcode
    localparam LSB_OPCODE = 26; // LSB of 6 bits for opcode
    localparam MSB_FUNCT  = 5; // MSB of 6 bits for funct
    localparam LSB_FUNCT  = 0; // LSB of the 6 bits for funct

    // Control signals
    reg [1:0] next_pc_select;
    reg ex_alu_src_a;
    reg [1:0] ex_alu_src_b;
    reg ex_branch_flag;
    reg [1:0] ex_reg_dest_sel;
    
    reg mem_write_to_register_flag;
    reg mem_write_read_flag;
    reg [2:0] mem_load_mask;
    reg mem_store_mask;

    reg wb_mem_to_reg_sel;
    reg wb_write_back_flag;


/** --------------------------------------------------------------------------------------------------------------------------
** DEFINES FOR OPCODES AND FUNCTS
** --------------------------------------------------------------------------------------------------------------------------
*/
    // Define opcodes
    localparam OPCODE_ARITMETIC_OR_SPECIAL = 6'b000000; // aritmetic, or special (in grl is R type instructions)
    localparam OPCODE_BEQ = 6'b000100;
    localparam OPCODE_BNE = 6'b000101;
    localparam OPCODE_J   = 6'b000010;
    localparam OPCODE_JAL = 6'b000011;
    localparam OPCODE_LB   = 6'b100000;
    localparam OPCODE_LH   = 6'b100001;
    localparam OPCODE_LW   = 6'b100011;
    localparam OPCODE_LWU  = 6'b100111;
    localparam OPCODE_LBU  = 6'b100100;
    localparam OPCODE_LHU  = 6'b100101;
    localparam OPCODE_SB   = 6'b101000;
    localparam OPCODE_SH   = 6'b101001;
    localparam OPCODE_SW   = 6'b101011;
    localparam OPCODE_ADDI = 6'b001000;
    localparam OPCODE_ORI  = 6'b100101;
    localparam OPCODE_XORI = 6'b001110;
    localparam OPCODE_LUI  = 6'b001111;
    localparam OPCODE_SLTI = 6'b001010;

    // Define functs
    localparam FUNCT_JR = 6'b001000;
    localparam FUNCT_JALR = 6'b001001; 
    localparam FUNCT_SLL  = 6'b000000;
    localparam FUNCT_SRL  = 6'b000010;
    localparam FUNCT_SRA  = 6'b000011;
    localparam FUNCT_SLLV = 6'b000100;
    localparam FUNCT_SRLV = 6'b000110;
    localparam FUNCT_SRAV = 6'b000111;

/**-----------------------------------------------------------------------------------------------------------------------
** Next PC Selector Logic
** --------------------------------------------------------------------------------------------------------------------------

** select next pc based on opcode and funct
   exisiting 4 cases:
    - branches (BNE,BEQ)(conditional jumps)
    - jumps (j, jal) (inconditional jumps)
    - jumps by register (jr, jalr) (inconditional jumps)
    - continue with pc+4 (default)
    NOTE: the opcode of "jump by register" is 0, so it is necessary to check the funct

____________________________________________
TABLE OF BRANCH INSTURCTIONS:
**------opcode------function---
- BEQ   000100          -
- BNE   000101          -
_____________________________________________
TABLE OF JUMP INSTURCTIONS:
**------opcode------function---
- J     000010          -
- JAL   000011          -
_____________________________________________
TABLE OF JUMP BY REGISTER INSTURCTIONS:
**------opcode------function---
- JR    000000      001000
- JALR  000000      001001
_____________________________________________
*/

// Define next pc selector
localparam SELECT_JUMP_DIRECTION = 2'b01; //offset
localparam SELECT_PC4 = 2'b00;
localparam SELECT_BRANCH = 2'b10;
localparam SELECT_JUMP_DATA_A = 2'b11;

always @(*) begin
    case(i_instruction[MSB_OPCODE:LSB_OPCODE])
        OPCODE_BEQ: next_pc_select = (i_is_A_B_equal_flag)?  SELECT_BRANCH : SELECT_PC4 ; 
        OPCODE_BNE: next_pc_select = (!i_is_A_B_equal_flag)? SELECT_BRANCH : SELECT_PC4 ;
        OPCODE_J:   next_pc_select = SELECT_JUMP_DIRECTION ;
        OPCODE_JAL: next_pc_select = SELECT_JUMP_DIRECTION ;
        OPCODE_ARITMETIC_OR_SPECIAL: begin
            case(i_instruction[MSB_FUNCT:LSB_FUNCT])
                FUNCT_JR: next_pc_select = SELECT_JUMP_DATA_A;
                FUNCT_JALR: next_pc_select = SELECT_JUMP_DATA_A;
                default: next_pc_select = SELECT_PC4; 
            endcase
        end
        default: next_pc_select = SELECT_PC4;
    endcase
end





/**-----------------------------------------------------------------------------------------------------------------------
** ALU Source A Logic
** --------------------------------------------------------------------------------------------------------------------------

** select alu source A based on opcode and funct
   exisiting 2 cases:
    - 0 - alu source A is register A (default)
    - 1 - alu source A is shift amount (SLL, SRL, SRA, ...)
____________________________________________
TABLE OF INSTRUCTIONS TO USE SHIFT AMOUNT:
**------opcode------function---
- SLL   000000      000000 
- SRL   000000      000010
- SRA   000000      000011
- SLLV  000000      000100
- SRLV  000000      000110
- SRAV  000000      000111
_____________________________________________
TABLE OF INSTRUCTIONS TO USE rs:
**NAME--OPCODE------FUNCTION---
- ADDU  000000      100001
- SUBU  000000      100011
- AND   000000      100100
- XOR   000000      100110
- NOR   000000      100111
- SLT   000000      101010
- LB    100000        -
- LH    100001        -
- LW    100011        -
- LWU   100111        -
- LBU   100100        -
- LHU   100101        -
- SB    101000        -
- SH    101001        -
- SW    101011        -
- ADDI  001000        -
- ORU   100101        -
- XORI  001110        -
- LUI   001111        -
- SLTI  001010        -
- BEQ   000100        -
_______________________________________________
*/

localparam SELECT_SHIFT_AMOUNT = 1'b1;
localparam SELECT_RS = 1'b0;
always @(*)
begin
    if(i_instruction[MSB_OPCODE:LSB_OPCODE] == OPCODE_ARITMETIC_OR_SPECIAL ) //check if is arithmetic instruction
       case (i_instruction[MSB_FUNCT:LSB_FUNCT]) //check function
            FUNCT_SLL : ex_alu_src_a = SELECT_SHIFT_AMOUNT;
            FUNCT_SRL : ex_alu_src_a = SELECT_SHIFT_AMOUNT;
            FUNCT_SRA : ex_alu_src_a = SELECT_SHIFT_AMOUNT;
            FUNCT_SLLV: ex_alu_src_a = SELECT_SHIFT_AMOUNT;
            FUNCT_SRLV: ex_alu_src_a = SELECT_SHIFT_AMOUNT;
            FUNCT_SRAV: ex_alu_src_a = SELECT_SHIFT_AMOUNT;
            default: ex_alu_src_a = SELECT_RS;
       endcase
    else //the rest instructions use rs
        ex_alu_src_a = SELECT_RS;
end

/**-----------------------------------------------------------------------------------------------------------------------
** ALU Source B Logic
** --------------------------------------------------------------------------------------------------------------------------

** select alu source B based on opcode and funct
   exisiting 3 cases:
    - 00 - alu source B is register B ( MEMORY_REGISTER(rt) = B ) (default)
    - 01 - alu source B is immediate
    - 10 - alu source B is return address
    - 11 - not used
____________________________________________
TABLE OF INSTRUCTIONS TO USE RT: 
**Name------opcode-----function----
- SLL       000000      000000
- SRL       000000      000010   
- SRA       000000      000011
- SLLV      000000      000100
- SRLV      000000      000110
- SRAV      000000      000111
- ADDU      000000      100001
- SUBU      000000      100011
- AND       000000      100100
- OR        000000      100101
- XOR       000000      100110
- NOR       000000      100111
- SLT       000000      101010
_____________________________________________
TABLE OF INSTRUCTIONS TO USE IMMEDIATE:
**Name------opcode-----function----
- LB        100000        -
- LH        100001        -
- LW        100011        -
- LWU       100111        -
- LBU       100100        -
- LHU       100101        -
- SB        101000        -
- SH        101001        -
- SW        101011        -
- ADDI      001000        -
- ORU       100101        -
- XORI      001110        -
- LUI       001111        -
- SLTI      001010        -
- BEQ       000100        -
- BNE       000101        -
______________________________________________
TABLE OF INSTRUCTIONS TO USE RETURN ADDRESS:
**Name------opcode-----function----
- JAL       000011        -
- JALR      000000      001001
*/

localparam SELECT_B = 2'b00;
localparam SELECT_IMMEDIATE = 2'b01;
localparam SELECT_RETURN_ADDRESS = 2'b10;


always @(*)
begin 
    case(i_instruction[MSB_OPCODE:LSB_OPCODE])
        //B=immediate
        OPCODE_LB   : ex_alu_src_b = SELECT_IMMEDIATE;
        OPCODE_LH   : ex_alu_src_b = SELECT_IMMEDIATE;
        OPCODE_LW   : ex_alu_src_b = SELECT_IMMEDIATE;
        OPCODE_LWU  : ex_alu_src_b = SELECT_IMMEDIATE;
        OPCODE_LBU  : ex_alu_src_b = SELECT_IMMEDIATE;
        OPCODE_LHU  : ex_alu_src_b = SELECT_IMMEDIATE;
        OPCODE_SB   : ex_alu_src_b = SELECT_IMMEDIATE;
        OPCODE_SH   : ex_alu_src_b = SELECT_IMMEDIATE;
        OPCODE_SW   : ex_alu_src_b = SELECT_IMMEDIATE;
        OPCODE_ADDI : ex_alu_src_b = SELECT_IMMEDIATE;
        OPCODE_ORI  : ex_alu_src_b = SELECT_IMMEDIATE;
        OPCODE_XORI : ex_alu_src_b = SELECT_IMMEDIATE;
        OPCODE_LUI  : ex_alu_src_b = SELECT_IMMEDIATE;
        OPCODE_SLTI : ex_alu_src_b = SELECT_IMMEDIATE;
        OPCODE_BEQ  : ex_alu_src_b = SELECT_IMMEDIATE;
        OPCODE_BNE  : ex_alu_src_b = SELECT_IMMEDIATE;

        //B=return address
        OPCODE_JAL : ex_alu_src_b = SELECT_RETURN_ADDRESS;

        // all the rest instructions use "SELECT_B" as B, except jalr
        OPCODE_ARITMETIC_OR_SPECIAL : ex_alu_src_b = (i_instruction[MSB_FUNCT:LSB_FUNCT] == FUNCT_JALR)?  SELECT_RETURN_ADDRESS : SELECT_B;
        default : ex_alu_src_b = SELECT_B;
    endcase
end

/**-----------------------------------------------------------------------------------------------------------------------
** Register Destiny Flag Logic
** --------------------------------------------------------------------------------------------------------------------------

** select register destiny flag based on opcode and funct
   exisiting 3 cases:
    - 00 - register destiny flag is rd
    - 01 - register destiny flag is rt
    - 10 - register destiny flag is GPR 31
    - 11 - not used
____________________________________________
TABLE OF INSTRUCTIONS TO USE RD:
**Name------opcode-----function----
- SLL       000000      000000
- SRL       000000      000010
- SRA       000000      000011
- SLLV      000000      000100
- SRLV      000000      000110
- SRAV      000000      000111
- ADDU      000000      100001
- SUBU      000000      100011
- AND       000000      100100
- OR        000000      100101
- XOR       000000      100110
- NOR       000000      100111
- SLT       000000      101010
- JALR      000000      001001
_____________________________________________
TABLE OF INSTRUCTIONS TO USE RT:
**Name------opcode-----function----
- LB        100000        -
- LH        100001        -
- LW        100011        -
- LWU       100111        -
- LBU       100100        -
- LHU       100101        -
- ADDI      001000        -
- ORI       001101        -
- XORI      001110        -
- LUI       001111        -
- SLTI      001010        -
______________________________________________
TABLE OF INSTRUCTIONS TO USE GPR 31:
**Name------opcode-----function----
- JAL       000011        -

______________________________________________
EXCLUIDED INSTRUCTIONS:
The following instructions not use register destiny flag:
**Name------opcode-----function----
- JR        000000      001000
- J         000010        -
- BEQ       000100        -
- BNE       000101        -
- SB        101000        -
- SH        101001        -
- SW        101011        -

*/

localparam SELECT_RD = 2'b00;
localparam SELECT_RT = 2'b01;
localparam SELECT_GPR31 = 2'b10;

always @(*)
begin 
    case(i_instruction[MSB_OPCODE:LSB_OPCODE])
        // Only the following instructions use "SELECT_GPR31" as register destiny flag
        OPCODE_JAL : ex_reg_dest_sel = SELECT_GPR31;
        // All the aritmetic and special instructions use "SELECT_RD" as register destiny flag. Also jalr
        // NOTE: tje jr instruction is not included in this case because it does not use register destiny flag
        OPCODE_ARITMETIC_OR_SPECIAL : ex_reg_dest_sel = SELECT_RD;
        default : ex_reg_dest_sel = SELECT_RT; // all the rest instructions use "SELECT_RT" as register destiny flag
    endcase
end

/**-----------------------------------------------------------------------------------------------------------------------
** Memory Wreite To Register Flag Logic
** -----------------------------------------------------------------------------------------------------------------------
** 
   exisiting 2 cases:
    - 0 - no write back
    - 1 - write back
____________________________________________
TABLE OF INSTRUCTIONS WRITE in Register Memory:
**------opcode------function---
- <arit>    000000        -
- LB    100000        -
- LH    100001        -
- LW    100011        -
- LWU   100111        -
- LBU   100100        -
- LHU   100101        -
- ADDI  001000        -
- ORI   100101        -
- XORI  001110        -
- LUI   001111        -
_______________________________________________
*/
localparam MEM_WRITE_BACK = 1'b1;
localparam MEM_NO_WRITE_BACK = 1'b0;

always @(*)
begin 
    case(i_instruction[MSB_OPCODE:LSB_OPCODE])
        OPCODE_ARITMETIC_OR_SPECIAL : mem_write_read_flag = MEM_WRITE_BACK;
        OPCODE_ADDI : mem_write_read_flag = MEM_WRITE_BACK;
        OPCODE_ORI :  mem_write_read_flag = MEM_WRITE_BACK;
        OPCODE_XORI :  mem_write_read_flag = MEM_WRITE_BACK;
        OPCODE_LUI :  mem_write_read_flag = MEM_WRITE_BACK;
        OPCODE_SLTI : mem_write_read_flag = MEM_WRITE_BACK;
        OPCODE_LB : mem_write_read_flag = MEM_WRITE_BACK;
        OPCODE_LH :  mem_write_read_flag = MEM_WRITE_BACK;
        OPCODE_LW :  mem_write_read_flag = MEM_WRITE_BACK;
        OPCODE_LWU :  mem_write_read_flag = MEM_WRITE_BACK;
        OPCODE_LBU :  mem_write_read_flag = MEM_WRITE_BACK;
        OPCODE_LHU : mem_write_read_flag = MEM_WRITE_BACK;
        default : mem_write_read_flag = MEM_NO_WRITE_BACK;
    endcase
end
/**-----------------------------------------------------------------------------------------------------------------------
** Memory Write OR Read Flag Logic
** -----------------------------------------------------------------------------------------------------------------------

** select memory write register flag based on opcode and funct
   exisiting 2 cases:
    - 0 - read memory
    - 1 - write memory  
____________________________________________
TABLE OF INSTRUCTIONS TO USE MEM_WRITE:
**Name------opcode-----function----
- SB        101000        -
- SH        101001        -
- SW        101011        -
The rest instructions not use memory write flag or READ memory
*/

localparam MEM_READ = 1'b0;
localparam MEM_WRITE = 1'b1;
always @(*)
begin 
    case(i_instruction[MSB_OPCODE:LSB_OPCODE])
        // Only the following instructions use "1" as memory write flag
        OPCODE_SB : mem_write_read_flag = MEM_WRITE;
        OPCODE_SH : mem_write_read_flag = MEM_WRITE;
        OPCODE_SW : mem_write_read_flag = MEM_WRITE;
        default : mem_write_read_flag = MEM_READ; // all the rest instructions use "0" as memory write flag
    endcase
end

//!TODO: es necario otra flag para leer?

/**-----------------------------------------------------------------------------------------------------------------------
** Memory LOAD MASK : byte half or word
** --------------------------------------------------------------------------------------------------------------------------
**Name------opcode-----function----
- SB        101000        -
- SH        101001        -
- SW        101011        -
*/

localparam MASK_STORE_NONE_MASK = 2'b00;
localparam MASK_STORE_BYTE = 2'b01;
localparam MASK_STORE_HALF = 2'b10;
localparam MASK_STORE_WORD = 2'b11;

always @(*)
begin 
    case(i_instruction[MSB_OPCODE:LSB_OPCODE])
        // Only the following instructions use "1" as memory write flag
        OPCODE_SB : mem_store_mask = MASK_STORE_BYTE;
        OPCODE_SH : mem_store_mask = MASK_STORE_HALF;
        OPCODE_SW : mem_store_mask = MASK_STORE_WORD;
        default : mem_store_mask = MASK_STORE_NONE_MASK; // all the rest instructions not use this flag
    endcase
end


/**-----------------------------------------------------------------------------------------------------------------------
** Memory LOAD MASK : byte half or word
** --------------------------------------------------------------------------------------------------------------------------
**Name------opcode-----function----
- LB        100000        -
- LH        100001        -
- LW        100011        -
- LWU       100111        -
- LBU       100100        -
- LHU       100101        -
*/

localparam MASK_LOAD_NONE_MASK = 3'b00;
localparam MASK_LOAD_SIGNED_BYTE = 3'b01;
localparam MASK_LOAD_SIGNED_HALF = 3'b10;
localparam MASK_LOAD_SIGNED_WORD = 3'b11;
localparam MASK_LOAD_UNSIGNED_BYTE = 3'b100;
localparam MASK_LOAD_UNSIGNED_HALF = 3'b101; 
localparam MASK_LOAD_UNSIGNED_WORD = 3'b110;

always @(*)
begin 
    case(i_instruction[MSB_OPCODE:LSB_OPCODE])
        // Only the following instructions use "1" as memory write flag
        OPCODE_LB : mem_load_mask = MASK_LOAD_SIGNED_BYTE;
        OPCODE_LH : mem_load_mask = MASK_LOAD_SIGNED_HALF;
        OPCODE_LW : mem_load_mask = MASK_LOAD_SIGNED_WORD;
        OPCODE_LWU : mem_load_mask = MASK_LOAD_UNSIGNED_WORD;
        OPCODE_LBU : mem_load_mask = MASK_LOAD_UNSIGNED_BYTE;
        OPCODE_LHU : mem_load_mask = MASK_LOAD_UNSIGNED_HALF;
        default : mem_load_mask = MASK_LOAD_NONE_MASK;
    endcase
end

/**-----------------------------------------------------------------------------------------------------------------------
** WriteBAck Memory to Register Flag
** --------------------------------------------------------------------------------------------------------------------------
**Name------opcode-----function----
- LB        100000        -
- LH        100001        -
- LW        100011        -
- LWU       100111        -
- LBU       100100        -
- LHU       100101        -
*/

localparam LOAD_FROM_ALU = 1'b0;
localparam LOAD_FROM_MEM = 1'b1;

always @(*)
begin 
    case(i_instruction[MSB_OPCODE:LSB_OPCODE])
        OPCODE_LB : wb_mem_to_reg_sel = LOAD_FROM_MEM;
        OPCODE_LH : wb_mem_to_reg_sel = LOAD_FROM_MEM;
        OPCODE_LW : wb_mem_to_reg_sel = LOAD_FROM_MEM;
        OPCODE_LWU : wb_mem_to_reg_sel = LOAD_FROM_MEM;
        OPCODE_LBU : wb_mem_to_reg_sel = LOAD_FROM_MEM;
        OPCODE_LHU : wb_mem_to_reg_sel = LOAD_FROM_MEM;
        default : wb_mem_to_reg_sel = LOAD_FROM_ALU; //aritmetic and special instructions
    endcase
end

/**-----------------------------------------------------------------------------------------------------------------------
** WriteBAck Memory to Register Flag
** --------------------------------------------------------------------------------------------------------------------------
**Name------opcode-----function----
The next instructionswrite back to register
**Name------opcode-----function----
- <arit>    000000        -
- LB    100000        -
- LH    100001        -
- LW    100011        -
- LWU   100111        -
- LBU   100100        -
- LHU   100101        -
- ADDI  001000        -
- ORI   100101        -
- XORI  001110        -
- LUI   001111        -
_______________________________________________
*/

localparam WRITE_BACK = 1'b1;
localparam NO_WRITE_BACK = 1'b0;

always @(*)
begin 
    case(i_instruction[MSB_OPCODE:LSB_OPCODE])
        OPCODE_ARITMETIC_OR_SPECIAL : wb_write_back_flag = WRITE_BACK;
        OPCODE_ADDI : wb_write_back_flag = WRITE_BACK;
        OPCODE_ORI : wb_write_back_flag = WRITE_BACK;
        OPCODE_XORI : wb_write_back_flag = WRITE_BACK;
        OPCODE_LUI : wb_write_back_flag = WRITE_BACK;
        OPCODE_SLTI : wb_write_back_flag = WRITE_BACK;
        OPCODE_LB : wb_write_back_flag = WRITE_BACK;
        OPCODE_LH : wb_write_back_flag = WRITE_BACK;
        OPCODE_LW : wb_write_back_flag = WRITE_BACK;
        OPCODE_LWU : wb_write_back_flag = WRITE_BACK;
        OPCODE_LBU : wb_write_back_flag = WRITE_BACK;
        OPCODE_LHU : wb_write_back_flag = WRITE_BACK;
        default : wb_write_back_flag = NO_WRITE_BACK;
    endcase
end



/**-----------------------------------------------------------------------------------------------------------------------
/**-----------------------------------------------------------------------------------------------------------------------
** ASSIGN OUTPUTS
** --------------------------------------------------------------------------------------------------------------------------
** --------------------------------------------------------------------------------------------------------------------------
*/
assign  o_next_pc_select = next_pc_select;
assign  o_ex_alu_src_a = ex_alu_src_a;
assign  o_ex_alu_src_b = ex_alu_src_b;
assign  o_ex_reg_dest_sel = ex_reg_dest_sel;
assign  o_mem_write_to_register_flag = mem_write_to_register_flag;
assign  o_mem_write_read_flag = mem_write_read_flag;
assign  o_mem_load_mask = mem_load_mask;
assign  o_mem_store_mask = mem_store_mask;
assign  o_wb_mem_to_reg_sel = wb_mem_to_reg_sel;
assign  o_wb_write_back_flag = wb_write_back_flag;


endmodule