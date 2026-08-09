library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity RX is
  generic (
    G_CLK_FPGA : integer := 100_000_000;
    G_BAUDS    : integer := 115_200
  );
  port (
    CLK_I     : in std_logic;
    RST_N_I   : in std_logic;
    EN_I      : in std_logic;
    DATA_O    : out std_logic_vector(7 downto 0);
    DATA_OK_O : out std_logic;
    RX_I      : in std_logic
  );
end entity RX;

architecture rtl of RX is

  type fsm is (
    SM_S0,
    SM_IDLE,
    SM_START,
    SM_DATA,
    SM_STOP,
    SM_FINISH
  );

  signal re_state : fsm;

  signal s_clk, s_clk_mid, s_clk_div_en : std_logic;

  signal s_rx_i : std_logic;

  signal r_cont : integer range 0 to 8;
  signal s_data : std_logic_vector(DATA_O'range);

begin

  antidebounce_inst : entity work.antidebounce
    port map
    (
      CLK_I    => CLK_I,
      RST_N_I  => RST_N_I,
      INPUT_I  => RX_I,
      OUTPUT_O => s_rx_i
    );

  process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        re_state <= SM_IDLE;
      elsif EN_I = '1' then
        case re_state is
          when SM_S0 =>
            re_state <= SM_S0;
            if s_rx_i = '1' then
              re_state <= SM_IDLE;
            end if;
          when SM_IDLE =>
            re_state <= SM_IDLE;
            if s_rx_i = '0' then
              re_state <= SM_START;
            end if;
          when SM_START =>
            re_state <= SM_START;
            if s_clk = '1' then
              re_state <= SM_DATA;
            end if;
          when SM_DATA =>
            re_state <= SM_DATA;
            if r_cont >= 8 then
              re_state <= SM_STOP;
            end if;
          when SM_STOP =>
            if s_clk = '1' then
              re_state <= SM_FINISH;
            end if;
          when SM_FINISH =>
            re_state <= SM_IDLE;
          when others =>
            re_state <= SM_IDLE;
        end case;
      end if;
    end if;
  end process;

  clk_div_inst : entity work.clk_div
    generic map(
      G_CYCLE => G_CLK_FPGA/G_BAUDS
    )
    port map
    (
      CLK_I     => CLK_I,
      RST_N_I   => RST_N_I,
      EN_I      => s_clk_div_en,
      CLK_MID_O => s_clk_mid,
      CLK_DIV_O => s_clk
    );
  process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        s_clk_div_en <= '0';
      elsif EN_I = '1' then
        s_clk_div_en <= '1';
        if re_state = SM_IDLE then
          s_clk_div_en <= '0';
        end if;
      end if;
    end if;
  end process;
  process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        s_data <= (others => '0');
      elsif EN_I = '1' then
        if re_state = SM_DATA then
          if s_clk_mid = '1' then
            s_data <= s_rx_i & s_data(7 downto 1);
          end if;
        end if;
      end if;
    end if;
  end process;

  DATA_O <= s_data;
  process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        DATA_OK_O <= '0';
      elsif EN_I = '1' then
        DATA_OK_O <= '0';
        if re_state = SM_FINISH then
          DATA_OK_O <= '1';
        end if;
      end if;
    end if;
  end process;

  process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        r_cont <= 0;
      elsif EN_I = '1' then
        if re_state = SM_DATA then
          if s_clk = '1' then
            r_cont <= r_cont + 1;
          end if;
        else
          r_cont <= 0;
        end if;
      end if;
    end if;
  end process;

end architecture;