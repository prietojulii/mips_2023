module UART_rx
    #(
        parameter SIZE_TRAMA_BIT = 8,
        parameter SIZE_BIT_COUNTER = 3  //tamaño del contadoe de bits
    )
    (
        input wire i_clk,
        input wire  i_reset,
        input wire i_rx,
        input wire  i_tick,
        output reg o_flag_rx_done,
        output wire [(SIZE_TRAMA_BIT-1):0] o_buff_data
    );



localparam TICK16 = 16;             //Ticks de muestreo
localparam TICK7 = 7;             //Ticks de sinc


//ESTADOS FSMD (REPRESENTACION: One-Cold)
localparam [3:0]
    ST_IDLE     =   4'b1110,        //Estado de espera
    ST_START    =   4'b1101,        //Estado de recepcion de start bit 
    ST_DATA     =   4'b1011,        //Estado de recepcion de data bits
    ST_STOP     =   4'b0111;        //Estado de recepcion de stop bit


//VARIABLES LOCALES
reg flag_rx_done,flag_rx_done_next;               //flag de recepcion terminada
reg[3:0] state_reg, state_next;                 //Estado
reg[3:0] tiks_count,tiks_count_next;            //contador de ticks
reg[(SIZE_BIT_COUNTER-1):0] bits_count,bits_count_next;            //contador de bits
reg[(SIZE_TRAMA_BIT-1):0] buff_data,buff_data_next;              //buffer de bits
 
always @(posedge i_clk) begin

    if (i_reset) begin
            state_reg <= ST_IDLE;
            tiks_count <= 0;
            bits_count <= 0;
            buff_data <= 0;
    end
    else begin
        state_reg <= state_next;
        tiks_count <= tiks_count_next;
        bits_count <= bits_count_next;
        buff_data <= buff_data_next;
    end
end

always @(*) begin

    state_next = state_reg;
    o_flag_rx_done = 1'b0;
    tiks_count_next = tiks_count;
    bits_count_next = bits_count;
    buff_data_next = buff_data;

    case (state_reg)
        ST_IDLE: begin
            if(~i_rx)begin
                state_next = ST_START;
                tiks_count_next = 0;
            end
        end
        ST_START: begin
            if(i_tick) begin
                if(tiks_count == TICK7) begin
                    state_next = ST_DATA;
                    tiks_count_next = 0;
                    bits_count_next = 0;
                end
                else
                    tiks_count_next = tiks_count + 1;
            end
        end
        ST_DATA: begin
            if(i_tick)begin
                if(tiks_count == 15) begin
                    tiks_count_next = 0;
                    buff_data_next = {i_rx, buff_data[(SIZE_TRAMA_BIT-1):1]};
                    if(bits_count == (SIZE_TRAMA_BIT-1))
                        state_next = ST_STOP;
                    else
                        bits_count_next = bits_count + 1;
                end
                else
                    tiks_count_next = tiks_count + 1;
            end
        end
        ST_STOP: begin
            if(i_tick) begin
                if(tiks_count == (TICK16 - 1)) begin
                    state_next = ST_IDLE;
                    o_flag_rx_done = 1'b1;
                end
                else
                    tiks_count_next = tiks_count + 1;
            end
        end
    endcase   
end

assign o_buff_data = buff_data;
endmodule