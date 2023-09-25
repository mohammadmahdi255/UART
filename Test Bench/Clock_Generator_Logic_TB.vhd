library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Clock_Generator_Logic_TB is
end Clock_Generator_Logic_TB;

architecture behavior of Clock_Generator_Logic_TB is

	-- Component Declaration for the Unit Under Test (UUT)

	component Clock_Generation_Logic
		port
		(
			i_EN     : in  std_logic;
			i_CLK    : in  std_logic;
			i_U2X    : in  std_logic;
			i_UCD    : in  std_logic_vector(15 downto 0);
			o_TX_CLK : out std_logic;
			o_RX_CLK : out std_logic
		);
	end component;

	--Inputs
	signal i_EN           : std_logic                     := '0';
	signal i_CLK          : std_logic                     := '0';
	signal i_U2X          : std_logic                     := '0';
	signal i_UCD          : std_logic_vector(15 downto 0) := (others => '0');

	--Outputs
	signal o_TX_CLK       : std_logic;
	signal o_RX_CLK       : std_logic;

	-- Clock period definitions
	constant i_CLK_period : time := 10 ns;

begin

	-- Instantiate the Unit Under Test (UUT)
	uut : Clock_Generation_Logic port map
	(
		i_EN     => i_EN,
		i_CLK    => i_CLK,
		i_U2X    => i_U2X,
		i_UCD    => i_UCD,
		o_TX_CLK => o_TX_CLK,
		o_RX_CLK => o_RX_CLK
	);

	-- Clock process definitions
	i_CLK_process : process
	begin
		i_CLK <= '0';
		wait for i_CLK_period/2;
		i_CLK <= '1';
		wait for i_CLK_period/2;
	end process;

	-- Stimulus process
	stim_proc : process
	begin
		-- hold reset state for 100 ns.
		--      wait for i_CLK_period*10;
		i_EN  <= '1';
		i_UCD <= x"0004";
		i_U2X <= '0';

		wait for i_CLK_period * 10;

		-- insert stimulus here 

		wait;
	end process;

end;
