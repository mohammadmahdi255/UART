library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.uart_package.all;

entity Transmitter is
	generic
	(
		WIDTH : integer := 16
	);
	port
	(
		i_EN        : in  std_logic;
		i_TX_CLK    : in  std_logic;
		i_TX_DATA   : in  std_logic_vector (WIDTH - 1 downto 0);
		i_TX_STR     : in  std_logic;
		i_PARITY_EN : in  std_logic;
		o_TX_RDY    : out std_logic;
		o_TX_SDO    : out std_logic
	);
end Transmitter;

architecture RTL of Transmitter is

	type t_FSM is (START_BIT, DATA_BITS, PARITY_BIT, STOP_BIT);

	signal r_PR_ST           : t_FSM                                := START_BIT;
	signal r_TX_DATA         : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
	signal r_PARITY_BIT      : std_logic                            := '0';
	signal r_BIT_COUNT       : integer range 0 to WIDTH - 1         := 0;

begin

	Transmitter : process (i_EN, i_TX_CLK)
	begin
		if i_EN = '0' then
			r_PR_ST      <= START_BIT;
			r_TX_DATA    <= (others => '0');
			r_PARITY_BIT <= '0';
			r_BIT_COUNT  <= 0;
			o_TX_RDY     <= '1';
			o_TX_SDO     <= '1';

		elsif rising_edge(i_TX_CLK) then
			case r_PR_ST is
				when START_BIT =>
					o_TX_RDY <= not i_TX_STR;
					o_TX_SDO <= not i_TX_STR;

					if i_TX_STR = '1' then
						r_TX_DATA    <= i_TX_DATA;
						r_PARITY_BIT <= calculate_parity_bit(i_TX_DATA);
						r_PR_ST      <= DATA_BITS;
					end if;

				when DATA_BITS =>
					o_TX_SDO    <= r_TX_DATA(r_TX_DATA'left);
					r_TX_DATA   <= r_TX_DATA(r_TX_DATA'left - 1 downto 0) & '0';
					r_BIT_COUNT <= r_BIT_COUNT + 1;
					if r_BIT_COUNT = WIDTH - 1 then
						r_BIT_COUNT <= 0;

						if i_PARITY_EN = '1' then
							r_PR_ST <= PARITY_BIT;
						else
							r_PR_ST <= STOP_BIT;
						end if;
					end if;

				when PARITY_BIT =>
					o_TX_SDO <= r_PARITY_BIT;
					r_PR_ST  <= STOP_BIT;

				when STOP_BIT =>
					o_TX_SDO <= '1';
					r_PR_ST  <= START_BIT;

			end case;

		end if;
	end process Transmitter;

end RTL;
