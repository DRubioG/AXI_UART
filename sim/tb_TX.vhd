
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TX_tb is
end;

architecture bench of TX_tb is
  -- Clock period
  constant clk_period : time := 5 ns;
  -- Generics
  constant G_CLK_FPGA : integer := 100_000_000;
  constant G_BAUDS : integer := 115_200;
  -- Ports
  signal CLK_I : std_logic := '0';
  signal RST_N_I : std_logic;
  signal EN_I : std_logic;
  signal DATA_I : std_logic_vector(7 downto 0);
  signal DATA_OK_I : std_logic;
  signal READY_O : std_logic;
  signal TX_O : std_logic;
  signal DUAL_STOP_I : std_logic;
begin

  TX_inst : entity work.TX
  generic map (
    G_CLK_FPGA => G_CLK_FPGA,
    G_BAUDS => G_BAUDS
  )
  port map (
    CLK_I => CLK_I,
    RST_N_I => RST_N_I,
    EN_I => EN_I,
    DATA_I => DATA_I,
    DATA_OK_I => DATA_OK_I,
    DUAL_STOP_I => DUAL_STOP_I,
    READY_O => READY_O,
    TX_O => TX_O
  );
CLK_I <= not CLK_I after clk_period/2;
RST_N_I <= '0', '1' after 50 ns;
EN_I <= '1';
DUAL_STOP_I <= '1';

DATA_I <= x"5A";

process begin
    DATA_OK_I <= '0';
    wait for 100 us;
    DATA_OK_I <= '1';
    wait for clk_period;
    DATA_OK_I <= '0';
end process;

end;