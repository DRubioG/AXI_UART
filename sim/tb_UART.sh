
nvc -a ../src/clk_div.vhd
nvc -a ../src/antirrebotes.vhd
nvc -a ../src/TX.vhd
nvc -a ../src/RX.vhd
nvc -a ../src/UART.vhd

nvc -a tb_UART.vhd

nvc -e UART_tb

nvc -r UART_tb --stop-time=10ms --wave=UART_tb.vcd