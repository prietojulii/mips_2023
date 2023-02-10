module UART_ticks 
#(
    parameter LEN_COUNTER  = 10, //2^len_counter >= MODULO
    parameter MODULO  = 651 // FR_COCK_HZ / (BAUDRATE * 16) =>  10MHz /(9600*16)
) 
(
 input wire i_clk,
 input wire i_reset,
 output wire o_tick
 );
    
    reg [LEN_COUNTER-1 : 0] counter;
    
    always @(posedge i_clk) begin
        if(i_reset)begin
            counter <= 0;
        end
        if(counter < MODULO)
            counter <= counter + 1;
        else
            counter <= 0;
    end
    
    
    assign o_tick = (counter==MODULO)? 1'b1 : 1'b0;
        
endmodule