`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mateo Merino
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
    input wire [SIZE_PC-1:0] i_next_pc,  // El pc por si hay una burbuja y no hay que hacer PC+4.
    input wire i_is_halt, i_no_load,  // Flags de control; de instrucción Halt y de No Cargar PC respectivamente.
    input wire i_flag_start_program,  // Flag para comenzar a incrementar el PC.
    input wire i_enable,
    output wire [SIZE_PC-1:0] o_pc,o_next_pc
);

    // States
    localparam ST_IDLE  = 4'b0001; 
    localparam ST_INCREMENT_PC  = 4'b0010;
    localparam ST_PROGRAM_FINISHED = 4'b0011; 
    localparam ST_NO_LOAD_PC=4'b0111;
    
    // Registers
    reg [3:0] state, state_next; 
    reg [SIZE_PC-1:0] pc, pc_next;

    // Logic
    always @ (posedge i_clk) begin
        if(i_reset)begin
            state <= ST_IDLE;
        end
        else begin
            if(i_enable) begin
                state <= state_next;
            end
        end
    end

    always @ (*) begin
        state_next = state;
        case(state)
            ST_IDLE: begin
                pc = 0;
                if(i_flag_start_program) begin
                        state_next=ST_INCREMENT_PC;
                    end
            end
            ST_INCREMENT_PC:
                begin
                    if(i_is_halt) begin
                        state_next=ST_PROGRAM_FINISHED;
                    end
                    else begin
                        if(i_no_load) begin
                            state_next=ST_NO_LOAD_PC;
                        end
                        if(~i_no_load) begin
                            pc=i_next_pc<<3;  // Mapeo de i_next_pc de BYTE a BIT.
                        end
                    end
                end
                ST_NO_LOAD_PC:
                begin
                    state_next=ST_INCREMENT_PC;
                end
                ST_PROGRAM_FINISHED: 
                begin
                    // Me quedo aqui por siempre.
                end
        endcase
    end

/************************************************************************************
*                              PC OUTPUTS
*************************************************************************************/

    assign o_pc = pc;
    assign o_next_pc= pc +   {{(SIZE_PC-6){1'b0}},6'b100000}   ;//pc+4Bytes

endmodule
