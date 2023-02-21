`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.02.2023 19:02:14
// Design Name: 
// Module Name: tb_if_id
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


module tb_if_id
#(
    parameter PC_SIZE = 32,
    parameter INSTR_SIZE = 32, 
    parameter REG_SIZE = 32
)(

);


//inputs registers
reg i_clock,
     i_reset,
     wire_flag_start_program_prueba,
     wire_flag_instruction_write_prueba;
     
reg [REG_SIZE-1:0] wire_debuguer_instruction_data_prueba;

//clock
always #1000 i_clock = ~i_clock;


Main main_instance (
    .i_clock(i_clock),
    .i_reset(i_reset),
    .wire_flag_start_program_prueba(wire_flag_start_program_prueba),
    .wire_flag_instruction_write_prueba(wire_flag_instruction_write_prueba),
    .wire_debuguer_instruction_data_prueba(wire_debuguer_instruction_data_prueba)
);

initial
begin

//reset
//i_clock=0;
//i_reset=1;
//wire_flag_start_program_prueba=0;
//wire_flag_instruction_write_prueba=0;
//wire_debuguer_instruction_data_prueba=0;
//#2000 
// i_reset = 0;
//#1000
//wire_flag_instruction_write_prueba=1;
//#1000
//wire_flag_instruction_write_prueba=0;
//wire_debuguer_instruction_data_prueba = 32'b111111100101010010;
//#1000
//wire_flag_instruction_write_prueba=1;
//#1000
//wire_flag_instruction_write_prueba=0;
//wire_debuguer_instruction_data_prueba = 32'b0;
//#1000
//wire_flag_start_program_prueba = 1;
//#1000
//wire_flag_start_program_prueba = 0;


    //ARRANCA TODO
    i_clock = 0;
    #1000
    i_reset = 1; 
    #1000
    i_reset = 0;
    
    
    //    //MANDO TRES INSTRUCCIONES Y EL HALT
    wire_flag_instruction_write_prueba=1;
    #1000
    wire_flag_instruction_write_prueba=0;
    //#2000
    wire_debuguer_instruction_data_prueba=32'b00000001000000010000000100000001;
    #2000
    wire_flag_instruction_write_prueba=1;
    #1000
    wire_flag_instruction_write_prueba=0;
   // #2000
    wire_debuguer_instruction_data_prueba=32'b00001111;
    
    #2000
    wire_flag_instruction_write_prueba=1;
    #1000
    wire_flag_instruction_write_prueba=0;
   // #2000
    wire_debuguer_instruction_data_prueba=32'b10101010;
    
    #2000
    wire_flag_instruction_write_prueba=1;
    #1000
    wire_flag_instruction_write_prueba=0;
    wire_debuguer_instruction_data_prueba=32'b00000000;
    
//        //ARRANCO EL PROGRAMA
    #2000
    wire_flag_start_program_prueba=1;
   #1000
    wire_flag_start_program_prueba=0;

end

endmodule
