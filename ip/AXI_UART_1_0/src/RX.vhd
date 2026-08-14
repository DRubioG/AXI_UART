--! PARITY
--! --
--! | PARITY | VALUE |
--! |--------|-------|
--! |  NONE  |   00  |
--! |  PAR   |   10  |
--! |  IMPAR |   11  |
--! BITS
--! --
--! | PARITY | VALUE |
--! |--------|-------|
--! | 8 bits |   00  |
--! | 7 bits |   01  |
--! | 6 bits |   10  |
--! | 5 bits |   11  |
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RX is
  port (
    --! Reloj del módulo.
    CLK_I : in std_logic;
    --! Reset del módulo. Activo a nivel bajo.
    RST_N_I : in std_logic;
    --! Habilitación del módulo. Activo a nivel alto.
    EN_I : in std_logic;
    --! Dato a transmitir.
    DATA_O : out std_logic_vector(7 downto 0);
    --! Nuevo dato recibido. Activo a nivel alto.
    DATA_OK_O : out std_logic;
    --! Indicación de doble bit de stop. Activo a nivel alto.
    DUAL_STOP_I : in std_logic;
    --! Baudios de la UART.
    BAUDS_I : in std_logic_vector(25 downto 0);
    --! Indicación de paridad.
    PARITY_I : in std_logic_vector(1 downto 0);
    --! Tamaño de datos de la UART.
    BITS_SIZE_I : in std_logic_vector(1 downto 0);
    --! RX de la UART.
    RX_I : in std_logic
  );
end entity RX;

architecture rtl of RX is

  --! Máquina de estados.
  type fsm is (
    --! Espera a que el bit de recepción sea 1.
    SM_S0,
    --! Estado de espera.
    SM_IDLE,
    --! Estado de recepción del bit START.
    SM_START,
    --! Estado de recepción de datos.
    SM_DATA,
    --! Estado de recepción del bit de paridad.
    SM_PARITY,
    --! Estado de recepción del bit de STOP.
    SM_STOP,
    --! Estado de recepción del doble bit de STOP.
    SM_STOP2,
    --! Estado de finalización de recepción.
    SM_FINISH
  );
  --! Registro de la máquina de estados.
  signal re_state : fsm;
  --! Señales de control del divisor de frecuencia.
  signal s_clk, s_clk_mid, s_clk_div_en : std_logic;

  --! Dato de recepción limpio.
  signal s_rx_i : std_logic;
  --! Contador del número de bits.
  signal r_cont : integer range 0 to 8;
  --! Señal auxiliar de recepción de datos.
  signal s_data      : std_logic_vector(DATA_O'range);
  --! Selector de número de bits a recibir.
  signal r_bit_limit : integer;

  --! Número de 7 bits de transmisión.
  constant C_7_BITS : std_logic_vector(1 downto 0) := "01";
  --! Número de 6 bits de transmisión.
  constant C_6_BITS : std_logic_vector(1 downto 0) := "10";
  --! Número de 5 bits de transmisión.
  constant C_5_BITS : std_logic_vector(1 downto 0) := "11";
begin

  --! Instanciación del antirrebotes.
  antidebounce_inst : entity work.antidebounce
    port map
    (
      CLK_I    => CLK_I,
      RST_N_I  => RST_N_I,
      INPUT_I  => RX_I,
      OUTPUT_O => s_rx_i
    );

  --! Máquina de estados.
  FSM_PROCESS : process (CLK_I)
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
            if r_cont >= r_bit_limit-1 then
              re_state <= SM_STOP;
              if PARITY_I(1) = '1' then
                re_state <= SM_PARITY;
              end if;
            end if;

          when SM_PARITY =>
            re_state <= SM_PARITY;
            if s_clk = '1' then
              re_state <= SM_STOP;
            end if;

          when SM_STOP =>
            re_state <= SM_STOP;
            if s_clk = '1' then
              re_state <= SM_FINISH;
              if DUAL_STOP_I = '1' then
                re_state <= SM_STOP2;
              end if;
            end if;

          when SM_STOP2 =>
            re_state <= SM_STOP2;
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

  --! Divisor de frecuencia.
  clk_div_inst : entity work.clk_div
    port map
    (
      CLK_I     => CLK_I,
      RST_N_I   => RST_N_I,
      EN_I      => s_clk_div_en,
      BAUDS_I   => BAUDS_I,
      CLK_MID_O => s_clk_mid,
      CLK_DIV_O => s_clk
    );

  --! Habilitación del divisor de frecuencia.
  DIVISOR_CONTROL : process (CLK_I)
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

  --! Recepción de datos por la UART.
  RX_PROCESS : process (CLK_I)
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

  --! Asinación de datos de salida.
  DATA : DATA_O <= s_data;

  --! Indicador de recepción de datos.
  NEW_DATA_INDICATOR : process (CLK_I)
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

  --! Contador de número de bit transmitidos.
  CONT_BITS : process (CLK_I)
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

  --! Este process selecciona el valor del número de bits de la UART.
  LIMITE_CONTADOR : process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        r_bit_limit <= 8;
      elsif EN_I = '1' then
        r_bit_limit <= 8;
        if BITS_SIZE_I = C_7_BITS then
          r_bit_limit <= 7;
        elsif BITS_SIZE_I = C_6_BITS then
          r_bit_limit <= 6;
        elsif BITS_SIZE_I = C_5_BITS then
          r_bit_limit <= 5;
        end if;
      end if;
    end if;
  end process;

end architecture;