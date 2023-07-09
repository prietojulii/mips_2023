`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mateo Merino
// 
// Create Date: 08.03.2023 08:52:28
// Design Name: 
// Module Name: risk_unit
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


module risk_unit#(
    parameter SIZE_REG = 32,
    parameter SIZE_MEMORY= 320,                           //320 bits correspondientes a 10 instrucciones de 32 bits.
    parameter SIZE_COMMAND=8

    )(
    input wire i_clk,                                   //CLOCK
    input wire  i_reset,                                //RESET
    input wire[(SIZE_REG-1):0] i_instruction_id,        //Instruction from the ID stage     
    input wire [5:0] i_op_ex,                           //OP input from the EX stage
    input wire [4:0] i_rt_ex,                           //RT input from the EX stage
    input wire [4:0] i_rd_ex,                           //RD input from the EX stage

    output wire o_is_halt_flag,                         //Halt Flag to IF Module
    output wire o_load_flag,                            //Load Flag to Short Circuit Unit
    output wire o_no_load_pc_flag,                      //No Load PC to IF Module
    output wire o_arithmetic_risk_flag                  //Aritchmetic Flag to Short Circuit Unit
    );
    
    //States
    localparam ST_READ_INSTRUCTION  = 4'b0000;
    localparam ST_RISK_DETECTED  = 4'b0011; 
    localparam ST_PROGRAM_FINISHED  = 4'b0100; 
    
   //Macros
    localparam LB=6'b100000;
    localparam LH=6'b100001;
    localparam LW=6'b100011;
    localparam LWU=6'b100111;
    localparam LBU=6'b100100;
    localparam LHU=6'b100101;
    localparam LUI=6'b001111;
    localparam BEQ=6'b000100;
    localparam BNE=6'b000101;
    localparam SPECIAL=6'b000000;
    localparam ADDI=6'b001000;
    localparam ANDI=6'b001100;
    localparam ORI=6'b001101;
    localparam XORI=6'b001110;
    localparam SLTI=6'b001010;
    localparam HALT=32'b0;

    //Registers
    reg is_halt_flag;
    reg [3:0] state, state_next;
    reg [4:0] rs_ex, rd_ex, rt_ex;
    reg [5:0] op_ex;
    reg [4:0] rs_id, rd_id, rt_id;
//    reg [5:0] op_id;
    reg bne_flag, beq_flag, load_flag, no_load_pc_flag, arithmetic_risk_flag;

     // ***************** Architecture DLX ***********************************************************

    always @(*) rs_id     = i_instruction_id[25:21]; //source register
    always @(*) rt_id     = i_instruction_id[20:16]; //source2 register
    always @(*) rd_id     = i_instruction_id[15:11]; //destination register
//    always @(*) op_id     = i_instruction_id[31:26];  //select the arithmetic operation
    

    always @ (posedge i_clk) begin
    if(i_reset)begin
        state <= ST_READ_INSTRUCTION;
//        op_id <= 0;
    end
    else begin
        state <= state_next;
      end
end

always @ (*) begin
    state_next = state; 
    no_load_pc_flag = 0;
    load_flag = 0;
    arithmetic_risk_flag = 0; 
    is_halt_flag = 0;
   
    case(state)
        ST_READ_INSTRUCTION: begin
            if(i_instruction_id==HALT)begin
                state_next = ST_PROGRAM_FINISHED;
            end
            else if(i_op_ex==LB || i_op_ex==LH || i_op_ex==LW || i_op_ex==LBU || i_op_ex==LHU || i_op_ex==LWU || i_op_ex==LUI)begin //LOADS
                    if(i_rt_ex==rs_id || i_rt_ex==rd_id)begin
                        load_flag=1;
                        no_load_pc_flag=1;
                        state_next = ST_RISK_DETECTED;
                    end
            end
            else if(i_op_ex==SPECIAL)begin //ARITMETICAS
                    if((i_rd_ex==rs_id || i_rd_ex==rt_id ) && (i_rd_ex != 0) )begin
                        arithmetic_risk_flag=1;
                        state_next = ST_RISK_DETECTED;
                    end
            end
            else if(i_op_ex==ADDI || i_op_ex==ANDI|| i_op_ex==ORI|| i_op_ex==XORI|| i_op_ex==SLTI)begin //RIESGO ARITMETICA INMEDIATA
                    if(i_rt_ex==rs_id || i_rt_ex== rd_id)begin
                        arithmetic_risk_flag=1;
                        state_next = ST_RISK_DETECTED;
                    end
            end
        end
        ST_RISK_DETECTED: begin
            no_load_pc_flag=0;
            arithmetic_risk_flag=0;
            load_flag=0;
            state_next = ST_READ_INSTRUCTION;
        end
        ST_PROGRAM_FINISHED: begin
            is_halt_flag = 1;
            state_next = ST_PROGRAM_FINISHED;
        end

    endcase

end

/************************************************************************************
                              RISK UNIT OUTPUTS
*************************************************************************************/

assign o_no_load_pc_flag = no_load_pc_flag;
assign o_arithmetic_risk_flag = arithmetic_risk_flag;
assign o_load_flag = load_flag;
assign o_is_halt_flag = is_halt_flag;

endmodule
