library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity UART_TB is
end UART_TB;

architecture behavior of UART_TB is

	-- Component Declaration for the Unit Under Test (UUT)

	component UART
		generic
		(
			WIDTH : integer := 16
		);
		port
		(
			i_EN        : in  std_logic;
			i_CLK       : in  std_logic;
			i_U2X       : in  std_logic;
			i_UCD       : in  std_logic_vector(WIDTH - 1 downto 0);
			i_PARITY_EN : in  std_logic;
			i_TX_STR    : in  std_logic;
			o_TX_RDY    : out std_logic;
			i_RX_CLR    : in  std_logic;
			o_RX_RDY    : out std_logic;
			o_RX_DV     : out std_logic;
			i_TX_DATA   : in  std_logic_vector(WIDTH - 1 downto 0);
			o_RX_DATA   : out std_logic_vector(WIDTH - 1 downto 0);
			o_TX_SDO    : out std_logic;
			i_RX_SDI    : in  std_logic
		);
	end component;

	constant WIDTH        : integer                              := 16;

	--Inputs
	signal i_EN           : std_logic                            := '0';
	signal i_CLK          : std_logic                            := '0';
	signal i_U2X          : std_logic                            := '0';
	signal i_UCD          : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
	signal i_PARITY_EN    : std_logic                            := '0';
	signal i_TX_STR       : std_logic                            := '0';
	signal i_RX_CLR       : std_logic                            := '0';
	signal i_TX_DATA      : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
	signal i_RX_SDI       : std_logic                            := '0';

	--Outputs
	signal o_TX_RDY       : std_logic;
	signal o_RX_RDY       : std_logic;
	signal o_RX_DV        : std_logic;
	signal o_RX_DATA      : std_logic_vector(WIDTH - 1 downto 0);
	signal o_TX_SDO       : std_logic;

	-- Clock period definitions
	constant i_CLK_period : time := 10 ns;

begin

	-- Instantiate the Unit Under Test (UUT)
	uut : UART
	generic
	map
	(
	WIDTH => WIDTH
	)
	port map
	(
		i_EN        => i_EN,
		i_CLK       => i_CLK,
		i_U2X       => i_U2X,
		i_UCD       => i_UCD,
		i_PARITY_EN => i_PARITY_EN,
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

	-- Clock process definitions
	i_CLK_process : process
	begin
		i_CLK <= '0';
		wait for i_CLK_period/2;
		i_CLK <= '1';
		wait for i_CLK_period/2;
	end process;

	i_RX_SDI <= o_TX_SDO;

	-- Stimulus process
	stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;
		i_EN        <= '1';
		i_U2X       <= '1';
		i_UCD       <= x"0000";
		i_PARITY_EN <= '0';

		wait for 100 ns;
		i_TX_STR  <= '1';
		i_TX_DATA <= x"F8DA";

		wait for 20 ns;
		i_TX_STR  <= '0';
		i_TX_DATA <= x"AD43";

		wait until o_TX_RDY = '1';
		i_TX_STR <= '1';
		
		wait for 100 ns;
		i_RX_CLR <= '1';
		wait for 30 ns;
		i_RX_CLR <= '0';

		wait;
	end process;

end;
