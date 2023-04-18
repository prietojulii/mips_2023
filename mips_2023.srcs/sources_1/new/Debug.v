module Debuguer #(
    parameter SIZE_MEM = 1024,
    parameter SIZE_REG = 32,
    parameter SIZE_COMMAND = 8,
    parameter SIZE_PC = 32,
    parameter SIZE_BUFFER_TO_USER = 170,             // PC + Rs + Rt + A + B + AddrMem + DataMem
    parameter SIZE_RS = 5,
    parameter SIZE_RT = 5,
    parameter SIZE_TRAMA = 8
) (
    input wire i_clk,
    input wire i_reset,
    input wire [(SIZE_COMMAND-1):0] i_command, //rx data
    input wire i_flag_rx_done, //rx done
    input wire i_flag_tx_done,
    
    input wire i_flag_halt,
    input wire [(SIZE_PC-1):0] i_pc,
    input wire [(SIZE_RS-1):0] i_rs,
    input wire [(SIZE_RT-1):0] i_rt,
    input wire [(SIZE_REG-1):0] i_a,
    input wire [(SIZE_REG-1):0] i_b,
    input wire [(SIZE_REG-1):0] i_addr_mem,
    input wire [(SIZE_REG-1):0] i_data_mem,   

    // input wire [(SIZE_REG-1):0] i_data_wb;
    // input wire [(SIZE_REG-1):0] i_addr_wb;

    // input wire [(SIZE_REG-1):0] i_data_mem;
    // input wire [(SIZE_REG-1):0] i_addr_mem;

    // input wire i_flag_reg_write;
    // input wire i_flag_mem_write;

    output wire o_flag_instruction_write,
    output wire o_enable_pc,  
    output wire [(SIZE_REG-1):0] o_instruction_data,
    output wire [(SIZE_TRAMA-1):0] o_trama_tx,
    output wire o_tx_start,
    output wire o_flag_start_program,
    
    //TODO: OUTPUT TEST
    output wire  [3:0] o_wire_state_leds
    
);  


//Macros
localparam L=1;
localparam C=2;
localparam S=3;
localparam N=4;
localparam BYTES_PER_INSTRUCTION=4;
localparam HALT = 32'b0;
localparam TX_COUNTER= 21; // = SIZE_BUFFER_TO_USER/8

//States Codes
localparam ST_IDLE  = 4'b0001; 
localparam ST_RECEIVE_INSTRUCTION  = 4'b0010; 
localparam ST_SEND_INSTRUCTION  = 4'b0011; 
localparam ST_READY  = 4'b0100; 
localparam ST_STEP_TO_STEP  = 4'b0110; 
localparam ST_CONTINUE  = 4'b0111; 
localparam ST_FILL_BUFFER_TO_USER  = 4'b1000;
localparam ST_SEND_DATA_TO_USER = 4'b1001; 


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
reg [SIZE_BUFFER_TO_USER-1:0] buffer_to_user, buffer_to_user_next;
reg flag_start_program, enable_pc,enable_pc_next;
reg [SIZE_TRAMA-1:0] trama_tx, trama_tx_next;
reg [4:0] index, index_next;
reg tx_start,tx_start_next;
/************************************************************************************
                              DEBUGUER STATE MACHINE.
*************************************************************************************/

always @ (posedge i_clk) begin
    if(i_reset)begin
        state <= ST_IDLE;
        addr_mem <= 0;
        addr_wb <= 0;
        pc <= 0;
        data_mem <= 0;
        data_wb <= 0;
        flag_instruction_write <= 0;
        bytes_counter <= 0;
        buffer_inst <= 32'b0;
        flag_start_program <=0;
        enable_pc <= 0;
        trama_tx <= 0;
        index <= 0;
        tx_start <= 0;
        buffer_to_user <= 0;
 
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
        enable_pc <= enable_pc_next;
        trama_tx <= trama_tx_next;
        index <= index_next;
        tx_start <= tx_start_next;
        buffer_to_user <= buffer_to_user_next;
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
    enable_pc_next = enable_pc;
    trama_tx_next = trama_tx; 
    index_next = index;
    tx_start_next = tx_start;
    buffer_to_user_next = buffer_to_user;

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
                //Ac? ya nos aseguramos que en i_command hay un byte de instrucci?n
                buffer_inst_next = {i_command, buffer_inst[(SIZE_REG-1):SIZE_COMMAND]};
                if(bytes_counter == BYTES_PER_INSTRUCTION-1) 
                begin
                    state_next = ST_SEND_INSTRUCTION;
                    bytes_counter_next = 0;
                end 
                else 
                begin
                    bytes_counter_next = bytes_counter + 1;
                end
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
                    enable_pc = 1; 
                end
                else if(i_command == S)
                begin
                    state_next = ST_STEP_TO_STEP; 
                end
            end
        end
        ST_STEP_TO_STEP: begin
            if (i_flag_rx_done) begin
                if(i_command == N)begin
                    enable_pc_next = 1;
                    state_next = ST_FILL_BUFFER_TO_USER;
                end
                else begin 
                    enable_pc_next=0;
                end
            end
            else begin
                enable_pc_next=0;
            end
        end
        ST_FILL_BUFFER_TO_USER: begin
            enable_pc_next= 0; //reset pc_next
            //shifteando data
            buffer_to_user_next={i_pc,buffer_to_user[(SIZE_BUFFER_TO_USER-1):SIZE_PC]};         //PC
            buffer_to_user_next={i_rs,buffer_to_user[(SIZE_BUFFER_TO_USER-1):SIZE_RS]};         //RS
            buffer_to_user_next={i_rt,buffer_to_user[(SIZE_BUFFER_TO_USER-1):SIZE_RT]};         //RT
            buffer_to_user_next={i_a,buffer_to_user[(SIZE_BUFFER_TO_USER-1):SIZE_REG]};         //A
            buffer_to_user_next={i_b,buffer_to_user[(SIZE_BUFFER_TO_USER-1):SIZE_REG]};         //B
            buffer_to_user_next={i_addr_mem,buffer_to_user[(SIZE_BUFFER_TO_USER-1):SIZE_REG]}; //AddrMem
            buffer_to_user_next={i_data_mem,buffer_to_user[(SIZE_BUFFER_TO_USER-1):SIZE_REG]}; //DataMem
  
            state_next = ST_SEND_DATA_TO_USER;
        end

        ST_SEND_DATA_TO_USER:begin
            //    Ir sacando por el output_trama_tx los datos de a 8 bits para que el uart los transmita al usuario desdel buffer_to_user_next
            // Tener en cuenta la flax tx_done para enviar un nuevo byte
            //TODO: Chequear la flag tx_done antes de volver a enviar mas data.
            if(index == 0) begin
                    trama_tx_next = buffer_to_user_next[index*SIZE_TRAMA+:SIZE_TRAMA];
                    index_next = index + 1;
                    tx_start_next = 1;

            end
            else if(i_flag_tx_done) begin
                    trama_tx_next = buffer_to_user_next[index*SIZE_TRAMA+:SIZE_TRAMA];
                    if( index == TX_COUNTER ) // se envio todo el buffer
                    begin
                        tx_start_next = 0; //reset
                        index_next = 0; //reset
                        state_next = ST_STEP_TO_STEP;
                    end
                    else begin
                        index_next = index + 1;
                        tx_start_next = 1;
                    end
            end
            else begin
                    tx_start_next = 0;
            end
        end
        // ST_CONTINUE:
        // begin
        //     flag_start_program=1;
        // end
        default: begin
            state_next = ST_IDLE; 
        end
    endcase
end

/************************************************************************************
                              DEBUGUER OUTPUTS.
*************************************************************************************/

assign o_flag_instruction_write = flag_instruction_write;
assign o_enable_pc = enable_pc;
assign o_instruccion_data = buffer_inst;
assign o_flag_instruction_write = flag_instruction_write;
assign o_flag_start_program = flag_start_program;
assign o_trama_tx = trama_tx;
assign o_tx_start = tx_start;
assign o_wire_state_leds = state;

endmodule
