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

entity UART is
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
    --! Dato a transmitir.
    DATA_O : out std_logic_vector(7 downto 0);
    --! Nuevo dato recibido. Activo a nivel alto.
    DATA_OK_O : out std_logic;
    --! Indicación de doble bit de stop. Activo a nivel alto.
    DUAL_STOP_I : in std_logic;
    --! Indicación de que la transmisión está activa. Activo a nivel alto.
    READY_O : out std_logic;
    --! Baudios de la UART.
    BAUDS_I : in std_logic_vector(25 downto 0);
    --! Indicación de paridad.
    PARITY_I : in std_logic_vector(1 downto 0);
    --! Tamaño de datos de la UART.
    BITS_SIZE_I : in std_logic_vector(1 downto 0);
    --! TX de la UART.
    TX_O : out std_logic;
    --! RX de la UART.
    RX_I : in std_logic

  );
end entity UART;

architecture rtl of UART is

begin

  --! Instanciación de RX.
  RX_inst : entity work.RX
    port map
    (
      CLK_I       => CLK_I,
      RST_N_I     => RST_N_I,
      EN_I        => EN_I,
      DATA_O      => DATA_O,
      DATA_OK_O   => DATA_OK_O,
      BAUDS_I     => BAUDS_I,
      PARITY_I    => PARITY_I,
      BITS_SIZE_I => BITS_SIZE_I,
      DUAL_STOP_I => DUAL_STOP_I,
      RX_I        => RX_I
    );

  --! Instanciación de TX.
  TX_inst : entity work.TX
    port map
    (
      CLK_I       => CLK_I,
      RST_N_I     => RST_N_I,
      EN_I        => EN_I,
      DATA_I      => DATA_I,
      DATA_OK_I   => DATA_OK_I,
      DUAL_STOP_I => DUAL_STOP_I,
      BAUDS_I     => BAUDS_I,
      READY_O     => READY_O,
      PARITY_I    => PARITY_I,
      BITS_SIZE_I => BITS_SIZE_I,
      TX_O        => TX_O
    );

end architecture;