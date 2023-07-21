`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Julieta Prieto y Mateo Merino
// 
// Create Date: 16.12.2022 12:21:54
// Design Name: 
// Module Name: Uart TX.
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
module UART_tx 
#(
    parameter SIZE_TRAMA_BIT = 8,  // Len TRAMA of bit.
    parameter SIZE_BIT_COUNTER = 3  // Bits del contador para contar de 0 hasta SIZE_BIT_COUNTER-1.
)
(
    input wire i_clk,  // Clock.
    input wire i_reset,  // Reset.
    input wire i_tx_start,  // Start bit.
    input wire i_tick,  //Tick.
    input wire [(SIZE_TRAMA_BIT-1):0] i_buff_trama,  // Buffer de datos recibidos.
    output wire o_flag_tx_done,  // "flag" de transmision terminada.
    output wire o_tx  // Serial data transmitida.

);

    localparam TICKS_PER_BIT = 15;  //Ticks de muestreo - 1

    //ESTADOS FSMD (REPRESENTACION: One-Cold)
    localparam [3:0]
        ST_IDLE     =   4'b1110,  // Estado de espera.
        ST_START    =   4'b1101,  // Estado de transmision de start bit .
        ST_DATA     =   4'b1011,  // Estado de transmision de data bits.
        ST_STOP     =   4'b0111;  // Estado de transmision de stop bit.


    //VARIABLES LOCALES
    reg      tx_reg,            tx_next;                        // Dato a transmitir.
    reg      flag_tx_done,      flag_tx_done_next;              // "flag" de transmision terminada.
    reg[3:0] state_reg,         state_next;                     // Estado.
    reg[3:0] tiks_count,        tiks_count_next;                // Contador de ticks.
    reg[(SIZE_BIT_COUNTER-1):0] bits_count, bits_count_next;    // Contador de bits.
    reg[(SIZE_TRAMA_BIT-1):0]   buff_trama, i_buff_trama_next;  // Buffer de bits por transmitir.


    //LOGICA DE FSMD ESTADO
    always @ (posedge i_clk)
    begin
        if (i_reset)  // Reset sincronico
        begin
            state_reg     <= ST_IDLE;
            tiks_count    <= 0;
            bits_count    <= 0;
            buff_trama    <= 0;
            tx_reg        <= 1;  // ~start
            flag_tx_done  <= 0;
        end
        else
        begin
            state_reg       <= state_next;
            tiks_count      <= tiks_count_next;
            bits_count      <= bits_count_next;
            buff_trama      <= i_buff_trama_next;
            flag_tx_done    <= flag_tx_done_next;
            tx_reg          <= tx_next;
        end
    end

    // LOGICA DEL SIGUIENTE ESTADO
    always @(*)
    begin

        // Else unificado para cada *case*
        state_next          = state_reg; 
        tiks_count_next     = tiks_count;
        bits_count_next     = bits_count;
        i_buff_trama_next   = buff_trama;
        flag_tx_done_next   = flag_tx_done;

        case(state_reg)
            ST_IDLE:
                begin
                    flag_tx_done_next = 0;
                    tx_next = 1;  // ~start
                    if (i_tx_start)
                    begin
                        state_next          = ST_START;
                        tiks_count_next     = 0;  // Reset count tiks.
                        i_buff_trama_next   = i_buff_trama;  // Almacena el dato a transmitir.
                    end
                end
            ST_START:
            begin
            flag_tx_done_next = 0;
                tx_next = 0;  // Start bit.
                if(i_tick)
                begin
                    if (tiks_count == TICKS_PER_BIT) 
                        begin
                            state_next      = ST_DATA;
                            tiks_count_next = 0;  // Reset count tiks.
                            bits_count_next = 0;  // Reset count bits.
                        end
                    else
                        tiks_count_next = tiks_count + 1;
                end
            end
            ST_DATA:
            begin
                tx_next = buff_trama[0];
                if (i_tick)
                begin
                    if (tiks_count == TICKS_PER_BIT)
                        begin
                            tiks_count_next = 0;                   // Reset count tiks.
                            i_buff_trama_next  = buff_trama >> 1;  // Shift buffer.
                            if (bits_count == (SIZE_TRAMA_BIT-1))  // Termine de enviar los bits ?
                                    state_next = ST_STOP;
                            else
                                bits_count_next = bits_count + 1;
                        end
                    else 
                        tiks_count_next = tiks_count + 1;  // Incremento el contador de ticks.
                end
            end
            ST_STOP:
            begin
                tx_next = 1;  // Bit de stop es un 1.
                if (i_tick)
                begin
                    if (tiks_count == TICKS_PER_BIT)
                    begin
                        state_next = ST_IDLE;
                        flag_tx_done_next = 1;  // Flag indico que termine de enviar.
                    end
                    else 
                        tiks_count_next = tiks_count + 1; 
                end
            end
            default:
            begin
                tx_next = 1; // Error (nunca queremos un 0 aca o podriamos comenzar una transmision erronea).
                state_next = ST_IDLE; 
                flag_tx_done_next = flag_tx_done;
            end
        endcase
    end

    // Cableado de salida
    assign o_tx = tx_reg;
    assign o_flag_tx_done = flag_tx_done;

endmodule
