module Debuguer #(
    parameter SIZE_MEM = 1024,
    parameter SIZE_REG = 32,
    parameter SIZE_COMMAND = 8,
    parameter SIZE_PC = 32
) (
    input wire i_clk,
    input wire i_reset,
    input wire [(SIZE_COMMAND-1):0] i_command, //rx data
    input wire i_flag_rx_done, //rx done
    // input wire [(SIZE_PC-1):0] i_pc;
    input wire i_flag_halt,    

    // input wire [(SIZE_REG-1):0] i_data_wb;
    // input wire [(SIZE_REG-1):0] i_addr_wb;

    // input wire [(SIZE_REG-1):0] i_data_mem;
    // input wire [(SIZE_REG-1):0] i_addr_mem;

    // input wire i_flag_reg_write;
    // input wire i_flag_mem_write;

    output wire o_flag_instruction_write,  
    output wire [(SIZE_REG-1):0] o_instruction_data,
    output wire o_flag_start_program
);  


//Macros
localparam L=1;
localparam C=2;
localparam S=3;
localparam BYTES_PER_INSTRUCTION=4;
localparam HALT = 32'b0;

//States Codes
localparam ST_IDLE  = 4'b0001; 
localparam ST_RECEIVE_INSTRUCTION  = 4'b0010; 
localparam ST_SEND_INSTRUCTION  = 4'b0011; 
localparam ST_READY  = 4'b0100; 
localparam ST_STEP_TO_STEP  = 4'b0110; 
localparam ST_CONTINUE  = 4'b0111; 
localparam ST_SEND_DATA  = 4'b1000; 


//reguistros
reg [3:0] state, state_next;
reg [SIZE_REG-1:0] command, command_next;
reg [SIZE_REG-1:0] addr_mem, addr_mem_next;
reg [SIZE_REG-1:0] addr_wb, addr_wb_next;
reg [SIZE_REG-1:0] pc, pc_next;
reg [SIZE_REG-1:0] data_mem, data_mem_next;
reg [SIZE_REG-1:0] data_wb, data_wb_next;
reg flag_instruction_write, flag_instruction_write_next;
reg [SIZE_REG-1:0] buffer_inst, buffer_inst_next; //buffer de instruccion
reg [1:0] bytes_counter, bytes_counter_next;
reg flag_start_program;

/************************************************************************************
                              DEBUGUER STATE MACHINE.
*************************************************************************************/

always @ (posedge i_clk) begin
    if(i_reset)begin
        state <= ST_IDLE;
        state_next <=ST_IDLE;
        addr_mem <= 0;
        addr_mem_next <= 0;
        addr_wb <= 0;
        addr_wb_next <= 0;
        pc <= 0;
        pc_next <= 0;
        data_mem <= 0;
        data_mem_next <= 0;
        data_wb <= 0;
        data_wb_next <= 0;
        flag_instruction_write <= 0;
        flag_instruction_write_next <= 0;
        bytes_counter <= 0;
        bytes_counter_next <= 0;
        buffer_inst <= 32'b0;
        buffer_inst_next <= 32'b0;
        flag_start_program <=0;

    end
    else begin
        state <= state_next;
        addr_mem <= addr_mem_next;
        addr_wb <= addr_wb_next;
        pc <= pc_next;
        data_mem <= data_mem_next;
        data_wb <= data_wb_next;
        flag_instruction_write <= flag_instruction_write_next;
        bytes_counter <= bytes_counter_next;
        buffer_inst <= buffer_inst_next;
      end
end


always @ (*) begin
    state_next = state; 
    addr_mem_next = addr_mem;
    addr_wb_next = addr_wb;
    pc_next = pc;
    data_mem_next = data_mem;
    data_wb_next = data_wb;
    flag_instruction_write_next = flag_instruction_write;
     bytes_counter_next = bytes_counter;
     buffer_inst_next = buffer_inst;
     
     
    case(state)
        ST_IDLE: begin
            if(i_flag_rx_done)
            begin
                if(i_command==L)
                begin
                    state_next = ST_RECEIVE_INSTRUCTION;
                    bytes_counter_next=0;
                end 
            end
        end

        ST_RECEIVE_INSTRUCTION: begin
            flag_instruction_write_next = 0;
            if(i_flag_rx_done) begin
                //Ac� ya nos aseguramos que en i_command hay un byte de instrucci�n
                buffer_inst_next = {i_command, buffer_inst[(SIZE_REG-1):SIZE_COMMAND]};
                if(bytes_counter == BYTES_PER_INSTRUCTION-1) 
                begin
                    state_next = ST_SEND_INSTRUCTION;
                    bytes_counter_next = 0;
                end 
                else 
                    bytes_counter_next = bytes_counter + 1;
            end 

        end
        ST_SEND_INSTRUCTION: begin
            //enviamos data
            flag_instruction_write_next = 1;
            state_next = ST_RECEIVE_INSTRUCTION;
            //esperando un halt para pasar al siguiente estado 
            if(buffer_inst == HALT ) begin //! remplazar por if( intruccion == halt)
                state_next = ST_READY;
                flag_instruction_write_next = 0;
            end
            
        end
        
        ST_READY:
        begin
            if(i_flag_rx_done ) begin 
                if(i_command == C)
                begin
                    state_next = ST_CONTINUE; 
                end
                else if(i_command == S)
                begin
                    state_next = ST_STEP_TO_STEP; 
                end
            end
        end
        //ST_STEP_TO_STEP:
        ST_CONTINUE:
        begin
            flag_start_program=1;
        end
        default: begin
            state_next = ST_IDLE; 
        end
    endcase
end

/************************************************************************************
                              DEBUGUER OUTPUTS.
*************************************************************************************/

assign o_flag_instruction_write = flag_instruction_write;
assign o_instruccion_data = buffer_inst;
assign o_flag_instruction_write = flag_instruction_write;
assign o_flag_start_program=flag_start_program;




endmodule