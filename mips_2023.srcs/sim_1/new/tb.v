`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.11.2022 22:19:57
// Design Name: 
// Module Name: load_mode_sim
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


module SIM_LOAD_MODE(

    );
      
    wire [7:0] i_command;
    reg [7:0] command; //rx data
    wire  flag_halt;    
    wire  flag_instruction_wr;  
    wire i_flag_tx_done;
    wire o_tx;
    wire o_flag_instruction_wr;
    wire i_tick, i_flag_rx_done,o_flag_inst_wr;
    reg  i_clock,
        i_reset,
        i_tx_start;
    wire [31:0] o_instruction_data;
////////////////////////////////
//SIMULACION DEL pc ENVIO DE DATOS
UART_ticks mytiks (
    .i_clk(i_clock),
    .i_reset(i_reset),
    .o_tick(i_tick)
);

 UART_tx user_pc(
    .i_clk(i_clock),
    .i_reset(i_reset),
    .i_tx_start(i_tx_start), //
    .i_tick(i_tick),

    .i_buff_trama(command),
    .o_flag_tx_done(i_flag_tx_done),
    .o_tx(o_tx)//
    );
    
    
    //control de a b y op
always @(posedge i_flag_rx_done)   //se ya se recibio un byte
begin
    if(command == 1)begin //si se envio L
        command = 0; 
           i_tx_start=1;        
        end      

     
     
end   

//MODULOS DEL MIPS
UART uart(
    .i_clk(i_clock),
    .i_reset(i_reset),
    .i_rx(o_tx),
//    .i_tx
//    .i_tx_start
   .o_rx(i_command),
    .o_rx_done_tick(i_flag_rx_done)
    // .o_tx
    // .o_tx_done_tick  
);
Debuguer debuguer(
    .i_clk(i_clock),
    .i_reset(i_reset),
    .i_command(i_command),
    .i_flag_rx_done(i_flag_rx_done),
    .o_flag_instruction_write(o_flag_inst_wr),
    .o_instruction_data(o_instruction_data)
);


//CLOCK
always #1000 i_clock = ~i_clock;



initial
begin
    //INIT RESET***************************
    i_clock = 0;
//    contador = 0;
    i_reset = 1; 
    command = 0;
    i_tx_start=0;
//    flag_halt = 0;
   // flag_instruction_wr = 0;

    #2000 
    i_reset = 0;
    #1000
    //**************************************
    //enviar comando L
    command = 1;    
    i_tx_start=1;
    //command = 0;
    #1000
    i_tx_start=0;
     

   

    
end 
endmodule
