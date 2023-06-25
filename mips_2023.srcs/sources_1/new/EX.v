`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: julieta prieto
// 
// Create Date: 19.06.2023 19:07:56
// Design Name: 
// Module Name: EX
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


module EX 
   #( 
   parameter SIZE_REG= 32,
   parameter SIZE_CTRL_CC_OP= 2, // tamaño del selector en bits para las entradas seg�n cortocircuito (mux)
   parameter SIZE_CTRL_ALU_SRC_B = 2, // tamaño del selector en bits para las entradas candidatas para B (mux)
   parameter SIZE_CTRL_ALU_SRC_A = 1, // tamaño del selector en bits para las entradas candidatas para A (mux)
   parameter SIZE_CTRL_REG_DEST = 2 // tamaño del selector en bits para las entradas candidatas para A (mux)

    )(
        input wire [(SIZE_REG-1):0] i_cc_data_wb, // data writeback corto circuitada desde la etapa WB.
        input wire [(SIZE_REG-1):0] i_op_a,
        input wire [(SIZE_REG-1):0] i_op_b,
        input wire [(SIZE_REG-1):0] i_inmediate,
        input wire [(SIZE_REG-1):0] i_shamat,
        input wire [(SIZE_REG-1):0] i_return_addr,
        input wire [4:0] i_rt,
        input wire [4:0] i_rd,
        input wire [5:0] i_opcode,
        input wire [(SIZE_CTRL_REG_DEST-1):0] i_ctrl_reg_dest,
        input wire [(SIZE_CTRL_CC_OP-1):0] i_sel_cc_b, //selector de corto circuito b
        input wire [(SIZE_CTRL_CC_OP-1):0] i_sel_cc_a, //selector de corto circuito a
        input wire [(SIZE_CTRL_ALU_SRC_A-1):0] i_ctrl_Alu_src_a, //selector de input A, a la ALU.
        input wire [(SIZE_CTRL_ALU_SRC_B-1):0] i_ctrl_Alu_src_b, //selector de input B, a la ALU.
        
        output wire [(SIZE_REG-1):0] o_op_b,
        output wire [(SIZE_REG-1):0] o_alu_result,
        output wire [4:0] o_addr_wb

    );
    /********* WIRES **********/
    (* dont_touch = "yes" *) wire [3:0]  wire_ctrl_alu; //TODO: salida de "Control ALU", entrada al selector de la ALU.
    (* dont_touch = "yes" *) reg [(SIZE_REG-1):0] reg_alu_result; //TODO: chequear si esto va como wire o reg
    (* dont_touch = "yes" *) wire [(SIZE_REG-1):0] wire_alu_result; //TODO: chequear si esto va como wire o reg

    /********* REGISTERS **********/
    (* dont_touch = "yes" *) reg [4:0] reg_addr_wb;
    (* dont_touch = "yes" *) reg [(SIZE_REG-1):0] out_mux_cc_src_b; // salida del MUX referido al cortocicuito en B
    (* dont_touch = "yes" *) reg [(SIZE_REG-1):0] out_mux_cc_src_a; // salida del MUX referido al cortocicuito en A
    (* dont_touch = "yes" *) reg [(SIZE_REG-1):0] out_mux_alu_src_b; // salida del MUX referido al input B de la ALU
    (* dont_touch = "yes" *) reg [(SIZE_REG-1):0] out_mux_alu_src_a; // salida del MUX referido al input A de la ALU

    /********* LOCAL PARAMETERS **********/
    localparam SELECT_REG_DEST_RD = 2'b01;
    localparam SELECT_REG_DEST_RT = 2'b00;
    localparam SELECT_REG_DEST_31 = 2'b10;

    localparam SELECT_B_CC_OP_B = 2'b00;
    localparam SELECT_B_CC_ALU_RESULT = 2'b01;
    localparam SELECT_B_CC_DATA_WB = 2'b10;

    localparam SELECT_A_CC_OP_A = 2'b00;
    localparam SELECT_A_CC_ALU_RESULT = 2'b01;
    localparam SELECT_A_CC_DATA_WB = 2'b10;

    localparam SELECT_ALU_SRC_A_OP_A = 1'b0;
    localparam SELECT_ALU_SRC_A_SHAMAT = 1'b1;

    localparam SELECT_ALU_SRC_B_OP_B = 2'b00;
    localparam SELECT_ALU_SRC_B_INMEDIATE = 2'b01;
    localparam SELECT_ALU_SRC_B_RETURN_ADDR = 2'b10;


/***********************
 * COMBINATIONAL LOGIC *
 ***********************/

reg [5:0] opcode, funct;
always @(*) begin
    opcode = i_opcode;
    funct = i_inmediate[5:0];
end

    /********* CONTROL ALU **********/
    CTRL_ALU ctrl_alu_instance(
        .i_alu_opcode(opcode),
        .i_funct(funct),
        .o_alu_ctrl(wire_ctrl_alu)
    );

    /********* ALU **********/
    ALU alu_instance(
        .i_op_a(out_mux_alu_src_a),
        .i_op_b(out_mux_alu_src_b),
        .i_ctrl_alu(wire_ctrl_alu),
        .o_result(wire_alu_result)
    );

     always @(*)
     begin

        reg_alu_result = wire_alu_result;
    /********* MUX SELECTOR ADDRESS WRITE-BACK **********/
        case(i_ctrl_reg_dest)
            SELECT_REG_DEST_RD: reg_addr_wb = i_rd;
            SELECT_REG_DEST_RT: reg_addr_wb = i_rt;
            SELECT_REG_DEST_31: reg_addr_wb = 5'b11111;
            default: reg_addr_wb = i_rt;
        endcase

    /********* MUX SELECTOR SHORT CIRCUIT B **********/
        case(i_sel_cc_b)
        SELECT_B_CC_OP_B: out_mux_cc_src_b = i_op_b;
        SELECT_B_CC_ALU_RESULT: out_mux_cc_src_b = reg_alu_result; //corto circuito en B
        SELECT_B_CC_DATA_WB: out_mux_cc_src_b = i_cc_data_wb;
        default: out_mux_cc_src_b = i_op_b;

        endcase

    /********* MUX SELECTOR SHORT CIRCUIT A **********/
        case(i_sel_cc_a)
        SELECT_A_CC_OP_A: out_mux_cc_src_a = i_op_a;
        SELECT_A_CC_ALU_RESULT: out_mux_cc_src_a = reg_alu_result; //corto circuito en A
        SELECT_A_CC_DATA_WB: out_mux_cc_src_a = i_cc_data_wb;
        default: out_mux_cc_src_a = i_op_a;

        endcase

    /********* MUX SELECTOR ALU SRC A **********/
        case(i_ctrl_Alu_src_a)
        SELECT_ALU_SRC_A_OP_A: out_mux_alu_src_a = out_mux_cc_src_a;
        SELECT_ALU_SRC_A_SHAMAT: out_mux_alu_src_a = i_shamat;
        default: out_mux_alu_src_a = out_mux_cc_src_a;
        endcase

    /********* MUX SELECTOR ALU SRC B **********/
        case(i_ctrl_Alu_src_b)
        SELECT_ALU_SRC_B_OP_B: out_mux_alu_src_b = out_mux_cc_src_b;
        SELECT_ALU_SRC_B_INMEDIATE: out_mux_alu_src_b = i_inmediate;
        SELECT_ALU_SRC_B_RETURN_ADDR: out_mux_alu_src_b = i_return_addr;
        default: out_mux_alu_src_b = out_mux_cc_src_b;
        endcase
    end

/********************
 * ASSIGN OUTPUTS   *
 ********************/
    assign o_op_b = i_op_b;
    assign o_alu_result = wire_alu_result;
    assign o_addr_wb = reg_addr_wb;

endmodule
