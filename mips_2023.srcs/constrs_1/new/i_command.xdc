
# Clock signal
set_property PACKAGE_PIN W5 [get_ports i_clock]							
	set_property IOSTANDARD LVCMOS33 [get_ports i_clock]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports i_clock]
  
	
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
#set_property PACKAGE_PIN W18 [get_ports {o_command[4]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {o_command[4]}]
#set_property PACKAGE_PIN U15 [get_ports {o_command[5]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {o_command[5]}]
#set_property PACKAGE_PIN U14 [get_ports {o_command[6]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {o_command[6]}]
#set_property PACKAGE_PIN V14 [get_ports {o_command[7]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {o_command[7]}]

#set_property PACKAGE_PIN V13 [get_ports {b[0]}]	
#	set_property IOSTANDARD LVCMOS33 [get_ports {b[0]}]
#set_property PACKAGE_PIN V3 [get_ports {b[1]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {b[1]}]
#set_property PACKAGE_PIN W3 [get_ports {b[2]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {b[2]}]
#set_property PACKAGE_PIN U3 [get_ports {b[3]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {b[3]}]
#set_property PACKAGE_PIN P3 [get_ports {b[4]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {b[4]}]
#set_property PACKAGE_PIN N3 [get_ports {b[5]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {b[5]}]
#set_property PACKAGE_PIN P1 [get_ports {b[6]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {b[6]}]
#set_property PACKAGE_PIN L1 [get_ports {b[7]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {b[7]}] 	

set_property BITSTREAM.STARTUP.STARTUPCLK JTAGCLK [current_design]

set_property CFGBVS VCCO [current_design]
#where value1 is either VCCO or GND

set_property CONFIG_VOLTAGE 3.3 [current_design]