library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity UART is
	generic
	(
		WIDTH : integer := 16
	);
	port
	(
		i_EN        : in  std_logic;
		i_CLK       : in  std_logic;

		i_U2X       : in  std_logic;
		i_UCD       : in  std_logic_vector (15 downto 0);
		i_PARITY_EN : in  std_logic;

		i_TX_STR    : in  std_logic;
		o_TX_RDY    : out std_logic;
		
		-- RX Control and status pins
		i_RX_CLR    : in  std_logic;
		o_RX_RDY    : out std_logic;
		o_RX_DV     : out std_logic;
		o_RX_IDLE   : out std_logic;

		i_TX_DATA   : in  std_logic_vector (WIDTH - 1 downto 0);
		o_RX_DATA   : out std_logic_vector (WIDTH - 1 downto 0);

		o_TX_SDO    : out std_logic;
		i_RX_SDI    : in  std_logic
	);
end UART;

architecture RTL of UART is

	signal w_TX_CLK : std_logic := '0';
	signal w_RX_CLK : std_logic := '0';
begin

	Clock_Generator : entity WORK.Clock_Generation_Logic
		port map
		(
			i_EN     => i_EN,
			i_CLK    => i_CLK,
			i_U2X    => i_U2X,
			i_UCD    => i_UCD,
			o_TX_CLK => w_TX_CLK,
			o_RX_CLK => w_RX_CLK
		);

	Transmit_Module : entity WORK.Transmitter
		generic
		map
		(
		WIDTH => WIDTH
		)
		port
		map
		(
		i_EN        => i_EN,
		i_TX_CLK    => w_TX_CLK,
		i_TX_DATA   => i_TX_DATA,
		i_TX_STR    => i_TX_STR,
		i_PARITY_EN => i_PARITY_EN,
		o_TX_RDY    => o_TX_RDY,
		o_TX_SDO    => o_TX_SDO
		);

	Receiver_Module : entity WORK.Receiver
		generic
		map
		(
		WIDTH => WIDTH
		)
		port
		map
		(
		i_EN        => i_EN,
		i_RX_CLK    => w_RX_CLK,
		i_U2X       => i_U2X,
		i_PARITY_EN => i_PARITY_EN,
		i_RX_CLR    => i_RX_CLR,
		o_RX_DATA   => o_RX_DATA,
		o_RX_RDY    => o_RX_RDY,
		o_RX_DV     => o_RX_DV,
		o_RX_IDLE   => o_RX_IDLE,
		i_RX_SDI    => i_RX_SDI
		);

end RTL;
