
nvc -a ../ip/AXI_UART_1_0/src/clk_div.vhd
nvc -a ../ip/AXI_UART_1_0/src/antirrebotes.vhd
nvc -a ../ip/AXI_UART_1_0/src/RX.vhd

nvc -a tb_RX.vhd

nvc -e RX_tb

nvc -r RX_tb --stop-time=300us --wave=RX_tb.vcd