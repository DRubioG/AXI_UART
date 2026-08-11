
nvc -a ../ip/AXI_UART_1_0/src/clk_div.vhd
nvc -a ../ip/AXI_UART_1_0/src/antirrebotes.vhd
nvc -a ../ip/AXI_UART_1_0/src/TX.vhd
nvc -a ../ip/AXI_UART_1_0/src/RX.vhd
nvc -a ../ip/AXI_UART_1_0/src/UART.vhd

nvc -a tb_UART.vhd

nvc -e UART_tb

nvc -r UART_tb --stop-time=10ms --wave=UART_tb.vcd