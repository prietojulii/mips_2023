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


module pc(
    input wire i_clk,i_reset,
    input wire [7:0] i_next_pc,                 //El pc por si hay una burbuja y no hay que hacer PC+4
    input wire i_is_halt, i_no_load,            //Flags de control; de instrucción Halt y de No Cargar PC respectivamente
    input wire i_flag_start_program,                  //Flag para comenzar a incrementar el PC
    output wire [7:0] o_pc,o_next_pc
    
    );
    
     //States
    localparam ST_IDLE  = 4'b0001; 
    localparam ST_INCREMENT_PC  = 4'b0010;
    localparam ST_PROGRAM_FINISHED = 4'b0011; 
    
    //Registers
    reg [3:0] state, state_next; 
    reg [8:0] pc, pc_next; 
    
    
    
    always @ (posedge i_clk) begin
    if(i_reset)begin
        state <= ST_IDLE;
        state_next <= ST_IDLE; 
        pc <= 0;
        pc_next <= 0;
    end
    else begin
        state <= state_next;
        pc <= pc_next;
      end
end

    always @ (*) begin
        case(state)
            ST_IDLE: begin
                if(i_flag_start_program)
                    begin
                    state_next=ST_INCREMENT_PC;
                    end
            end
            ST_INCREMENT_PC:
             begin
                if(i_is_halt)
                    begin
                    state_next=ST_PROGRAM_FINISHED;
                    end
                else if(i_no_load) 
                    begin
                    pc_next=pc;
                    end
                else 
                    begin
                    pc_next=pc_next+4;
                    end
             end
             
             ST_PROGRAM_FINISHED: 
             begin
                
             end
                  
        endcase
    
    end
    
/************************************************************************************
                              PC OUTPUTS
*************************************************************************************/

assign o_pc = pc;
assign o_next_pc=pc+4;
endmodule
