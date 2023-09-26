library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity Clock_Prescaling is
	port
	(
		i_EN   : in  std_logic;
		i_CLK  : in  std_logic;
		i_UBRR : in  std_logic_vector (11 downto 0);
		o_UCLK : out std_logic
	);
end Clock_Prescaling;

architecture RTL of Clock_Prescaling is
	signal r_UCLK : std_logic := '0';
	signal w_EN   : std_logic := '0';
begin

	UART_Clock : process (i_EN, i_CLK)
		variable v_COUNT : std_logic_vector(11 downto 0) := (others => '0');
	begin
		if i_EN = '0' then
			v_COUNT := (others => '0');
			r_UCLK <= '0';
		elsif rising_edge(i_CLK) and w_EN = '1' then
			v_COUNT := v_COUNT + 1;
			if v_COUNT = i_UBRR then
				r_UCLK <= not r_UCLK;
				v_COUNT := x"000";
			end if;
		end if;
	end process UART_Clock;

	w_EN <= '0' when i_UBRR = x"000" else
		'1';
	o_UCLK <= r_UCLK when w_EN = '1' else
		i_CLK;

end RTL;
