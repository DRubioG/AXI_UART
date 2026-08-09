library ieee;
use ieee.std_logic_1164.all;

entity TX is
  generic (
    G_CLK_FPGA : integer := 100_000_000;
    G_BAUDS    : integer := 115_200
  );
  port (
    CLK_I       : in std_logic;
    RST_N_I     : in std_logic;
    EN_I        : in std_logic;
    DATA_I      : in std_logic_vector(7 downto 0);
    DATA_OK_I   : in std_logic;
    READY_O     : out std_logic;
    DUAL_STOP_I : in std_logic;
    TX_O        : out std_logic
  );
end entity TX;

architecture rtl of TX is

  type fsm is (
    SM_IDLE,
    SM_SEND_START,
    SM_SEND_DATA,
    SM_SEND_STOP,
    SM_SEND_STOP2
  );
  signal re_state : fsm;

  signal r_cont : integer range 0 to 8;

  signal s_clk, s_clk_div_en : std_logic;

  signal s_data : std_logic_vector(DATA_I'range);

begin

  process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        re_state <= SM_IDLE;
      elsif EN_I = '1' then
        case re_state is
          when SM_IDLE =>
            re_state <= SM_IDLE;
            if DATA_OK_I = '1' then
              re_state <= SM_SEND_START;
            end if;
          when SM_SEND_START =>
            re_state <= SM_SEND_START;
            if s_clk = '1' then
              re_state <= SM_SEND_DATA;
            end if;

          when SM_SEND_DATA =>
            re_state <= SM_SEND_DATA;
            if r_cont >= 8 then
              re_state <= SM_SEND_STOP;
            end if;

          when SM_SEND_STOP =>
            re_state <= SM_SEND_STOP;
            if s_clk = '1' then
              re_state <= SM_IDLE;
              if DUAL_STOP_I = '1' then
                re_state <= SM_SEND_STOP2;
              end if;
            end if;


          when SM_SEND_STOP2 =>
            re_state <= SM_SEND_STOP2;
            if s_clk = '1' then
              re_state <= SM_IDLE;
            end if;
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
      CLK_MID_O => open,
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
        TX_O <= '1';
      elsif EN_I = '1' then
        TX_O <= '1';
        if re_state = SM_SEND_START then
          TX_O <= '0';
        elsif re_state = SM_SEND_DATA then
          TX_O <= s_data(0);
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
        if re_state = SM_SEND_START then
          s_data <= DATA_I;
        elsif re_state = SM_SEND_DATA then
          if s_clk = '1' then
            s_data <= s_data(7) & s_data(7 downto 1);
          end if;
        end if;
      end if;
    end if;
  end process;
  process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        READY_O <= '0';
      elsif EN_I = '1' then
        READY_O <= '0';
        if re_state = SM_IDLE then
          READY_O <= '1';
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
        if re_state = SM_SEND_DATA then
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