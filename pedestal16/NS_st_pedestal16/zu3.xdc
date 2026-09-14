create_clock -period 1.50 -name clk [get_ports clk]
set_property -dict {IOSTANDARD LVCMOS33} [get_ports {clk}]