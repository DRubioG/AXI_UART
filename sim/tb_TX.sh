
nvc -a ../src/clk_div.vhd
nvc -a ../src/TX.vhd

nvc -a tb_TX.vhd

nvc -e TX_tb

nvc -r TX_tb --stop-time=10ms --wave=TX_tb.vcd