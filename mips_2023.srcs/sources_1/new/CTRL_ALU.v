`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.06.2023 05:49:12
// Design Name: 
// Module Name: CTRL_ALU
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


module CTRL_ALU#(
        //Parameters
        parameter   N_BITS_FUNC = 6,
        parameter   N_BITS_ALUOP = 6,
        parameter   N_BITS_ALUCON = 4
    )
    (
        // Inputs
        input wire  [N_BITS_FUNC - 1 : 0]   i_funct,      // Codigo de instruccion para las Instrucciones tipo R 
        input wire  [N_BITS_ALUOP - 1 : 0]  i_alu_opcode, // Tipo de instruccion       

        // Output
        output wire  [N_BITS_ALUCON - 1 : 0] o_alu_ctrl   // Señal que va a la ALU con el codigo de operacion
    );

// Define opcodes
    localparam OPCODE_ARITMETIC_OR_SPECIAL = 6'b000000;   // aritmetic, or special (in grl is R type instructions)
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
    localparam OPCODE_ORI  = 6'b001101;
    localparam OPCODE_XORI = 6'b001110;
    localparam OPCODE_LUI  = 6'b001111;
    localparam OPCODE_SLTI = 6'b001010;
    localparam OPCODE_ANDI = 6'b001100;

    // Define functs
    localparam   SLL_FUNCTIONCODE =  6'b000000;
    localparam   SRL_FUNCTIONCODE =  6'b000010;
    localparam   SRA_FUNCTIONCODE =  6'b000011;
    localparam   ADD_FUNCTIONCODE =  6'b100000;
    localparam   SUB_FUNCTIONCODE =  6'b100010;
    localparam   AND_FUNCTIONCODE =  6'b100100;
    localparam   OR_FUNCTIONCODE  =  6'b100101;
    localparam   XOR_FUNCTIONCODE =  6'b100110;
    localparam   NOR_FUNCTIONCODE =  6'b100111;
    localparam   SLT_FUNCTIONCODE =  6'b101010;
    localparam   SLLV_FUNCTIONCODE = 6'b000100;
    localparam   SRLV_FUNCTIONCODE = 6'b000110;
    localparam   SRAV_FUNCTIONCODE = 6'b000111;

    reg  [N_BITS_ALUCON - 1 : 0] alu_ctrl ;

    always@(*) begin
        case(i_alu_opcode)
            OPCODE_ARITMETIC_OR_SPECIAL:                      // INSTRUCCIONES RTYPE 
                case(i_funct)
                    SLL_FUNCTIONCODE :   alu_ctrl = 4'b0000;  //  SLL Shift left logical (r1<<r2)  
                    SRL_FUNCTIONCODE :   alu_ctrl = 4'b0001;  // SRL Shift right logical (r1>>r2)  
                    SRA_FUNCTIONCODE :   alu_ctrl = 4'b0010;  // SRA  Shift right arithmetic (r1>>>r2)
                    ADD_FUNCTIONCODE :   alu_ctrl = 4'b0011;  // ADD Sum (r1+r2)
                    SUB_FUNCTIONCODE :   alu_ctrl = 4'b0100;  // SUB Substract (r1-r2)
                    AND_FUNCTIONCODE :   alu_ctrl = 4'b0101;  // AND Logical and (r1&r2)
                    OR_FUNCTIONCODE :    alu_ctrl = 4'b0110;  // OR Logical or (r1|r2)
                    XOR_FUNCTIONCODE :   alu_ctrl = 4'b0111;  // XOR Logical xor (r1^r2)
                    NOR_FUNCTIONCODE :   alu_ctrl = 4'b1000;  // NOR Logical nor ~(r1|r2)
                    SLT_FUNCTIONCODE :   alu_ctrl = 4'b1001;  // SLT Compare (r1<r2)
                    SLLV_FUNCTIONCODE :  alu_ctrl = 4'b1010;  // SLLV
                    SRLV_FUNCTIONCODE :  alu_ctrl = 4'b1011;  // SRLV
                    SRAV_FUNCTIONCODE :  alu_ctrl = 4'b1100;  // SRAV
                    default :            alu_ctrl = 4'b0000;
                endcase                
            OPCODE_ADDI : alu_ctrl = 4'b0011;  // -> ADD de ALU
            OPCODE_ANDI : alu_ctrl = 4'b0101;  // -> AND de ALU
            OPCODE_ORI : alu_ctrl = 4'b0110;  // -> OR de ALU
            OPCODE_XORI : alu_ctrl = 4'b0111;  // -> XOR de ALU
            OPCODE_LUI : alu_ctrl = 4'b1101;  // -> SLL16 de ALU
            OPCODE_SLTI : alu_ctrl = 4'b1001;  // -> SLT de ALU
            OPCODE_BEQ : alu_ctrl = 4'b0100;  // -> SUB de ALU
            OPCODE_BNE : alu_ctrl = 4'b1110;  // -> NEQ de ALU
            default : alu_ctrl = 4'b0000;
        endcase
    end
    assign o_alu_ctrl = alu_ctrl;
endmodule
