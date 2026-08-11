
--! Registros
--! ==
--! | Nombre  | Offset | R/W | Descripción |
--! |---------|--------|-----|-------------|
--! | CNTRL   |   0x0  |  W  | Registro de control del bloque IP |
--! |   TX    |   0x4  |  W  | Registro para transmitir por la UART |
--! |   RX    |   0x8  |  R  | Registro para recibir datos por la UART |
--!
--! CNTRL
--! --
--! - **EN**: Bit de habilitación del bloque IP.
--! - **DS**: Bit de dual STOP de la UART.
--! - **PAR**: Paridad de la UART.
--! - **PARITY**
--! | PARITY | VALUE |
--! |--------|-------|
--! |  NONE  |   00  |
--! |  PAR   |   10  |
--! |  IMPAR |   11  |
--!
--! - **BITS**
--!
--! | PARITY | VALUE |
--! |--------|-------|
--! | 8 bits |   00  |
--! | 7 bits |   01  |
--! | 6 bits |   10  |
--! | 5 bits |   11  |
--! - **BSZ**: Número de bits de la UART.
--! - **BAUDS**: Baudios de la UART.

--! {
--!       "config": { 
--!         "hspace": 1000
--!       },
--!     reg:[
--!     { "name": "EN",   	"bits": 1, "attr": "w", "type": 4},
--!     { "name": "DS",  	  "bits": 1, "attr": "w", "type": 5 },
--!     { "name": "PAR",   	"bits": 2, "attr": "w", "type": 6 },
--!     { "name": "BSZ",   	"bits": 2, "attr": "w", "type": 7 },
--!     { "name": "BAUDS",  "bits": 26, "attr": "w", "type": 2 },
--! ]}
--! WRITE
--! --
--! - **DATA**: Dato a transmitir.
--! - **DOK**: Envío de datos por la UART.
--! {
--!       "config": { 
--!         "hspace": 1000
--!       },
--!     reg:[
--!     { "name": "DATA",   	"bits": 8, "attr": "w", "type":4 },
--!     { "name": "DOK",   		"bits": 1, "attr": "w", "type":3 },
--!     { "name": "Reserved",   "bits": 23, "attr": "", "type":"not used" }
--! ]}
--! READ
--! --
--! - **Data**: Dato leído por UART.
--! - **DOK**: Recepción de la UART.
--! - **RDY**: Indicador de que el módulo UART está listo.
--! {
--!       "config": { 
--!         "hspace": 1000
--!       },
--!     reg:[
--!     { "name": "DATA",   	"bits": 8, "attr": "r", "type":4 },
--!     { "name": "DOK",   		"bits": 1, "attr": "r", "type":3 },
--!     { "name": "RDY",   		"bits": 1, "attr": "r", "type": 5 },
--!     { "name": "Reserved",   "bits": 22, "attr": "", "type":"not used" }
--! ]}
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AXI_UART_v1_0 is
  generic (
    -- Users to add parameters here

    -- User parameters ends
    -- Do not modify the parameters beyond this line
    -- Parameters of Axi Slave Bus Interface S00_AXI
    C_S00_AXI_DATA_WIDTH : integer := 32;
    C_S00_AXI_ADDR_WIDTH : integer := 4
  );
  port (
    -- Users to add ports here
    RX : in std_logic;
    TX : out std_logic;

    --! @virtualbus AXI @dir in
    -- User ports ends
    -- Do not modify the ports beyond this line
    -- Ports of Axi Slave Bus Interface S00_AXI
    s00_axi_aclk    : in std_logic;
    s00_axi_aresetn : in std_logic;
    s00_axi_awaddr  : in std_logic_vector(C_S00_AXI_ADDR_WIDTH - 1 downto 0);
    s00_axi_awprot  : in std_logic_vector(2 downto 0);
    s00_axi_awvalid : in std_logic;
    s00_axi_awready : out std_logic;
    s00_axi_wdata   : in std_logic_vector(C_S00_AXI_DATA_WIDTH - 1 downto 0);
    s00_axi_wstrb   : in std_logic_vector((C_S00_AXI_DATA_WIDTH/8) - 1 downto 0);
    s00_axi_wvalid  : in std_logic;
    s00_axi_wready  : out std_logic;
    s00_axi_bresp   : out std_logic_vector(1 downto 0);
    s00_axi_bvalid  : out std_logic;
    s00_axi_bready  : in std_logic;
    s00_axi_araddr  : in std_logic_vector(C_S00_AXI_ADDR_WIDTH - 1 downto 0);
    s00_axi_arprot  : in std_logic_vector(2 downto 0);
    s00_axi_arvalid : in std_logic;
    s00_axi_arready : out std_logic;
    s00_axi_rdata   : out std_logic_vector(C_S00_AXI_DATA_WIDTH - 1 downto 0);
    s00_axi_rresp   : out std_logic_vector(1 downto 0);
    s00_axi_rvalid  : out std_logic;
    s00_axi_rready  : in std_logic
    --! @end
  );
end AXI_UART_v1_0;

architecture arch_imp of AXI_UART_v1_0 is

begin

  -- Instantiation of Axi Bus Interface S00_AXI
  AXI_UART_v1_0_S00_AXI_inst : entity work.AXI_UART_v1_0_S00_AXI
    generic map(
      C_S_AXI_DATA_WIDTH => C_S00_AXI_DATA_WIDTH,
      C_S_AXI_ADDR_WIDTH => C_S00_AXI_ADDR_WIDTH
    )
    port map
    (
      RX            => RX,
      TX            => TX,
      S_AXI_ACLK    => s00_axi_aclk,
      S_AXI_ARESETN => s00_axi_aresetn,
      S_AXI_AWADDR  => s00_axi_awaddr,
      S_AXI_AWPROT  => s00_axi_awprot,
      S_AXI_AWVALID => s00_axi_awvalid,
      S_AXI_AWREADY => s00_axi_awready,
      S_AXI_WDATA   => s00_axi_wdata,
      S_AXI_WSTRB   => s00_axi_wstrb,
      S_AXI_WVALID  => s00_axi_wvalid,
      S_AXI_WREADY  => s00_axi_wready,
      S_AXI_BRESP   => s00_axi_bresp,
      S_AXI_BVALID  => s00_axi_bvalid,
      S_AXI_BREADY  => s00_axi_bready,
      S_AXI_ARADDR  => s00_axi_araddr,
      S_AXI_ARPROT  => s00_axi_arprot,
      S_AXI_ARVALID => s00_axi_arvalid,
      S_AXI_ARREADY => s00_axi_arready,
      S_AXI_RDATA   => s00_axi_rdata,
      S_AXI_RRESP   => s00_axi_rresp,
      S_AXI_RVALID  => s00_axi_rvalid,
      S_AXI_RREADY  => s00_axi_rready
    );

  -- Add user logic here

  -- User logic ends

end arch_imp;
