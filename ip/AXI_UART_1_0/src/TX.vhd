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

entity TX is
  port (
    --! Reloj del módulo.
    CLK_I : in std_logic;
    --! Reset del módulo. Activo a nivel bajo.
    RST_N_I : in std_logic;
    --! Habilitación del módulo. Activo a nivel alto.
    EN_I : in std_logic;
    --! Dato a transmitir.
    DATA_I : in std_logic_vector(7 downto 0);
    --! Nuevo dato a transmitir. Activo a nivel alto.
    DATA_OK_I : in std_logic;
    --! Indicación de que la transmisión está activa. Activo a nivel alto.
    READY_O : out std_logic;
    --! Baudios de la UART.
    BAUDS_I : in std_logic_vector(25 downto 0);
    --! Indicación de doble bit de stop. Activo a nivel alto.
    DUAL_STOP_I : in std_logic;
    --! Indicación de paridad.
    PARITY_I : in std_logic_vector(1 downto 0);
    --! Tamaño de datos de la UART.
    BITS_SIZE_I : in std_logic_vector(1 downto 0);
    --! TX de la UART.
    TX_O : out std_logic
  );
end entity TX;

architecture rtl of TX is

  --! Máquina de estados.
  type fsm is (
    --! Estado de parada.
    SM_IDLE,
    --! Estado de envío del bit de START.
    SM_SEND_START,
    --! Estado de envío de los datos.
    SM_SEND_DATA,
  --! Estado de envío de la paridad.
    SM_SEND_PARITY,
    --! Estado de envío del bit de STOP.
    SM_SEND_STOP,
    --! Estado de envío del doble bit de STOP.
    SM_SEND_STOP2
  );
  --! Registro de la máquina de estados.
  signal re_state : fsm;
  --! Contador del número de bits.
  signal r_cont : integer range 0 to 8;
  --! Señales de control del divisor de frecuencia.
  signal s_clk, s_clk_div_en : std_logic;
  --! Señal auxiliar de envío de datos.
  signal s_data : std_logic_vector(DATA_I'range);
  --! Valor de la paridad a transmitir.
  signal r_parity_value : std_logic;
  --! Valor de contador de número de '1's.
  signal r_bit_counter : unsigned(2 downto 0);
  --! Valor de número de bits a enviar.
  signal r_bit_limit : integer;
  --! Número de 7 bits de transmisión.
  constant C_7_BITS : std_logic_vector(1 downto 0) := "01";
  --! Número de 6 bits de transmisión.
  constant C_6_BITS : std_logic_vector(1 downto 0) := "10";
  --! Número de 5 bits de transmisión.
  constant C_5_BITS : std_logic_vector(1 downto 0) := "11";
  

begin

  --! Control de la máquina de estados.
  FSM_PROCESS : process (CLK_I)
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
            if r_cont >= r_bit_limit then
              re_state <= SM_SEND_STOP;
              if PARITY_I(1) = '1' then
                re_state <= SM_SEND_PARITY;
              end if;
            end if;

          when SM_SEND_PARITY =>
            re_state <= SM_SEND_PARITY;
            if s_clk = '1' then
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

  --! Divisor de frecuencia.
  clk_div_inst : entity work.clk_div
    port map
    (
      CLK_I     => CLK_I,
      RST_N_I   => RST_N_I,
      EN_I      => s_clk_div_en,
      BAUDS_I   => BAUDS_I,
      CLK_MID_O => open,
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

  --! Transmisión de datos por la UART.
  TX_PROCESS : process (CLK_I)
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
        elsif re_state = SM_SEND_PARITY then
          TX_O <= r_parity_value;
        end if;
      end if;
    end if;
  end process;

  --! Desplazamiento de datos hacia la derecha para transmisión.
  DATA_SHIFTER : process (CLK_I)
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

  --! Indicación de señal de disponibilidad para transmisión.
  READY_PROCESS : process (CLK_I)
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

  --! Contador de número de bit transmitidos.
  CONT_BITS : process (CLK_I)
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

  --! Este process cuenta el número de '1's de la UART.
  BIT_CONT : process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        r_bit_counter <= (others => '0');
      elsif EN_I = '1' then
        if re_state = SM_SEND_DATA then
          if s_clk = '1' then
            if s_data(0) = '1' then
              r_bit_counter <= r_bit_counter + 1;
            end if;
          end if;
        elsif re_state = SM_IDLE then
          r_bit_counter <= (others => '0');
        end if;
      end if;
    end if;
  end process;

  --! Este process selecciona el valor de la paridad a transmitir.
  BIT_PARIDAD : process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        r_parity_value <= '0';
      elsif EN_I = '1' then
        if PARITY_I(0) = '0' then -- Paridad PAR
          r_parity_value <= '0';
          if r_bit_counter(0) = '1' then
            r_parity_value <= '1';
          end if;
        else --Paridad IMPAR
          r_parity_value <= '1';
          if r_bit_counter(0) = '1' then
            r_parity_value <= '0';
          end if;
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