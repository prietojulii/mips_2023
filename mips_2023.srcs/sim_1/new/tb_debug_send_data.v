`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2023 18:13:44
// Design Name: 
// Module Name: tb_debug_send_data
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


module tb_debug_send_data#(
    parameter SIZE_MEM = 1024,
    parameter SIZE_REG = 32,
    parameter SIZE_COMMAND = 8,
    parameter SIZE_PC = 32,
    parameter SIZE_BUFFER_TO_USER = 170,             // PC + Rs + Rt + A + B + AddrMem + DataMem
    parameter SIZE_RS = 5,
    parameter SIZE_RT = 5,
    parameter SIZE_TRAMA = 8
    );
    reg  i_clock,
 i_reset,i_tx_start,i_flag_rx_done;
    reg [7:0] i_command;                       //Comando que viene desde la PC al Debuguer
    wire i_flag_tx_done;
    wire [(SIZE_PC-1):0] i_pc, i_rs, i_rt, i_a, i_b, i_addr_mem, i_data_mem; 
    
    wire [(SIZE_TRAMA-1):0] o_trama_tx;
    wire o_tx_start;
    wire o_enable_pc;
    
    localparam L=1;
    localparam C=2;
    localparam S=3;
    localparam N=4;
    localparam BYTES_PER_INSTRUCTION=4;
    localparam HALT = 32'b0;
    localparam TX_COUNTER= 21;
     
Debuguer my_debug(
    .i_clock(i_clock),
    .i_reset(i_reset),
    .i_tx_start(i_tx_start),
    .i_flag_rx_done(i_flag_rx_done),
    .i_command(i_command),
    .i_flag_tx_done(i_flag_tx_done),
    .i_pc(i_pc),
    .i_rs(i_rs),
    .i_rt(i_rt),
    .i_a(i_a),
    .i_b(i_b),
    .i_addr_mem(i_addr_mem),
    .i_data_mem(i_data_mem)
    );
    
    
    //CLOCK
always #1000 i_clock = ~i_clock;

initial
begin

    i_clock = 0;
    i_reset = 1;
    #2000
    i_reset = 0;
    
    i_flag_rx_done=1;
    i_command=L;
    #2000
    i_flag_rx_done=0;
    #2000
    i_flag_rx_done=1;
    i_command=L;




end

    
    
endmodule
