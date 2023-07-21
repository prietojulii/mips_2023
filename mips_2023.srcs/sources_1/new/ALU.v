`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Julieta Prieto y Mateo Merino
// 
// Create Date: 20.06.2023 05:44:44
// Design Name: 
// Module Name: ALU
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


module ALU#(
        //Parameters
        parameter   N_BITS_REG = 32,
        parameter   N_BITS_ALU = 4
    )    
    (
        //Inputs
        input wire  [N_BITS_REG - 1 : 0]   i_op_a,
        input wire  [N_BITS_REG - 1 : 0]   i_op_b,
        input wire  [N_BITS_ALU - 1 : 0]   i_ctrl_alu,

        //Outputs
        output wire  [N_BITS_REG - 1 : 0]    o_result 
    );

    reg [N_BITS_REG - 1 : 0] result;
    always@(*) begin
        case(i_ctrl_alu)
            4'b0000 : result = i_op_a << i_op_b;      //  SLL Shift left logical (r1<<r2)
            4'b0001 : result = i_op_a >> i_op_b;      // SRL Shift right logical (r1>>r2)
            4'b0010 : result = i_op_a >>> i_op_b;     // SRA  Shift right arithmetic (r1>>>r2)
            4'b0011 : result = i_op_a + i_op_b;       // ADD Sum (r1+r2)
            4'b0100 : result = i_op_a - i_op_b;       // SUB Substract (r1-r2)
            4'b0101 : result = i_op_a & i_op_b;       // AND Logical and (r1&r2)
            4'b0110 : result = i_op_a | i_op_b;       // OR Logical or (r1|r2)
            4'b0111 : result = i_op_a ^ i_op_b;       // XOR Logical xor (r1^r2)
            4'b1000 : result = ~(i_op_a | i_op_b);    // NOR Logical nor ~(r1|r2)
            4'b1001 : result = i_op_a < i_op_b;       // SLT Compare (r1<r2)
            4'b1010 : result = i_op_a << i_op_b;      // SLLV
            4'b1011 : result = i_op_a >> i_op_b;      // SRLV
            4'b1100 : result = i_op_a >>> i_op_b;     // SRAV
            4'b1101 : result = i_op_a << 16;          // SLL16
            4'b1110 : result = (i_op_a == i_op_b);    // NEQ
            default : result = {N_BITS_REG{1'b0}}; 
        endcase
    end

assign o_result = result;
endmodule