`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Julieta Prieto y Mateo Merino
// 
// Create Date: 20.06.2023 04:21:54
// Design Name: 
// Module Name: short_circuit_unit
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


module SHORT_CIRCUIT_UNIT
    (
        input wire            i_ex_mem_reg_write_flag,  // Flag de escritura de registro extraido desde EX_MEM.
        input wire            i_mem_wb_reg_write_flag,  // Flag de escritura de registro extraido desde MEM_WB.
        input wire [4:0]      i_id_ex_rs,  // Registro rs extraido desde ID_EX.
        input wire [4:0]      i_id_ex_rt,  // Registro rt extraido desde ID_EX.
        input wire [4:0]      i_ex_mem_write_addr,  // Registro AddrWriteBack desde EX_MEM.
        input wire [4:0]      i_mem_wb_write_addr,  // Registro AddrWriteBack desde MEM_WB.
        output wire [1:0]      o_sel_short_circuit_A,  //Selectores para el cortocircuito A.
        output wire [1:0]      o_sel_short_circuit_B  //Selectores para el cortocircuito B.
    );

    // Registros:
    reg [1:0] sel_short_circuit_A;
    reg [1:0] sel_short_circuit_B;

    /*** Condiciones del cortocircuito ****/

    // Condiciones del operando A:
    always@(*) begin

        // Si no se escribe sobre el registro, no hay cortocircuito.
        if((i_ex_mem_reg_write_flag == 0) && (i_mem_wb_reg_write_flag == 0))
        begin
            sel_short_circuit_A = 2'b00;
        end

        if ((i_ex_mem_write_addr == i_id_ex_rs) && (i_ex_mem_reg_write_flag))
        begin
            sel_short_circuit_A = 2'b01;  // cortocircuito el resultado de la ALU.
        end
        if ((i_mem_wb_write_addr == i_id_ex_rs) && (i_mem_wb_reg_write_flag))
        begin
            sel_short_circuit_A = 2'b10;  // cortocircuito el dato de WB.
        end

    // Condiciones para operando B:

        // Si no se escribe sobre el registro, no hay cortocircuito.
        if((i_ex_mem_reg_write_flag == 0) && (i_mem_wb_reg_write_flag == 0))
        begin
            sel_short_circuit_B = 2'b00;
        end

        if (i_ex_mem_write_addr == i_id_ex_rt && i_ex_mem_reg_write_flag)
        begin
           sel_short_circuit_B = 2'b01;  // Cortocircuito el resultado de la ALU.
        end
        else if (i_mem_wb_write_addr == i_id_ex_rt && i_mem_wb_reg_write_flag) 
        begin
            sel_short_circuit_B = 2'b10;  // Cortocircuito el dato de WB.
        end
        else
        begin
            sel_short_circuit_B = 2'b00;  // No hay cortocircuito.
        end
    end

    assign o_sel_short_circuit_B = sel_short_circuit_B;
    assign o_sel_short_circuit_A = sel_short_circuit_A;

endmodule
