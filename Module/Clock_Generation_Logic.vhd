LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.std_logic_unsigned.all;

entity Clock_Generation_Logic is
	port
	(
		i_EN     : in  std_logic;
		i_CLK    : in  std_logic;
		i_U2X    : in  std_logic;
		i_UBRR   : in  std_logic_vector (11 downto 0);
		o_TX_CLK : out std_logic;
		o_RX_CLK : out std_logic
	);
end Clock_Generation_Logic;

architecture RTL of Clock_Generation_Logic is
	signal r_COUNT    : std_logic_vector(11 downto 0) := (others => '0');
	signal r_TX_COUNT : std_logic_vector(3 downto 0)  := (others => '0');
	signal r_UCLK     : std_logic                     := '0';
begin

	UART_Clock : process (i_EN, i_UBRR, i_CLK)
	begin
		if i_EN = '0' then
			r_COUNT    <= (others => '0');
			r_TX_COUNT <= (others => '0');
			r_UCLK     <= '0';
		elsif rising_edge(i_CLK) then
			case i_UBRR is
				when x"000" =>
					r_COUNT    <= x"000";
					r_TX_COUNT <= r_TX_COUNT + 1;
					r_UCLK     <= '0';
					
				when others =>
					r_COUNT <= r_COUNT + 1;
					if r_COUNT = i_UBRR then
						r_COUNT    <= x"000";
						r_UCLK     <= not r_UCLK;
						if r_UCLK = '0' then
							r_TX_COUNT <= r_TX_COUNT + 1;
						end if;
						
					end if;
			end case;
			
		end if;
	end process UART_Clock;

	o_RX_CLK <= i_CLK when i_UBRR = x"000" else r_UCLK;
	o_TX_CLK <= r_TX_COUNT(3) when i_U2X = '0' else
		r_TX_COUNT(2);

end RTL;
