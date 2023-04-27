
# Clock signal
set_property PACKAGE_PIN W5 [get_ports i_clock]
set_property IOSTANDARD LVCMOS33 [get_ports i_clock]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports i_clock]


##Buttons enable
set_property PACKAGE_PIN U18 [get_ports i_reset]
set_property IOSTANDARD LVCMOS33 [get_ports i_reset]


#Pines RX-TX
set_property PACKAGE_PIN B18 [get_ports i_rx]
set_property IOSTANDARD LVCMOS33 [get_ports i_rx]
set_property PACKAGE_PIN A18 [get_ports o_tx]
set_property IOSTANDARD LVCMOS33 [get_ports o_tx]

#   LEDS
set_property PACKAGE_PIN U16 [get_ports {o_wire_state_leds_pins[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_wire_state_leds_pins[0]}]
set_property PACKAGE_PIN E19 [get_ports {o_wire_state_leds_pins[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_wire_state_leds_pins[1]}]
set_property PACKAGE_PIN U19 [get_ports {o_wire_state_leds_pins[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_wire_state_leds_pins[2]}]
set_property PACKAGE_PIN V19 [get_ports {o_wire_state_leds_pins[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_wire_state_leds_pins[3]}]

set_property PACKAGE_PIN W18 [get_ports {o_wire_bytes_counter_leds_pins[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {o_wire_bytes_counter_leds_pins[0]}]
set_property PACKAGE_PIN U15 [get_ports {o_wire_bytes_counter_leds_pins[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {o_wire_bytes_counter_leds_pins[1]}]

set_property PACKAGE_PIN U14 [get_ports {o_wire_bytes_counter_leds_pins[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {o_wire_bytes_counter_leds_pins[2]}]
	
set_property PACKAGE_PIN V14 [get_ports {o_wire_instruction_buffer_MSB_leds_pin[31]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {o_wire_instruction_buffer_MSB_leds_pin[31]}]
set_property PACKAGE_PIN V13 [get_ports {o_wire_instruction_buffer_MSB_leds_pin[30]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {o_wire_instruction_buffer_MSB_leds_pin[30]}]
set_property PACKAGE_PIN V3 [get_ports {o_wire_instruction_buffer_MSB_leds_pin[29]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {o_wire_instruction_buffer_MSB_leds_pin[29]}]
set_property PACKAGE_PIN W3 [get_ports {o_wire_instruction_buffer_MSB_leds_pin[28]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {o_wire_instruction_buffer_MSB_leds_pin[28]}]
set_property PACKAGE_PIN U3 [get_ports {o_wire_instruction_buffer_MSB_leds_pin[27]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {o_wire_instruction_buffer_MSB_leds_pin[27]}]
set_property PACKAGE_PIN P3 [get_ports {o_wire_instruction_buffer_MSB_leds_pin[26]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {o_wire_instruction_buffer_MSB_leds_pin[26]}]
set_property PACKAGE_PIN N3 [get_ports {o_wire_instruction_buffer_MSB_leds_pin[25]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {o_wire_instruction_buffer_MSB_leds_pin[25]}]
set_property PACKAGE_PIN P1 [get_ports {o_wire_instruction_buffer_MSB_leds_pin[24]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {o_wire_instruction_buffer_MSB_leds_pin[24]}]
set_property PACKAGE_PIN L1 [get_ports {o_wire_instruction_buffer_MSB_leds_pin[23]}]					
	set_property IOSTANDARD LVCMOS33 [get_port {o_wire_instruction_buffer_MSB_leds_pin[23]}]

set_property BITSTREAM.STARTUP.STARTUPCLK JTAGCLK [current_design]

set_property CFGBVS VCCO [current_design]
#where value1 is either VCCO or GND

set_property CONFIG_VOLTAGE 3.3 [current_design]

