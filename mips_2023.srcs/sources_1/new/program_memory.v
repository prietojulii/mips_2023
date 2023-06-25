`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.02.2023 15:41:10
// Design Name: Mateo Merino y Julieta Prieto 
// Module Name: program_memory
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


module PROGRAM_MEMORY
    #(
       parameter SIZE_REG = 32,
       parameter SIZE_MEMORY= 320,                           //320 bits correspondientes a 10 instrucciones de 32 bits.
       parameter SIZE_COMMAND=8
    )
    (
        input wire i_clk,                                   //CLOCK
        input wire  i_reset,                                //RESET
        input wire [(SIZE_REG-1):0] i_pc,                                    //PC
        input wire[(SIZE_REG-1):0] i_instruction_data,      //La input que trae la instruccion, es decir la que viene del debuger
        
        input wire i_flag_new_inst_ready,                   //Flag de que hay una instruccion nueva para leer, viene del debuger
        input wire i_flag_start_program, 
        output wire [(SIZE_REG-1):0] o_instruction_data,     //El output con la instruccion que corresponda
        output wire [3:0] o_state_prueba, //todo: borrar
        output wire o_flag_new_inst_ready_prueba
    );


    //States
    localparam ST_IDLE  = 4'b0001; 
    localparam ST_RECEIVE_INSTRUCTION  = 4'b0010; 
    localparam ST_READY_TO_EXECUTE  = 4'b0011; 
    localparam ST_SEND_INSTRUCTION  = 4'b0100; 
    localparam ST_PROGRAM_FINISHED  = 4'b0110; 

    //Parameters
    //parameter first_instruction=0;
    localparam HALT = 32'b00000000000000000000000000000000;
    localparam INSTRUCTIONS_TOTAL=10; //La cantidad total de instrucciones: SIZE_MEMORY/SIZE_REG


    //Registers
    reg [3:0] state, state_next;

//    reg flag_start_program,flag_start_program_next;
    reg [(SIZE_REG-1):0] instruction_data_output,instruction_data_output_next;
    //reg [(SIZE_COMMAND-1):0] instruction_data_output,instruction_data_output_next;
    //reg [(SIZE_MEMORY-1):0] instruction_buffer, instruction_buffer_next;
    reg flag_new_inst_ready, flag_new_inst_ready_next;
    reg [(SIZE_MEMORY-1):0] instruction_buffer, instruction_buffer_next;
    reg [5:0] total_instructions, total_instructions_next;
    //reg [8:0]instruction_LSB,instruction_MSB;
    

    always @ (posedge i_clk) begin
    if(i_reset)begin
        state <= ST_IDLE;
        flag_new_inst_ready <=0; 
//        flag_start_program<=0;
        instruction_data_output<=0;
        instruction_buffer<=0;
        total_instructions<=INSTRUCTIONS_TOTAL;
    end
    else begin
        state <= state_next;
        instruction_data_output <= instruction_data_output_next;
        instruction_buffer <= instruction_buffer_next;
//        flag_start_program<=flag_start_program_next;
        total_instructions<=total_instructions_next;
        flag_new_inst_ready <= flag_new_inst_ready_next;
      end
end

always @ (*) begin
    state_next = state;
    instruction_data_output_next = instruction_data_output;
//    flag_start_program_next = flag_start_program;
    instruction_buffer_next = instruction_buffer;
    flag_new_inst_ready_next =flag_new_inst_ready;
    total_instructions_next = total_instructions;

    case(state)
        ST_IDLE: begin
            if(i_flag_new_inst_ready)
            begin
                    flag_new_inst_ready_next = 0;
                    state_next = ST_RECEIVE_INSTRUCTION;    //Si me llega un flag de que una instrucción está lista, inmediatamente paso al siguiente estado
            end
        end

    ST_RECEIVE_INSTRUCTION: begin
            if(i_instruction_data==HALT) begin     //Si la instruccion que vino es halt
                //ALMACENAR INSTRUCCIÓN HALT
//                instruction_buffer_next={i_instruction_data,instruction_buffer[(SIZE_REG-1):SIZE_COMMAND]};
                instruction_buffer_next={i_instruction_data,instruction_buffer[(SIZE_MEMORY-1):SIZE_REG]}; //pecho las instrucciones desde el mas signficativo hacia la derecha
                instruction_buffer_next=instruction_buffer_next>>(SIZE_REG*(total_instructions-1));         //shift para que la primera instruccion quede en la posicion 0

               state_next = ST_READY_TO_EXECUTE;    //Si ya llegó la instruccion halt, ya estamos listos para empezar a ejecutar
            end 
            else begin
                //ALMACENAR INSTRUCCCION
               // instruction_buffer_next={i_instruction_data,instruction_buffer[(SIZE_REG-1):SIZE_COMMAND]};
                instruction_buffer_next={i_instruction_data,instruction_buffer[(SIZE_MEMORY-1):SIZE_REG]};
                total_instructions_next=total_instructions-1;
                state_next = ST_IDLE;    //Cargo la instrucción y vuelvo al estado IDLE 
            end
        end
    
    ST_READY_TO_EXECUTE: begin
        if(i_flag_start_program)begin
            //SACO LA INSTRUCCION CORRESPONDIENTE
            state_next = ST_SEND_INSTRUCTION;
        end
    end
    
    ST_SEND_INSTRUCTION:begin
           instruction_data_output_next=instruction_buffer[(i_pc)+:SIZE_REG];
    end

    endcase

end

/************************************************************************************
                              PROGRAM MEMORY OUTPUTS
*************************************************************************************/

assign o_instruction_data = instruction_data_output;
assign o_state_prueba = state;
assign o_flag_new_inst_ready_prueba = flag_new_inst_ready;
endmodule
