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
// Additional Comments:
// ! por que dice que es direccionable por "byte" y es una memoria de 32 GPR. 
//! PERO como tengo 5 bits(rt) para direccionar ... solo puedo direccionar por "registro (32bit)"
//////////////////////////////////////////////////////////////////////////////////


module REG_MEMORY
#(
   parameter ADDR_SIZE = 5, //instruction memory address size 
   parameter DATA_SIZE = 32, //data size in bits (INSTRUCTION_SIZE)
   parameter BUFFER_SIZE = 1024 //buffer size in bits (memory size)
)
(
  input wire i_clock,
  input wire i_reset,
  input wire i_wr_flag, // 1 for write, 0 for read
  input wire [ADDR_SIZE-1:0]  i_addr_A,  //A Reg address of the memory
  input wire [ADDR_SIZE-1:0]  i_addr_B,  //B reg address of the memory
  input wire [ADDR_SIZE-1:0]  i_addr_wr, //address to be written in the memory
  input wire [DATA_SIZE-1:0]  i_data_in, // data to be written in A register
  output wire [DATA_SIZE-1:0] o_data_A, // A register to be read
  output wire [DATA_SIZE-1:0] o_data_B // B register to be read
);

reg [BUFFER_SIZE-1:0] buffer; //buffer of the memory 

always @(posedge i_clock) begin
    if (i_reset) begin //write 
         buffer[ DATA_SIZE-1 : 0] = {DATA_SIZE{1'b0}}; //R0 
  end
end
always @(*) begin   
    if (i_wr_flag & i_clock) begin //write in the first cicle-time
    begin
      if(i_addr_wr != 0) //R0, always is 0
        buffer[({27'b0,i_addr_wr}*DATA_SIZE) +: DATA_SIZE] = i_data_in; //dynamic index (ADDR POSITION) 
      else
         buffer[({27'b0,i_addr_wr}*DATA_SIZE) +: DATA_SIZE] = 0; //R0 always is 0
    end

  end
end


assign o_data_A = buffer[({27'b0,i_addr_A}*DATA_SIZE) +: DATA_SIZE]; //dynamic index (ADDR-A POSITION)
assign o_data_B = buffer[({27'b0,i_addr_B}*DATA_SIZE) +: DATA_SIZE]; //dynamic index (ADDR-B POSITION)
endmodule