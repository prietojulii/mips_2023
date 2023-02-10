	`timescale 1ns / 1ps

	module UART
			#(
			parameter TRAMA_SIZE  = 8 //tamaño de la trama
			)
			(
			input wire i_clk,
			input wire i_reset,
			input wire i_rx,
			input wire [TRAMA_SIZE-1:0] i_tx, 
			input wire i_tx_start,
			output wire [TRAMA_SIZE-1:0] o_rx,
			output wire o_rx_done_tick,
			output wire o_tx,
			output wire o_tx_done_tick
			);

	wire ticks;

	UART_ticks uart_ticks (.i_clk(i_clk),
								   .i_reset(i_reset),
								   .o_tick(ticks));

	UART_rx uart_rx (.i_clk(i_clk),
							 .i_reset(i_reset),
							 .i_rx(i_rx),
                             .i_tick(ticks),
							 .o_flag_rx_done(o_rx_done_tick),
							 .o_buff_data(o_rx));

	UART_tx uart_tx (.i_clk(i_clk),
							   .i_reset(i_reset),
							   .i_tx_start(i_tx_start),
							   .i_tick(ticks),
							   .i_buff_trama(i_tx),
							   .o_flag_tx_done(o_tx_done_tick),
							   .o_tx(o_tx));    

	endmodule