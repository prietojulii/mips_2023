`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UNC-Universidad Nacional de Cordoba
// Engineer: Julieta Prieto y Mateo Merino
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
// Memoria direccionable por Numero de registro. Es decir si la dirección de A es 0,
// este, mostrara el primer registro de 32 bit de la memoria de registro.
//////////////////////////////////////////////////////////////////////////////////


module REG_MEMORY
#(
   parameter ADDR_SIZE = 5,  // Instruction memory address size.
   parameter DATA_SIZE = 32,  // Data size in bits (INSTRUCTION_SIZE).
   parameter BUFFER_SIZE = 4,  // Number of register.
   parameter MEM_REG_TO_USER = 128  // Data size * 4.
)
(
   input wire i_clock,
   input wire i_reset,
   input wire i_wr_flag,  // 1 for write, 0 for read.
   input wire [ADDR_SIZE-1:0]  i_addr_A,   // A Reg address of the memory.
   input wire [ADDR_SIZE-1:0]  i_addr_B,   // B reg address of the memory.
   input wire [ADDR_SIZE-1:0]  i_addr_wr,  // Address to be written in the memory.
   input wire [DATA_SIZE-1:0]  i_data_in,  // Data to be written in A register.
   output wire [DATA_SIZE-1:0] o_data_A,  // A register to be read.
   output wire [DATA_SIZE-1:0] o_data_B,  // B register to be read.
   // Cables para Debug Mode:
   output wire [MEM_REG_TO_USER-1:0] o_mem_reg_to_user
);

   (* dont_touch = "yes" *) reg [DATA_SIZE-1:0] buffer [BUFFER_SIZE-1:0];  // Buffer of the memory.
   (* dont_touch = "yes" *) reg [DATA_SIZE-1:0] dataA;
   (* dont_touch = "yes" *) reg [DATA_SIZE-1:0] dataB;
   (* dont_touch = "yes" *) reg [MEM_REG_TO_USER-1:0] mem_to_user_reg; // Cable con fines de Debugging.

   //ESCRITURA
   always@(posedge i_clock) begin  // First write.
         if (i_reset) begin
            // buffer[1]=2;
            // buffer[2]=3;
            // buffer[3]=4;
         end
      else  if (i_wr_flag ) begin  // Write in the first cicle-time.
         //R0, always is 0
         buffer[ i_addr_wr] = (i_addr_wr != 0) ? i_data_in : {DATA_SIZE{1'b0}};  // Dynamic index (ADDR POSITION).
      end
   end

   // LECTURA
   always@(negedge i_clock) begin  // Read in the second cicle-time.
      dataA = buffer[i_addr_A];
      dataB = buffer[i_addr_B];

      // Asignación solo con fines de debuggin. Este cable permite visualizar la memoria.
      mem_to_user_reg[31:0]= buffer[0];
      mem_to_user_reg[63:32] = buffer[1];
      mem_to_user_reg[95:64] = buffer[2];
      mem_to_user_reg[127:96] = buffer[3];
   end


   // ASSIGNS
   assign o_data_B = dataB;  // Dynamic index (ADDR-B POSITION)
   assign o_data_A = dataA;  // Dynamic index (ADDR-A POSITION)
   assign o_mem_reg_to_user = mem_to_user_reg; // Cable solo con fines de debugging.

endmodule
