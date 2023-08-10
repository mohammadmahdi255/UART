library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity Clock_Generation_Logic is
	port
	(
		i_EN     : in  std_logic;
		i_CLK    : in  std_logic;
		i_U2X    : in  std_logic;
		i_UCD    : in  std_logic_vector (15 downto 0);
		o_TX_CLK : out std_logic;
		o_RX_CLK : out std_logic
	);
end Clock_Generation_Logic;

architecture RTL of Clock_Generation_Logic is

	constant c_ZERO   : std_logic_vector(15 downto 0) := (others => '0');

	signal r_RE_COUNT : std_logic_vector(15 downto 0) := (others => '0');
	signal r_FE_COUNT : std_logic_vector(15 downto 0) := (others => '0');
	signal r_RE_CLEAR : std_logic                     := '0';
	signal r_FE_CLEAR : std_logic                     := '0';
	signal w_TOGGLE   : std_logic                     := '0';
	signal r_UCLKS    : std_logic_vector(4 downto 0)  := (others => '0');

begin

	Clock_Logic : process (i_EN, i_CLK)
	begin
		if i_EN = '0' then
			r_RE_COUNT <= c_ZERO;
			r_FE_COUNT <= c_ZERO;
		else
			if rising_edge(i_CLK) then
				r_RE_COUNT <= r_RE_COUNT + 1;
				r_FE_CLEAR <= '0';
				if r_RE_CLEAR = '1' then
					r_RE_COUNT <= c_ZERO + 1;
				end if;
				if r_RE_COUNT + r_FE_COUNT = i_UCD then
					r_FE_CLEAR <= '1' xor r_FE_CLEAR;
					r_RE_COUNT <= c_ZERO;
				end if;
			end if;

			if falling_edge(i_CLK) then
				r_FE_COUNT <= r_FE_COUNT + 1;
				r_RE_CLEAR <= '0';
				if r_FE_CLEAR = '1' then
					r_FE_COUNT <= c_ZERO + 1;
				end if;
				if r_RE_COUNT + r_FE_COUNT = i_UCD then
					r_RE_CLEAR <= '1' xor r_RE_CLEAR;
					r_FE_COUNT <= c_ZERO;
				end if;
			end if;
		end if;
	end process Clock_Logic;

	process (i_EN, w_TOGGLE)
	begin

		if i_EN = '0' then
			r_UCLKS <= (others => '0');
		elsif rising_edge(w_TOGGLE) then
			r_UCLKS <= r_UCLKS + 1;
		end if;

	end process;

	w_TOGGLE <= r_RE_CLEAR xor r_FE_CLEAR;

	o_RX_CLK <= r_UCLKS(0);
	o_TX_CLK <= r_UCLKS(4) when i_U2X = '0' else
		r_UCLKS(3);

end RTL;
