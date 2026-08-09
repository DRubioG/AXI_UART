library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity antidebounce is
  port (
    --! Reloj del módulo.
    CLK_I : in std_logic;
    --! Reset del módulo. Activo a nivel bajo.
    RST_N_I : in std_logic;
    --! Señal de entrada.
    INPUT_I : in std_logic;
    --! Señal de salida.
    OUTPUT_O : out std_logic
  );
end antidebounce;

architecture Behavioral of antidebounce is
  --! CDC de la entrada.
  signal s_input_sync1, s_input_sync2 : std_logic;
  --! Señales para hacer el antirrebotes.
  signal s_d_ff1, s_d_ff2, s_d_ff3, s_d_ff4 : std_logic;
  --! Señales del biestable.
  signal s_J, s_K : std_logic;
  --! Señal de salida.
  signal s_Q : std_logic;

begin

  ----------------SYNC---------------------------
  SYNC : process (CLK_I, RST_N_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        s_input_sync1 <= '0';
        s_input_sync2 <= '0';
      else
        s_input_sync1 <= INPUT_I;
        s_input_sync2 <= s_input_sync1;
      end if;
    end if;
  end process;
  -------------------------------------------
  D_FF : process (CLK_I, RST_N_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        s_d_ff1 <= '0';
        s_d_ff2 <= '0';
        s_d_ff3 <= '0';
        s_d_ff4 <= '0';
      else
        s_d_ff1 <= s_input_sync2;
        s_d_ff2 <= s_d_ff1;
        s_d_ff3 <= s_d_ff2;
        s_d_ff4 <= s_d_ff3;
      end if;
    end if;
  end process;
  AND_L  : s_J <= s_d_ff1 and s_d_ff2 and s_d_ff3 and s_d_ff4;
  N_OR_L : s_K <= not (s_d_ff1 or s_d_ff2 or s_d_ff3 or s_d_ff4);
  JK_FF : process (CLK_I, RST_N_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        s_Q <= '0';
      else
        if s_J = '0' and s_K = '0' then
          s_Q <= s_Q;
        elsif s_J = '0' and s_K = '1' then
          s_Q <= '0';
        elsif s_J = '1' and s_K = '0' then
          s_Q <= '1';
        elsif s_J = '1' and s_K = '1' then
          s_Q <= not s_Q;
        end if;
      end if;
    end if;
  end process;

  OUTPUT_O <= s_Q;
end Behavioral;