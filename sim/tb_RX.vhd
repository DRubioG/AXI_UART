
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RX_tb is
end;

architecture bench of RX_tb is
  -- Clock period
  constant clk_period : time := 5 ns;
  -- Generics
  -- Ports
  signal CLK_I : std_logic := '0';
  signal RST_N_I : std_logic;
  signal EN_I : std_logic;
  signal DATA_O : std_logic_vector(7 downto 0);
  signal DATA_OK_O : std_logic;
  signal DUAL_STOP_I : std_logic;
  signal BAUDS_I : std_logic_vector(25 downto 0);
  signal PARITY_I : std_logic_vector(1 downto 0);
  signal BITS_SIZE_I : std_logic_vector(1 downto 0);
  signal RX_I : std_logic;
begin

  RX_inst : entity work.RX
  port map (
    CLK_I => CLK_I,
    RST_N_I => RST_N_I,
    EN_I => EN_I,
    DATA_O => DATA_O,
    DATA_OK_O => DATA_OK_O,
    DUAL_STOP_I => DUAL_STOP_I,
    BAUDS_I => BAUDS_I,
    PARITY_I => "01",
    BITS_SIZE_I => BITS_SIZE_I,
    RX_I => RX_I
  );
CLK_I <= not CLK_I after clk_period/2;
RST_N_I <= '0', '1' after 50 ns;
EN_I <= '1';
DUAL_STOP_I <= '0';
BAUDS_I <= (others => '0');
PARITY_I <= (others => '0');
BITS_SIZE_I <= (others => '0');
RX_I <= '0';
end;