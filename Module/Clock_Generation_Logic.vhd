library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.uart_package.to_int;

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
	
	
	signal r_RE_UCKL : std_logic  := '0';
	signal r_FE_UCKL : std_logic := '0';

	signal r_UCKLS : std_logic_vector(3 downto 0)  := (others => '0');

	signal w_PRS_CLK  : std_logic := '0';

begin

	Clock_Logic : process (i_EN, i_CLK)
		variable v_RE_COUNT : std_logic_vector(15 downto 0) := (others => '0');
		variable v_FE_COUNT : std_logic_vector(15 downto 0) := (others => '0');
	begin
		if i_EN = '0' then
			v_RE_COUNT := c_ZERO;
			v_FE_COUNT := c_ZERO;
			r_RE_UCKL <= '0';
			r_FE_UCKL <= '0';
		else
			if rising_edge(i_CLK) then
				r_FE_CLEAR <= '0';
				if r_RE_CLEAR = '1' then
					v_RE_COUNT := c_ZERO;
				end if;
				
				if v_RE_COUNT + v_FE_COUNT = i_UCD then
					r_RE_UCKL <= not r_RE_UCKL;
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
					r_FE_UCKL <= not r_FE_UCKL;
					r_RE_CLEAR <= '1';
					v_FE_COUNT := c_ZERO;
				else
					v_FE_COUNT := v_FE_COUNT + 1;
				end if;
			end if;
		end if;
	end process Clock_Logic;

	process (i_EN, w_PRS_CLK)

	begin
		if i_EN = '0' then
			r_UCKLS <= (others => '0');
			o_TX_CLK <= '0';
		elsif rising_edge(w_PRS_CLK) then
			r_UCKLS <= r_UCKLS + 1;
			if i_U2X = '1' then
				o_TX_CLK <= r_UCKLS(2);
			else
				o_TX_CLK <= r_UCKLS(3);
			end if;
		end if;
	end process;

	w_PRS_CLK <= r_RE_UCKL xor r_FE_UCKL;
	o_RX_CLK  <= w_PRS_CLK;
end RTL;
