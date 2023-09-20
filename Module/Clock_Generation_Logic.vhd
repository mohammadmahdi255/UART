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

	signal r_RE_CLEAR : std_logic                     := '0';
	signal r_FE_CLEAR : std_logic                     := '0';

	signal r_RE_UCKLS : std_logic_vector(4 downto 0)  := (others => '0');
	signal r_FE_UCKLS : std_logic_vector(4 downto 0)  := (others => '0');

	signal w_UCLKS    : std_logic_vector(2 downto 0)  := (others => '0');

begin

	Clock_Logic : process (i_EN, i_CLK)
		variable v_RE_COUNT : std_logic_vector(15 downto 0) := (others => '0');
		variable v_FE_COUNT : std_logic_vector(15 downto 0) := (others => '0');
	begin
		if i_EN = '0' then
			v_RE_COUNT := c_ZERO;
			v_FE_COUNT := c_ZERO;
			r_RE_UCKLS <= (others => '0');
			r_FE_UCKLS <= (others => '0');
		else
			if rising_edge(i_CLK) then
				r_FE_CLEAR <= '0';
				if r_RE_CLEAR = '1' then
					v_RE_COUNT := c_ZERO;
				end if;
				if v_RE_COUNT + v_FE_COUNT = i_UCD then
					r_RE_UCKLS <= r_RE_UCKLS + 1;
					r_FE_CLEAR <= '1';
					v_RE_COUNT := c_ZERO;
				else
					v_RE_COUNT := v_RE_COUNT + 1;
				end if;

			end if;

			if falling_edge(i_CLK) then
				r_RE_CLEAR <= '0';
				if r_FE_CLEAR = '1' then
					v_FE_COUNT := c_ZERO;
				end if;
				if v_RE_COUNT + v_FE_COUNT = i_UCD then
					r_FE_UCKLS <= r_FE_UCKLS + 1;
					r_RE_CLEAR <= '1';
					v_FE_COUNT := c_ZERO;
				else
					v_FE_COUNT := v_FE_COUNT + 1;
				end if;
			end if;
		end if;
	end process Clock_Logic;

	process (r_RE_UCKLS, r_FE_UCKLS)
		variable v_SUM : std_logic_vector(4 downto 0);
	begin
		v_SUM := r_RE_UCKLS + r_FE_UCKLS;
		w_UCLKS(0) <= v_SUM(0);
		w_UCLKS(1) <= v_SUM(3);
		w_UCLKS(2) <= v_SUM(4);
	end process;

	o_RX_CLK <= w_UCLKS(0);
	o_TX_CLK <= w_UCLKS(2) when i_U2X = '0' else
		w_UCLKS(1);

end RTL;
