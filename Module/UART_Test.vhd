library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_Test is
    Port ( 
		i_EN        : in  std_logic;
		i_CLK       : in  std_logic;

		i_TX_STR    : in  std_logic;
		o_TX_RDY    : out std_logic;
		i_RX_CLR    : in  std_logic;
		o_RX_RDY    : out std_logic;
		o_RX_DV     : out std_logic;

		i_TX_DATA   : in  std_logic_vector (7 downto 0);
		o_RX_DATA   : out std_logic_vector (7 downto 0);

		o_TX_SDO    : out std_logic;
		i_RX_SDI    : in  std_logic
		   
		   );
end UART_Test;

architecture RTL of UART_Test is

begin

	UART_uut : entity Work.UART
		generic
		map(WIDTH => 8)
		port
		map (
		i_EN        => i_EN,
		i_CLK       => i_CLK,

		i_U2X       => '0',
		i_UCD       => x"0000",
		i_PARITY_EN => '0',

		i_TX_STR    => i_TX_STR,
		o_TX_RDY    => o_TX_RDY,
		i_RX_CLR    => i_RX_CLR,
		o_RX_RDY    => o_RX_RDY,
		o_RX_DV     => o_RX_DV,

		i_TX_DATA   => i_TX_DATA,
		o_RX_DATA   => o_RX_DATA,

		o_TX_SDO    => o_TX_SDO,
		i_RX_SDI    => i_RX_SDI
		);


end RTL;

