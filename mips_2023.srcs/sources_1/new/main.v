`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mateo Merino y Julieta Prieto.
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
    input wire i_clock,
    input wire i_reset,
    input wire i_rx,

    output wire [3:0] o_wire_state_leds_pins,
    output wire [3:0] o_wire_state_program_memory_pins,
    output wire o_tx,
    output wire o_wire_if_new_inst_ready
    // output wire o_wire_flag_instruction_write,
    // output wire [2:0] o_wire_bytes_counter_leds_pins,
    // output wire [8:0] o_main_pc_next,
    // output wire [8:0] o_wire_instruction_buffer_MSB_leds_pin
    
    );

 wire wire_uart_main_tx, wire_uart_debug_tx_done;
 wire [(TRAMA_SIZE-1):0] wire_debuguer_uart_tx;
 wire [TRAMA_SIZE-1:0] wire_trama;
 wire wire_flag_rx_done;
 wire wire_debuger_uart_tx_start;
 UART uart_instance(
     .i_clk(i_clock),
     .i_reset(i_reset),
     .i_rx(i_rx),
     .i_tx(wire_debuguer_uart_tx),
     .i_tx_start(wire_debuger_uart_tx_start),
     .o_rx(wire_trama),
     .o_rx_done_tick(wire_flag_rx_done),
     .o_tx(wire_uart_main_tx),
     .o_tx_done_tick(wire_uart_debug_tx_done) //tx done
 );


/**
* WB wires
**/
wire [REG_SIZE-1:0] wb_mem_data_to_wb,wb_wire_mem_alu_result;
wire wb_wire_mem_ctrl_WB_memToReg_flag;
wire wb_wire_mem_ctrl_WB_wr_flag;
wire [4:0] wb_addr_wb;
wire [REG_SIZE-1:0] wb_wire_mem_data_to_wb;


 /***
EXMEM WIRES
***/

wire [(REG_SIZE-1):0] wire_mem_alu_result, wire_mem_data_B;
wire [4:0] wire_mem_addr_wb;
wire wire_mem_ctrl_WB_wr_flag;
wire wire_mem_MEM_mem_write_or_read_flag;
wire [1:0] wire_mem_MEM_store_mask;
wire [2:0] wire_mem_MEM_load_mask;
wire wire_mem_ctrl_WB_memToReg_flag;



/***
Debuguer WIRES
***/
wire [REG_SIZE -1:0] wire_if_instruction;                               //Cable que sale del m�dulo IF con la instrucci�n correspondiente a ejecutar.
wire [REG_SIZE-1:0] wire_id_dataA;                                          //Cable que sale de la etapa ID con el registro DATA_A 
wire [REG_SIZE-1:0] wire_id_dataB;                                          //Cable que sale de la etapa ID con el registro DATA_B 
wire [4:0] wire_id_rs;                                                      //Cable que sale de la etapa ID con el registro RS                                          
wire [4:0] wire_id_rt;                                                      //Cable que sale de la etapa ID con el registro RT
 wire wire_flag_start_program, wire_flag_instruction_write;
 wire wire_debuguer_latch_enable_pc;  
 wire [REG_SIZE-1:0] wire_debuguer_instruction_data;
 wire [3:0] wire_state_leds;
 Debuguer debug_instace (
    .i_clk(i_clock),
    .i_reset(i_reset),
    .i_command(wire_trama),
    .i_flag_rx_done(wire_flag_rx_done),
    .i_flag_tx_done(wire_uart_debug_tx_done),
    //.i_flag_halt()
    //.i_pc(),
    // .i_rs(wire_id_rs),
    // .i_rt(wire_id_rt),
    // .i_a(wire_id_dataA),
    // .i_b(wire_id_dataB),
    //.i_addr_mem(),
    //.i_data_mem(),
    //....
    .o_flag_instruction_write(wire_flag_instruction_write),
    .o_enable_pc(wire_debuguer_latch_enable_pc),
    .o_instruction_data(wire_debuguer_instruction_data),
    .o_trama_tx(wire_debuguer_uart_tx),
    .o_tx_start(wire_debuger_uart_tx_start),
    .o_flag_start_program(wire_flag_start_program), // ESTE CABLE SE ENVIA A TODAS LAS UNIDADES LATCH (y pc) PARA HABILITARLAS O DESHABILITARLAS

    //TODO: borrar pruebas:
    .o_wire_state_leds(wire_state_leds),
    // .i_wire_if_instruction(wire_if_instruction),
    .i_buffer_to_send(
        // { {27{1'b1}}  , wb_addr_wb }
        {
            wire_id_dataA,
            wire_id_dataB,
            wire_mem_alu_result,
            wb_wire_mem_data_to_wb,
            {28'b0, wire_ctrl_wb_mem_to_reg_sel,wire_ex_ctrl_WB_memToReg_flag,wire_mem_ctrl_WB_memToReg_flag,wb_wire_mem_ctrl_WB_memToReg_flag},
            {28'b0,wire_ctrl_ex_reg_dest_sel,wire_ex_ctrl_EX_regDEST_flag},//Selector para controlar la seleccion del registro
            {28'b0,wire_ctrl_wb_write_back_flag,wire_ex_ctrl_WB_wr_flag,wire_mem_ctrl_WB_wr_flag,wb_wire_mem_ctrl_WB_wr_flag}, 
            {27'b0, exmem_addr_wb}, //salida del mux con addr wb
            {27'b0, wire_mem_addr_wb},// salida latcheada
            {27'b0, wb_addr_wb}, //entrada al MEM reg
            wire_id_pc4,
            wire_id_instruction,
            {31'b0,wire_id_is_A_B_equal_flag},
            {30'b0, wire_ctrl_next_pc_select}, //selector
            wire_id_pc_next,
            {31'b0, wire_is_halt_flag},
            {31'b0, wire_arithmetic_risk_flag},
            {31'b0, wire_load_flag},
            {31'b0, wire_no_load_pc_flag},
            wire_if_instruction,
            wire_if_pc4,
            {31'b0, wire_flag_start_program}
        }

        // wb_wire_mem_data_to_wb
        // {
            //  wire_mem_alu_result
            // mem_data_to_wb
            
        //     }
        )
 );
/*
    LOS CABLES i_clock e i_reset son para TODOS LOS M�DULOS
*/

/*
******WIRES DECLARED FOR IF INSTACE*****
*/
wire [PC_SIZE-1:0] wire_if_pc4;                                         //Cable que sale del m�dulo IF del siguiente PC.
wire  wire_no_load_pc_flag;                              //Cable que ingresa al m�dulo PC, flag de que no hay que cargar el PC.
wire [PC_SIZE-1:0] wire_id_pc_next;                                     //Cable que ingresa desde el m�dulo ID con el pr�ximo PC.
wire [3:0] wire_if_main_state_program_memory;           //todo: borrar
wire wire_if_new_inst_ready_prueba;                     //todo: borrar
wire wire_is_halt_flag;

/*
******IF INSTACE*****
*/
IF if_instance(
    .i_clk(i_clock),
    .i_reset(i_reset),
    .i_flag_start_program(wire_flag_start_program),
    .i_flag_new_inst_ready(wire_flag_instruction_write),
    .i_instruction_data(wire_debuguer_instruction_data),
    .i_no_load(wire_no_load_pc_flag),
    .i_is_halt(wire_is_halt_flag ),                                                     //Este cable viene de la unidad de control. Avisa que llego la ultima instruccion y termina el programa
    .i_next_pc(wire_id_pc_next), //TODO: conectar
    .i_enable(wire_debuguer_latch_enable_pc),
    .o_instruction_data(wire_if_instruction),
    .o_next_pc(wire_if_pc4), //TODO: cambiar pc_next a pc4
    .o_wire_state_program_memory(wire_if_main_state_program_memory),
    .o_wire_new_inst_program_memory(wire_if_new_inst_ready_prueba)
);

/*
******WIRES DECLARED FOR IFID INSTACE*****
*/
wire [PC_SIZE-1:0] wire_id_pc4;                                         //Cable sale del latch IF/ID con el siguiente PC.
wire [REG_SIZE-1:0] wire_id_instruction;                                               //Cable que sale del latch IF/ID con la instrucci�n a ingresar en la etapa ID.
wire id_flag_first_ex_instruction;
wire wire_id_ex_debuguer_latch_enable_pc;

/*
******IFID INSTACE*****
*/
 IFID ifid_instance (
    .i_clock(i_clock),
    .i_reset(i_reset),
    .i_enable(wire_debuguer_latch_enable_pc),
    
    .i_instruction_data(wire_if_instruction),
    .i_flag_start_program(wire_flag_start_program),
    .i_next_pc(wire_if_pc4),
    .o_instruction_data(wire_id_instruction),
    .o_next_pc(wire_id_pc4), //!todo: CAMBIAR A PC4
    .o_flag_start_program(id_flag_first_ex_instruction),
    .o_enable(wire_id_ex_debuguer_latch_enable_pc)

);

/*
******WIRES DECLARED FOR CONTROL MAIN INSTANCE*****
*/
wire wire_ctrl_ex_alu_src_a;                                            //Cable que controla el operando A en ALU.
wire wire_ctrl_mem_write_read_flag;                                     //Cable que controla si se escribe o se lee en la memoria de Datos.
wire wire_ctrl_mem_store_mask;                                          //Cable que controla la mascara en la memoria de Datos. (DUDA)
wire wire_ctrl_wb_mem_to_reg_sel;                                       //Cable que controla si se escribir� desde la memeoria de Datos hacia la memoria de Registros.
wire wire_ctrl_wb_write_back_flag;                                      //Cable que controla si hay un Write Back.
wire wire_id_is_A_B_equal_flag;                                         //Cable que controla si A es igual a B en la etapa ID para los Branch.

wire [1:0] wire_ctrl_next_pc_select;                                    //Cable que controla la selecci�n del pr�ximo PC.
wire [1:0] wire_ctrl_ex_alu_src_b;                                      //Cable que controla la selecci�n el operando B en la entrada de la ALU
wire [1:0] wire_ctrl_ex_reg_dest_sel;                                   //Cable que controla la selecci�n del registro INMEDIATO que pasa por la etapa EX.
wire [2:0] wire_ctrl_mem_load_mask;                                     //Cable que controla la mascara en la memoria de Datos. (DUDA)

/*
******CONTROL MAIN INSTANCE*****
*/
ControlMain control_main_instance( 
 
    .i_instruction(wire_id_instruction),
    .i_is_A_B_equal_flag(wire_id_is_A_B_equal_flag),
    .o_next_pc_select(wire_ctrl_next_pc_select),
    .o_ex_alu_src_a(wire_ctrl_ex_alu_src_a),
    .o_ex_alu_src_b(wire_ctrl_ex_alu_src_b),
    .o_ex_reg_dest_sel(wire_ctrl_ex_reg_dest_sel),
    .o_mem_write_read_flag(wire_ctrl_mem_write_read_flag),
    .o_mem_load_mask(wire_ctrl_mem_load_mask),
    .o_mem_store_mask(wire_ctrl_mem_store_mask),
    .o_wb_mem_to_reg_sel(wire_ctrl_wb_mem_to_reg_sel), //selector del dato write back
    .o_wb_write_back_flag(wire_ctrl_wb_write_back_flag)//flag writeback
);

/*
******WIRES DECLARED FOR ID INSTANCE*****
*/
wire [4:0] wire_id_rd;                                                      //Cable que sale de la etapa ID con el registro RD
wire [REG_SIZE-1:0] wire_id_shamt;                                          //Cable que sale de la etapa ID con el registro SHAMT 
wire [REG_SIZE-1:0] wire_id_indmediate;                                     //Cable que sale de la etapa ID con el registro IMMEDIATE 
wire [5:0] wire_id_function;                                                //Cable que sale de la etapa ID con el FUNCTION 
wire [5:0] wire_id_opcode;                                                  //Cable que sale de la etapa ID con el OPCODE
/*
******ID INSTANCE*****
*/
ID id_instace (
    .i_clock(i_clock),
    .i_reset(i_reset),
    .i_ctrl_next_pc_sel(wire_ctrl_next_pc_select),                          //Cable que controla la selecci�n del pr�ximo PC, viene de la CONTROL UNIT.
    .i_write_wb_flag(wb_wire_mem_ctrl_WB_wr_flag),
    .i_addr_wr(wb_addr_wb), 
    .i_data_wb(wb_wire_mem_data_to_wb),
    .i_instruction(wire_id_instruction),                                    //Cable que ingresa a la etapa ID con la instrucci�n, viene del latch IFID
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
wire wire_arithmetic_risk_flag;                                             //Cable que sale de la unidad de Riesgo, flag de riesgo aritm�tico.
wire wire_load_flag;                                                        //Cable que sale de la unidad de Riesgo, flag de riesgo de load.
wire [4:0] wire_ex_rs;                                                      //Cable que viene de la etapa EX con el registro RS       
wire [4:0] wire_ex_rt;                                                      //Cable que viene de la etapa EX con el registro RT                  
wire [4:0] wire_ex_rd;                                                      //Cable que viene de la etapa EX con el registro RD
wire [5:0] wire_ex_opcode;                                                  //Cable que viene de la etapa EX con el OPCODE 
wire wire_ex_enable_risk_unit;                                            //Cable que viene de la etapa EX con el enable de la unidad de riesgo.
/*
******RISK UNIT INSTANCE*****
*/
risk_unit risk_unit_instance(
    .i_clk(i_clock),
    .i_reset(i_reset),
    .i_enable(wire_ex_enable_risk_unit), // el cable sale desde EX ( representa la primera instruccion a ejecutar)- lo lee una vez.
    .i_rd_ex(wire_ex_rd),
    .i_rt_ex(wire_ex_rt),
    .i_op_ex(wire_ex_opcode),
    .i_instruction_id(wire_id_instruction),                                 //Cable que ingresa a la Risk Unit con la instrucci�n, viene del latch IFID.
    .o_is_halt_flag(wire_is_halt_flag),
    .o_arithmetic_risk_flag(wire_arithmetic_risk_flag),
    .o_load_flag(wire_load_flag), // !No ESTA IMPLEMENTADO!
    .o_no_load_pc_flag(wire_no_load_pc_flag)                                 //Cable que ingresa al m�dulo PC, flag de que no hay que cargar el PC. Declarado en la etapa IF.
);

wire [REG_SIZE-1:0] wire_ex_shamt, wire_ex_indmediate, wire_ex_dataA, wire_ex_dataB;
wire [PC_SIZE-1:0] wire_ex_pc4;
wire [1:0] wire_ex_ctrl_EX_regDEST_flag;
wire [1:0] wire_ex_ctrl_EX_ALU_source_B_flag;
wire  wire_ex_ctrl_EX_ALU_source_A_flag;
wire  wire_ex_ctrl_MEM_mem_write_or_read_flag;
wire [1:0] wire_ex_ctrl_MEM_store_mask;
wire [2:0] wire_ex_ctrl_MEM_load_mask;
wire   wire_ex_ctrl_WB_memToReg_flag, wire_ex_ctrl_WB_wr_flag;

IDEX idex_instance(
     .i_clock(i_clock),
     .i_reset(i_reset),
     .i_enable(wire_debuguer_latch_enable_pc),

    //* Signals from ID to EX
    .i_enable_risk_unit(wire_id_ex_debuguer_latch_enable_pc),
    .i_rs(wire_id_rs),
    .i_rt(wire_id_rt),
    .i_rd(wire_id_rd),
    .i_shamt_extend(wire_id_shamt),
    .i_imm_extend(wire_id_indmediate),
    .i_data_A(wire_id_dataA),
    .i_data_B(wire_id_dataB),
    .i_pc4(wire_id_pc4),
    .i_op(wire_id_opcode),
    .o_rs(wire_ex_rs),
    .o_rt(wire_ex_rt),
    .o_rd(wire_ex_rd),
    .o_shamt_extend(wire_ex_shamt),
    .o_imm_extend(wire_ex_indmediate),
    .o_data_A(wire_ex_dataA),
    .o_data_B(wire_ex_dataB), 
    .o_pc4(wire_ex_pc4),
    .o_op(wire_ex_opcode),
    .o_enable_risk_unit(wire_ex_enable_risk_unit), // habilita por primera vez el risk unit

    //* Signals from Unit Control
    //to EX
    .i_ctrl_EX_regDEST_flag(wire_ctrl_ex_reg_dest_sel),
    .i_ctrl_EX_ALU_source_B_flag(wire_ctrl_ex_alu_src_b),
    .i_ctrl_EX_ALU_source_A_flag(wire_ctrl_ex_alu_src_a),
    .o_ctrl_EX_regDEST_flag(wire_ex_ctrl_EX_regDEST_flag),
    .o_ctrl_EX_ALU_source_B_flag(wire_ex_ctrl_EX_ALU_source_B_flag),
    .o_ctrl_EX_ALU_source_A_flag(wire_ex_ctrl_EX_ALU_source_A_flag),

    //to MEM
    .i_ctrl_MEM_mem_write_or_read_flag(wire_ctrl_mem_write_read_flag),
    .i_ctrl_MEM_store_mask(wire_ctrl_mem_store_mask),
    .i_ctrl_MEM_load_mask(wire_ctrl_mem_load_mask),
    .o_ctrl_MEM_mem_write_or_read_flag(wire_ex_ctrl_MEM_mem_write_or_read_flag),
    .o_ctrl_MEM_store_mask(wire_ex_ctrl_MEM_store_mask),
    .o_ctrl_MEM_load_mask(wire_ex_ctrl_MEM_load_mask),

    //to WB
    .i_ctrl_WB_memToReg_flag(wire_ctrl_wb_mem_to_reg_sel),
    .i_ctrl_WB_wr_flag(wire_ctrl_wb_write_back_flag),
    .o_ctrl_WB_memToReg_flag(wire_ex_ctrl_WB_memToReg_flag),
    .o_ctrl_WB_wr_flag(wire_ex_ctrl_WB_wr_flag)
);





/***
SHORT_CIRCUIT_UNIT WIRES
***/
wire [1:0] cc_sel_short_circuit_A, cc_sel_short_circuit_B;

SHORT_CIRCUIT_UNIT short_circuit_instance(
    .i_ex_mem_reg_write_flag(wire_mem_ctrl_WB_wr_flag),
    .i_mem_wb_reg_write_flag(wb_wire_mem_ctrl_WB_wr_flag),
    .i_id_ex_rs(wire_ex_rs),
    .i_id_ex_rt(wire_ex_rt),
    .i_ex_mem_write_addr(wire_mem_addr_wb),
    .i_mem_wb_write_addr(wb_addr_wb),
    .o_sel_short_circuit_A(cc_sel_short_circuit_A),
    .o_sel_short_circuit_B(cc_sel_short_circuit_B)
);

 wire [REG_SIZE-1:0]  exmem_op_b;
 wire [REG_SIZE-1:0]  exmem_alu_result;
 wire [4:0] exmem_addr_wb;

 EX ex_instance(
    .i_cc_data_wb(wb_wire_mem_data_to_wb), //TODO conecatar cortocircuito con etapa WB
    .i_op_a(wire_ex_dataA),
    .i_op_b(wire_ex_dataB),
    .i_inmediate(wire_ex_indmediate),
    .i_shamat(wire_ex_shamt),
    .i_return_addr(wire_ex_pc4),
    .i_rt(wire_ex_rt),
    .i_rd(wire_ex_rd),
    .i_opcode(wire_ex_opcode),
    .i_ctrl_reg_dest(wire_ex_ctrl_EX_regDEST_flag),
    .i_sel_cc_b(cc_sel_short_circuit_B),
    .i_sel_cc_a(cc_sel_short_circuit_A),
    .i_ctrl_Alu_src_a(wire_ex_ctrl_EX_ALU_source_A_flag),
    .i_ctrl_Alu_src_b(wire_ex_ctrl_EX_ALU_source_B_flag),
    .o_op_b(exmem_op_b),
    .o_alu_result(exmem_alu_result),
    .o_addr_wb(exmem_addr_wb)
);


EXMEM EXMEM_instance(
    .i_clock(i_clock),
    .i_reset(i_reset),
    .i_enable(wire_debuguer_latch_enable_pc),

    .i_alu_result(exmem_alu_result),
    .i_data_B(exmem_op_b),
    .i_addr_wb(exmem_addr_wb), 
    .o_alu_result(wire_mem_alu_result),//TODO:
    .o_data_B(wire_mem_data_B),
    .o_addr_wb(wire_mem_addr_wb),//TODO:

    //* Signals from unit
    // to MEM
    .i_ctrl_MEM_mem_write_or_read_flag(wire_ex_ctrl_MEM_mem_write_or_read_flag),
    .i_ctrl_MEM_store_mask(wire_ex_ctrl_MEM_store_mask),
    .i_ctrl_MEM_load_mask(wire_ex_ctrl_MEM_load_mask),
    .o_ctrl_MEM_mem_write_or_read_flag(wire_mem_MEM_mem_write_or_read_flag),
    .o_ctrl_MEM_store_mask(wire_mem_MEM_store_mask),
    .o_ctrl_MEM_load_mask(wire_mem_MEM_load_mask),
    // to WB
    .i_ctrl_WB_memToReg_flag(wire_ex_ctrl_WB_memToReg_flag),
    .i_ctrl_WB_wr_flag(wire_ex_ctrl_WB_wr_flag),
    .o_ctrl_WB_memToReg_flag(wire_mem_ctrl_WB_memToReg_flag),//TODO:
    .o_ctrl_WB_wr_flag(wire_mem_ctrl_WB_wr_flag)//TODO:
);

wire [REG_SIZE-1:0] mem_data_to_wb;

MEM MEM_instance(
    .i_clock(i_clock),
    .i_reset(i_reset),
    .i_addr_mem(wire_mem_alu_result),
    .i_data_mem(wire_mem_data_B),
    .i_ctrl_mem_store_mask(wire_mem_MEM_store_mask),
    .i_ctrl_mem_load_mask(wire_mem_MEM_load_mask),
    .i_ctrl_mem_write_or_read_flag(wire_mem_MEM_mem_write_or_read_flag),
    .o_data_mem(mem_data_to_wb)//TODO:
);


MEMWB MEMWB_instance(
    .i_clock(i_clock),
    .i_reset(i_reset),
    .i_enable(wire_debuguer_latch_enable_pc),

    .i_addr_wb(wire_mem_addr_wb),//wb_wire_mem_ctrl_WB_memToReg_flag
    .i_data_mem(mem_data_to_wb),
    .i_ctrl_WB_memToReg_flag(wire_mem_ctrl_WB_memToReg_flag),
    .i_ctrl_WB_wr_flag(wire_mem_ctrl_WB_wr_flag),
    .i_alu_result(wire_mem_alu_result),

    .o_ctrl_WB_wr_flag(wb_wire_mem_ctrl_WB_wr_flag),
    .o_addr_wb(wb_addr_wb),
    .o_data_mem(wb_mem_data_to_wb),
    .o_ctrl_WB_memToReg_flag(wb_wire_mem_ctrl_WB_memToReg_flag),
    .o_alu_result(wb_wire_mem_alu_result)
);


WB WB_instance (
    .i_data_mem(wb_mem_data_to_wb),
    .i_ctrl_WB_memToReg_flag(wb_wire_mem_ctrl_WB_memToReg_flag),
    .i_alu_result(wb_wire_mem_alu_result),
    .o_data_to_wb(wb_wire_mem_data_to_wb)
);



/********************
*    ASSINGMENTS    *
********************/



assign o_tx = wire_uart_main_tx;
assign o_wire_state_leds_pins = wire_state_leds;
//assign o_wire_flag_rx_done = wire_flag_rx_done; //todo borrar
// assign o_wire_instruction_buffer_MSB_leds_pin = wire_if_instruction[31:23];

// assign o_wire_flag_instruction_write = wire_flag_instruction_write; //todo: borrar
assign o_wire_state_program_memory_pins = wire_if_main_state_program_memory;
assign o_wire_if_new_inst_ready = wire_if_new_inst_ready_prueba;
endmodule
