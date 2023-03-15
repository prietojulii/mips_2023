`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.02.2023 17:35:39
// Design Name: 
// Module Name: main
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


module Main
#(
    parameter REG_SIZE= 32,
    parameter PC_SIZE= 32,
    parameter TRAMA_SIZE = 8
)(


    // input wire i_rx,
    // output wire o_tx,
    input wire i_clock,
    input wire i_reset,
    input wire wire_flag_start_program_prueba,
    input wire wire_flag_instruction_write_prueba,
    input wire [REG_SIZE-1:0] wire_debuguer_instruction_data_prueba

    );


// wire [TRAMA_SIZE-1:0] wire_trama;
// wire wire_flag_rx_done;
// UART uart_instance(
//     .i_clk(i_clock),
//     .i_reset(i_reset),
//     .i_rx(i_rx),
//     .i_tx(),
//     .i_tx_start(),
//     .o_rx(wire_trama),
//     .o_rx_done_tick(wire_flag_rx_done),
//     .o_tx(o_tx),
//     .o_tx_done_tick()
// );

// wire wire_flag_start_program, wire_flag_instruction_write;
// wire [REG_SIZE-1:0] wire_debuguer_instruction_data;
// Debuguer debug_instace (
//     .i_clk(i_clock),
//     .i_reset(i_reset),
//    .i_command(wire_trama),
//    .i_flag_rx_done(wire_flag_rx_done),
//    .o_flag_instruction_write(wire_flag_instruction_write),
//    .o_instruction_data(wire_debuguer_instruction_data)
//    .o_flag_start_program(wire_flag_start_program),
// );
/*
    LOS CABLES i_clock e i_reset son para TODOS LOS MÓDULOS
*/

/*
******WIRES DECLARED FOR IF INSTACE*****
*/
wire [PC_SIZE-1:0] wire_if_pc4;                                         //Cable que sale del módulo IF del siguiente PC.
wire [REG_SIZE -1:0] wire_if_instruction;                               //Cable que sale del módulo IF con la instrucción correspondiente a ejecutar.
wire [REG_SIZE -1:0] wire_no_load_pc_flag;                              //Cable que ingresa al módulo PC, flag de que no hay que cargar el PC.
wire [PC_SIZE-1:0] wire_id_pc_next;                                     //Cable que ingresa desde el módulo ID con el próximo PC.
/*
******IF INSTACE*****
*/
IF if_instance(
    .i_clk(i_clock),
    .i_reset(i_reset),
    .i_flag_start_program(wire_flag_start_program_prueba),          
    .i_flag_new_inst_ready(wire_flag_instruction_write_prueba),
    .i_instruction_data(wire_debuguer_instruction_data_prueba),
    // .i_is_halt(),
    .i_no_load(wire_no_load_pc_flag),
    .i_next_pc(wire_id_pc_next), //TODO: conectar
    .o_instruction_data(wire_if_instruction),
    .o_next_pc(wire_if_pc4) //TODO: cambiar pc_next a pc4
);

/*
******WIRES DECLARED FOR IFID INSTACE*****
*/
wire [PC_SIZE-1:0] wire_id_pc4;                                         //Cable sale del latch IF/ID con el siguiente PC.
wire wire_id_instruction;                                               //Cable que sale del latch IF/ID con la instrucción a ingresar en la etapa ID.

/*
******IFID INSTACE*****
*/
IFID ifid_instance (
    .i_clock(i_clock),
    .i_reset(i_reset),
    .i_instruction_data(wire_if_instruction),
    .i_next_pc(wire_if_pc4),
    .o_instruction_data(wire_id_instruction),
    .o_next_pc(wire_id_pc4) //!todo: CAMBIAR A PC4
);

/*
******WIRES DECLARED FOR CONTROL MAIN INSTANCE*****
*/
wire wire_ctrl_ex_alu_src_a;                                            //Cable que controla el operando A en ALU.
wire wire_ctrl_mem_write_to_register_flag;                              //Cable que controla la escritura de Memoria hacia los Registros
wire wire_ctrl_mem_write_read_flag;                                     //Cable que controla si se escribe o se lee en la memoria de Datos.
wire wire_ctrl_mem_store_mask;                                          //Cable que controla la mascara en la memoria de Datos. (DUDA)
wire wire_ctrl_wb_mem_to_reg_sel;                                       //Cable que controla si se escribirá desde la memeoria de Datos hacia la memoria de Registros.
wire wire_ctrl_wb_write_back_flag;                                      //Cable que controla si hay un Write Back.
wire wire_id_is_A_B_equal_flag;                                         //Cable que controla si A es igual a B en la etapa ID para los Branch.

wire [1:0] wire_ctrl_next_pc_select;                                    //Cable que controla la selección del próximo PC.
wire [1:0] wire_ctrl_ex_alu_src_b;                                      //Cable que controla la selección el operando B en la entrada de la ALU
wire [1:0] wire_ctrl_ex_reg_dest_sel;                                   //Cable que controla la selección del registro INMEDIATO que pasa por la etapa EX.
wire [2:0] wire_ctrl_mem_load_mask;                                     //Cable que controla la mascara en la memoria de Datos. (DUDA)

/*
******CONTROL MAIN INSTANCE*****
*/
ControlMain control_main_instance( 
    .i_clock(i_clock),
    .i_reset(i_reset),
    .i_instruction(wire_id_instruction),
    .i_is_A_B_equal_flag(wire_id_is_A_B_equal_flag),
    .o_next_pc_select(wire_ctrl_next_pc_select),
    .o_ex_alu_src_a(wire_ctrl_ex_alu_src_a),
    .o_ex_alu_src_b(wire_ctrl_ex_alu_src_b),
    .o_ex_reg_dest_sel(wire_ctrl_ex_reg_dest_sel),
    .o_mem_write_to_register_flag(wire_ctrl_mem_write_to_register_flag),
    .o_mem_write_read_flag(wire_ctrl_mem_write_read_flag),
    .o_mem_load_mask(wire_ctrl_mem_load_mask),
    .o_mem_store_mask(wire_ctrl_mem_store_mask),
    .o_wb_mem_to_reg_sel(wire_ctrl_wb_mem_to_reg_sel),
    .o_wb_write_back_flag(wire_ctrl_wb_write_back_flag)
);

/*
******WIRES DECLARED FOR ID INSTANCE*****
*/
wire [4:0] wire_id_rs;                                                      //Cable que sale de la etapa ID con el registro RS                                          
wire [4:0] wire_id_rt;                                                      //Cable que sale de la etapa ID con el registro RT
wire [4:0] wire_id_rd;                                                      //Cable que sale de la etapa ID con el registro RD
wire [REG_SIZE-1:0] wire_id_shamt;                                          //Cable que sale de la etapa ID con el registro SHAMT 
wire [REG_SIZE-1:0] wire_id_indmediate;                                     //Cable que sale de la etapa ID con el registro IMMEDIATE 
wire [REG_SIZE-1:0] wire_id_dataA;                                          //Cable que sale de la etapa ID con el registro DATA_A 
wire [REG_SIZE-1:0] wire_id_dataB;                                          //Cable que sale de la etapa ID con el registro DATA_B 
//wire [PC_SIZE-1:0] wire_id_pc_next;
wire [5:0] wire_id_function;                                                //Cable que sale de la etapa ID con el FUNCTION 
wire [5:0] wire_id_opcode;                                                  //Cable que sale de la etapa ID con el OPCODE

/*
******ID INSTANCE*****
*/
ID id_instace (
    .i_clock(i_clock),
    .i_reset(i_reset),
    .i_ctrl_next_pc_sel(wire_ctrl_next_pc_select),                          //Cable que controla la selección del próximo PC, viene de la CONTROL UNIT.
    // .i_write_wb_flag(),
    // .i_addr_wr(),
    // .i_data_wb(),
    .i_instruction(wire_id_instruction),                                    //Cable que ingresa a la etapa ID con la instrucción, viene del latch IFID
    .i_pc4(wire_id_pc4),                                                    //Cable que ingresa a la etapa ID con el PC4, viene del latch IFID
    .o_rs(wire_id_rs),
    .o_rt(wire_id_rt),
    .o_rd(wire_id_rd),
    .o_shamt_extend(wire_id_shamt),
    .o_imm_extend(wire_id_indmediate),
    .o_data_A(wire_id_dataA),
    .o_data_B(wire_id_dataB),
    .o_pc_next(wire_id_pc_next),
    .o_funct(wire_id_function),
    .o_op(wire_id_opcode),
    .o_is_A_B_equal_flag(wire_id_is_A_B_equal_flag)                         //Cable que controla si A es igual a B en la etapa ID para los Branch; viene de la CONTROL UNIT.                         
);

/*
******WIRES DECLARED FOR RISK UNIT *****
*/
wire wire_arithmetic_risk_flag;                                             //Cable que sale de la unidad de Riesgo, flag de riesgo aritmético.
wire wire_load_flag;                                                        //Cable que sale de la unidad de Riesgo, flag de riesgo de load.
wire [4:0] wire_ex_rs;                                                      //Cable que viene de la etapa EX con el registro RS       
wire [4:0] wire_ex_rt;                                                      //Cable que viene de la etapa EX con el registro RT                  
wire [4:0] wire_ex_rd;                                                      //Cable que viene de la etapa EX con el registro RD
wire [5:0] wire_ex_opcode;                                                  //Cable que viene de la etapa EX con el OPCODE 

/*
******RISK UNIT INSTANCE*****
*/
risk_unit risk_unit_instance(
    .i_clk(i_clock),
    .i_reset(i_reset),
//TODO: Ver que onda este cable .i_flag_first_ex_instruction(i_flag_first_ex_instruction),
     .i_rs_ex(wire_ex_rs),                  //Todos estos cables son del latch ID/EX
     .i_rd_ex(wire_ex_rd),
     .i_rt_ex(wire_ex_rt),
     .i_op_ex(wire_ex_opcode),
    .i_instruction_id(wire_id_instruction),                                 //Cable que ingresa a la Risk Unit con la instrucción, viene del latch IFID.
    .o_arithmetic_risk_flag(wire_arithmetic_risk_flag),
    .o_load_flag(wire_load_flag),
    .o_no_load_pc_flag(wire_no_load_pc_flag)                                 //Cable que ingresa al módulo PC, flag de que no hay que cargar el PC. Declarado en la etapa IF.
);




wire [4:0] wire_ex_rs, wire_ex_rt, wire_ex_rd;
wire [REG_SIZE-1:0] wire_ex_shamt, wire_ex_indmediate, wire_ex_dataA, wire_ex_dataB;
wire [PC_SIZE-1:0] wire_ex_pc_next;
wire [5:0] wire_ex_function; 
// IDEX idex_instance (
//     .i_clock(i_clock),
//     .i_reset(i_reset),
//     .i_rs(wire_id_rs),
//     .i_rt(wire_id_rt),
//     .i_rd(wire_id_rd),
//     .i_shamt_extend(wire_id_shamt),
//     .i_imm_extend(wire_id_indmediate),
//     .i_dataA(wire_id_dataA),
//     .i_dataB(wire_id_dataB),
//     .i_pc4(wire_id_pc4),
//     .i_pc_next(wire_id_pc_next),
//     .i_funct(wire_id_function),
//     .i_op(wire_id_opcode),
//     .o_rs(wire_ex_rs),
//     .o_rt(wire_ex_rt),
//     .o_rd(wire_ex_rd),
//     .o_shamt_extend(wire_ex_shamt),
//     .o_imm_extend(wire_ex_indmediate),
//     .o_dataA(wire_ex_dataA),
//     .o_dataB(wire_ex_dataB),
//     // .o_pc_next(wire_ex_pc_next), //TODO: no se lachea por que se conserva con la burbuja si es condicional y si fuese incondicional deberia actualizar autoaticamente el pc
//     .o_funct(wire_ex_function),
//     .o_op(wire_ex_opcode)

//      //* Signals from Unit Control
//     //to EX
//     // .i_ctrl_EX_regDEST_flag(),     
//     // .i_ctrl_EX_ALU_source_B_flag(),
//     // .i_ctrl_EX_ALU_source_A_flag(),
//     // .i_ctrl_EX_ALUop_flag(),       
//     // .i_ctrl_EX_Branch_flag(), 
//     // .o_ctrl_EX_regDEST_flag(),
//     // .o_ctrl_EX_ALU_source_B_flag(),
//     // .o_ctrl_EX_ALU_source_A_flag(),
//     // .o_ctrl_EX_ALUop_flag(),
//     // .o_ctrl_EX_Branch_flag(),

//     //to MEM
//     // .i_ctrl_MEM_memWrite_flag(),
//     // .i_ctrl_MEM_memRead_flag(),
//     // .i_ctrl_MEM_byte_half_or_word_flag(),
//     // .i_ctrl_MEM_wr_reg_flag,(),
//     // .o_ctrl_MEM_memWrite_flag(),
//     // .o_ctrl_MEM_memRead_flag(),
//     // .o_ctrl_MEM_byte_half_or_word_flag(),
//     // .o_ctrl_MEM_wr_reg_flag(),

//     //to WB
//     // .i_ctrl_WB_memToReg_flag(),
//     // .i_ctrl_WB_wr_flag(),
//     // .o_ctrl_WB_memToReg_flag(),
//     // .o_ctrl_WB_wr_fla(),
// );
endmodule
