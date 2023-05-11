`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.02.2023 15:21:36
// Design Name: 
// Module Name: pc
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


module PC
     #(
     parameter SIZE_PC = 32)
     (
    input wire i_clk,i_reset,
    input wire [SIZE_PC-1:0] i_next_pc,                 //El pc por si hay una burbuja y no hay que hacer PC+4
    input wire i_is_halt, i_no_load,            //Flags de control; de instrucción Halt y de No Cargar PC respectivamente
    input wire i_flag_start_program,                  //Flag para comenzar a incrementar el PC
    input wire i_enable,
    output wire [SIZE_PC-1:0] o_pc,o_next_pc
    
    );
    
     //States
    localparam ST_IDLE  = 4'b0001; 
    localparam ST_INCREMENT_PC  = 4'b0010;
    localparam ST_PROGRAM_FINISHED = 4'b0011; 
    
    //Registers
    reg [3:0] state, state_next; 
    reg [SIZE_PC-1:0] pc, pc_next;
     
    
    
    
    always @ (posedge i_clk) begin
    if(i_reset)begin
        state <= ST_IDLE;
        pc <= 0;
    end
    else if(i_enable) begin
        state <= state_next;
        pc <= pc_next;
      end
    else begin
        state <= state;
        pc <= pc;
    end
end

always @ (*) begin
    pc_next = pc;
    state_next = state;
        case(state)
            ST_IDLE: begin
                if(i_flag_start_program)
                    begin
                    state_next=ST_INCREMENT_PC;
                    end
            end
            ST_INCREMENT_PC:
             begin
               //  if(i_is_halt) //todo: descomentar
               //     begin
               //    state_next=ST_PROGRAM_FINISHED;
               //    end
                if(i_no_load)  //todo: else if
                    begin
                    pc_next=pc;
                    end
                else 
                    begin
                    pc_next=i_next_pc<<3; // i_next_pc with byte-to-bit mapping 
                    end
             end
             
             ST_PROGRAM_FINISHED: 
             begin
                //stay here forever
             end
                  
        endcase
    
    end
    
/************************************************************************************
                              PC OUTPUTS
*************************************************************************************/

assign o_pc = pc;
assign o_next_pc= pc +   {{(SIZE_PC-6){1'b0}},6'b100000}   ;//pc+4Bytes
endmodule