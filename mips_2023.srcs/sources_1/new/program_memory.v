`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.02.2023 15:41:10
// Design Name: 
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
        input wire [7:0] i_pc,                                    //PC
        input wire[(SIZE_REG-1):0] i_instruction_data,      //La input que trae la instruccion, es decir la que viene del debuger
        
        //input wire[(SIZE_COMMAND-1):0] i_instruction_data,      //La input que trae la instruccion, es decir la que viene del debuger
        input wire i_flag_new_inst_ready,                   //Flag de que hay una instruccion nueva para leer, viene del debuger
        input wire i_flag_start_program, 
        output wire [(SIZE_REG-1):0] o_instruction_data     //El output con la instruccion que corresponda
        //output wire [(SIZE_COMMAND-1):0] o_instruction_data    //El output con la instruccion que corresponda
 
    );


    //States
    localparam ST_IDLE  = 4'b0001; 
    localparam ST_RECEIVE_INSTRUCTION  = 4'b0010; 
    localparam ST_READY_TO_EXECUTE  = 4'b0011; 
    localparam ST_SEND_INSTRUCTION  = 4'b0100; 
    localparam ST_PROGRAM_FINISHED  = 4'b0110; 
    
    localparam first_instruction=0;
    localparam second_instruction=8;
    localparam third_instruction=16;
    localparam fourth_instruction=24;
    
    
    //Parameters
    //parameter first_instruction=0;
    
    


    //Registers
    reg [3:0] state, state_next;
    reg pc, pc_next;
    reg [4:0] inst_counter,inst_counter_next;
    reg [4:0] inst_decrease,inst_decrease_next;
    reg [(SIZE_REG-1):0] instruction_data,instruction_data_next;
    reg flag_new_inst_ready,flag_new_inst_ready_next;
    reg flag_start_program,flag_start_program_next;
    reg [(SIZE_REG-1):0] instruction_data_output,instruction_data_output_next;
    //reg [(SIZE_COMMAND-1):0] instruction_data_output,instruction_data_output_next;
    //reg [(SIZE_MEMORY-1):0] instruction_buffer, instruction_buffer_next;
    reg [(SIZE_MEMORY-1):0] instruction_buffer, instruction_buffer_next;
    reg [5:0] total_instructions, total_instructions_next;
    //reg [8:0]instruction_LSB,instruction_MSB;
    

    always @ (posedge i_clk) begin
    if(i_reset)begin
        state <= ST_IDLE;
        state_next <=ST_IDLE;
        pc <= 0;
        pc_next <= 0;
        instruction_data<=0;
        instruction_data_next<=0;  
        flag_new_inst_ready<=0;
        flag_new_inst_ready_next<=0;
        flag_start_program<=0;
        flag_start_program_next<=0;
        instruction_data_output<=0;
        instruction_data_output_next<=0;
        instruction_buffer<=0;
        instruction_buffer_next<=0;
        inst_counter<=0;
        inst_counter_next<=0;
        inst_decrease<=0;
        inst_decrease_next<=0;
        total_instructions<=SIZE_MEMORY/SIZE_REG;
        total_instructions_next<=SIZE_MEMORY/SIZE_REG;
    end
    else begin
        state <= state_next;
        pc <= pc_next;
        instruction_data <= instruction_data_next;
        flag_new_inst_ready <= flag_new_inst_ready_next;
        instruction_data_output <= instruction_data_output_next;
        instruction_buffer <= instruction_buffer_next;
        inst_counter<=inst_counter_next;
        flag_start_program<=flag_start_program_next;
        inst_decrease<=inst_decrease_next;
        total_instructions<=total_instructions_next;
      end
end

always @ (*) begin
    state_next = state; 
    pc_next = pc;
    instruction_data_next = instruction_data;
    flag_new_inst_ready_next = flag_new_inst_ready;
    instruction_data_output_next = instruction_data_output;
    inst_counter_next = inst_counter;
    flag_start_program_next = flag_start_program;
    inst_decrease_next = inst_decrease;
    
    case(state)
        ST_IDLE: begin
            if(i_flag_new_inst_ready)
            begin
                    state_next = ST_RECEIVE_INSTRUCTION;    //Si me llega un flag de que una instrucción está lista, inmediatamente paso al siguiente estado
            end
        end

    ST_RECEIVE_INSTRUCTION: begin
            if(i_instruction_data==32'b0) begin     //Si la instruccion que vino es halt
                //ALMACENAR INSTRUCCIÓN HALT
//                instruction_buffer_next={i_instruction_data,instruction_buffer[(SIZE_REG-1):SIZE_COMMAND]};
                instruction_buffer_next={i_instruction_data,instruction_buffer[(SIZE_MEMORY-1):SIZE_REG]};
                instruction_buffer_next=instruction_buffer_next>>(SIZE_REG*(total_instructions-1));
                inst_counter_next = inst_counter+1;
                //inst_decrease_next = inst_decrease+1;
               state_next = ST_READY_TO_EXECUTE;    //Si ya llegó la instruccion halt, ya estamos listos para empezar a ejecutar
            end 
            else begin
                //ALMACENAR INSTRUCCCION
               // instruction_buffer_next={i_instruction_data,instruction_buffer[(SIZE_REG-1):SIZE_COMMAND]};
                instruction_buffer_next={i_instruction_data,instruction_buffer[(SIZE_MEMORY-1):SIZE_REG]};
               total_instructions_next=total_instructions-1;
                //inst_decrease_next = inst_decrease+1;
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
//         case(i_pc)
//            first_instruction:begin
//                instruction_data_output_next=instruction_buffer[(SIZE_COMMAND):first_instruction];
                
//                if(instruction_data_output_next==8'b0)begin
//                    state_next=ST_PROGRAM_FINISHED;
//                end
                
//            end
//              second_instruction:begin
//                instruction_data_output_next=instruction_buffer[((SIZE_COMMAND*2)-1):second_instruction];
//                if(instruction_data_output_next==8'b0)begin
//                    state_next=ST_PROGRAM_FINISHED;
//                end
//            end
//              third_instruction:begin
//                instruction_data_output_next=instruction_buffer[((SIZE_COMMAND*3)-1):third_instruction];
//                if(instruction_data_output_next==8'b0)begin
//                    state_next=ST_PROGRAM_FINISHED;
//                end
//            end
//            fourth_instruction:begin
//                instruction_data_output_next=instruction_buffer[((SIZE_COMMAND*4)-1):fourth_instruction];
//                if(instruction_data_output_next==8'b0)begin
//                    state_next=ST_PROGRAM_FINISHED;
//                end
//            end
                      
//         endcase     
    end

    endcase

end

/************************************************************************************
                              PROGRAM MEMORY OUTPUTS
*************************************************************************************/

assign o_instruction_data = instruction_data_output;

endmodule
