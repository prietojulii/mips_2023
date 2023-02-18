`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.02.2023 15:44:02
// Design Name: 
// Module Name: tb_program_memory
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


module tb_program_memory(

    );
    
    reg  i_clock, i_reset;
    reg [8:0] i_pc;
    
    reg [31:0] i_instruction_data;
    reg i_flag_new_inst_ready,i_flag_start_program;
    reg [7:0] o_pc;


program_memory my_memory(
    .i_clk(i_clock),
    .i_reset(i_reset),
    .i_pc(i_pc),
    .i_instruction_data(i_instruction_data),
    .i_flag_new_inst_ready(i_flag_new_inst_ready),
    .i_flag_start_program(i_flag_start_program)
);

pc my_pc(
    .i_clk(i_clock),
    .i_reset(i_reset),
    .i_flag_start_program(i_flag_start_program),
    o_pc
);


always #500 i_clock = ~i_clock;


initial begin
    //ARRANCA TODO
    i_clock = 0;
    #1000
    i_reset = 1; 
    #1000
    i_reset = 0;
    
/************************************************************************************
                              ESTE TEST BENCH FUNCIONA PARA EL MODULO PROGRAM
                              MEMORY. SE ENVIAN DOS INSTRUCCIONES, Y LUEGO EL 
                              HALT.
                              LUEGO, ARRANCA EL PROGRAMA Y SE INCREMENTA EL VALOR
                              DEL PC. 
                              A LA SALIDA DE LA MEMORIA DE INSTRUCCIONES SE VEN
                              LAS INSTRUCCIONES CORRESPONDIENTES. 
*************************************************************************************/
//    //MANDO TRES INSTRUCCIONES Y EL HALT
//    i_flag_new_inst_ready=1;
//    #1000
//    i_flag_new_inst_ready=0;
//    //#2000
//    i_instruction_data=8'b00000001;
//    #2000
//    i_flag_new_inst_ready=1;
//    #1000
//    i_flag_new_inst_ready=0;
//   // #2000
//    i_instruction_data=8'b00001111;
    
//    #2000
//    i_flag_new_inst_ready=1;
//    #1000
//    i_flag_new_inst_ready=0;
//    i_instruction_data=8'b00000000;
    
//        //ARRANCO EL PROGRAMA
//    #2000
//    i_flag_start_program=1;
//    #1000
//    i_flag_start_program=0;
    
//    i_pc=9'b000000000;
    
//   #2000
////    i_flag_start_program=1;
////    #1000
////    i_flag_start_program=0;
    
//    i_pc=9'b000001000;
//    #2000
//    i_pc=9'b000010000;

/************************************************************************************
                              FIN DEL TEST BENCH PARA EL PROGRAM MEMORY
*************************************************************************************/

  
    
    
    //    //MANDO TRES INSTRUCCIONES Y EL HALT
    i_flag_new_inst_ready=1;
    #1000
    i_flag_new_inst_ready=0;
    //#2000
    i_instruction_data=8'b00000001;
    #2000
    i_flag_new_inst_ready=1;
    #1000
    i_flag_new_inst_ready=0;
   // #2000
    i_instruction_data=8'b00001111;
    
    #2000
    i_flag_new_inst_ready=1;
    #1000
    i_flag_new_inst_ready=0;
    i_instruction_data=8'b00000000;
    
//        //ARRANCO EL PROGRAMA
    #2000
    i_flag_start_program=1;
   #1000
    i_flag_start_program=0;
    
//    i_pc=9'b000000000;
    
//   #2000
////    i_flag_start_program=1;
////    #1000
////    i_flag_start_program=0;
    
//    i_pc=9'b000001000;
//    #2000
//    i_pc=9'b000010000;
    
    
    
    
    
    
    

end
endmodule
