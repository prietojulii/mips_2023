`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UNC-Universidad Nacional de Cordoba
// Engineer: Julieta Prieto
// 
// Create Date: 04.12.2022 16:21:54
// Design Name: 
// Module Name: REG_MEMORY
// Project Name: MIPS
// Target Devices: 
// Tool Versions: 
// Description: REGISTERS MEMORY:
// - 32 (GPR) single precision general purpose registers ( 32 bits per register)
// - R0 always is 0
// - register addressable in memory BIG ENDIAN mode
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// *Additional Comments:
// Esta Memoria direcciona por registro ( por posición) si la direccion es 1,
// te busca el ELEMENTO (REGISTRO) numero 1.
/////////////////////////////////////////////////////////////////////////////


module DATA_MEM
#(
   parameter ADDR_SIZE = 5, //instruction memory address size 
   parameter DATA_SIZE = 32, //data size in bits (INSTRUCTION_SIZE)
   parameter BUFFER_SIZE = 4, //number of register
   parameter DATA_MEM_TO_USER_SIZE = 128 //data size * Buffer size . Numero de bits para debuguear
)
(
  input wire i_clock,
  input wire i_reset,
  input wire i_ctrl_mem_rd_or_wr, // 1 for write, 0 for read
  input wire [DATA_SIZE-1:0]  i_data_mem,  //A Reg address of the memory
  input wire [DATA_SIZE-1:0]  i_addr_mem,  //B reg address of the memory

  output wire [DATA_SIZE-1:0] o_data_mem, // A register to be read
  output wire [DATA_MEM_TO_USER_SIZE-1:0] o_data_mem_to_user //!  Cable para enviar al usuario para debuguear y ver la memoria
);

localparam WRITE = 1;
localparam READ = 0;

(* dont_touch = "yes" *) reg [DATA_SIZE-1:0] buffer [BUFFER_SIZE-1:0]; //buffer of the memory 
reg [DATA_SIZE-1:0] dataMEM;

always@(negedge i_clock) begin // first write
   if (i_reset) begin
      dataMEM = 0;
    end
    else  if (i_ctrl_mem_rd_or_wr == WRITE) begin 
       buffer[i_addr_mem] =  i_data_mem;  
    end
    else if (i_ctrl_mem_rd_or_wr == READ) begin
        dataMEM = buffer[i_addr_mem]; 
    end
end

// Assing data
assign o_data_mem = dataMEM; 
assign o_data_mem_to_user = {buffer[0], buffer[1], buffer[2], buffer[3]}; // Solo para debuguear, ilustra los primeros registros de la memoria

endmodule
