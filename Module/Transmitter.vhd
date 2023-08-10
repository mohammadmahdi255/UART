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
		i_TX_STR    : in  std_logic;
		i_PARITY_EN : in  std_logic;
		o_TX_RDY    : out std_logic;
		o_TX_SDO    : out std_logic
	);
end Transmitter;

architecture RTL of Transmitter is

	type t_FSM is (IDLE, START_BIT, DATA_BITS, PARITY_BIT, STOP_BIT);

	signal r_PR_ST      : t_FSM                                := IDLE;
	signal w_NX_ST      : t_FSM                                := IDLE;
	signal r_TX_DATA    : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
	signal r_PARITY_BIT : std_logic                            := '0';
	signal r_BIT_COUNT  : integer range 0 to WIDTH - 1         := 0;

begin

	Sequential : process (i_EN, i_TX_CLK)
	begin

		if i_EN = '0' then
			r_PR_ST <= IDLE;
		elsif rising_edge(i_TX_CLK) then
			r_PR_ST <= w_NX_ST;
		end if;

		if i_EN = '0' then
			r_TX_DATA    <= (others => '0');
			r_BIT_COUNT  <= 0;
			r_PARITY_BIT <= '0';

		elsif rising_edge(i_TX_CLK) then
			case r_PR_ST is
				when IDLE | STOP_BIT =>
					if i_TX_STR = '1' then
						r_TX_DATA <= i_TX_DATA;
						r_BIT_COUNT <= 0;
					end if;

				when START_BIT =>
					r_PARITY_BIT <= calculate_parity_bit(r_TX_DATA);

				when DATA_BITS =>
					r_TX_DATA   <= r_TX_DATA(r_TX_DATA'left - 1 downto 0) & '0';
					r_BIT_COUNT <= r_BIT_COUNT + 1;

				when PARITY_BIT =>
			end case;
		end if;

	end process Sequential;

	combinational : process (i_EN, r_PR_ST, i_TX_STR, r_TX_DATA, r_BIT_COUNT, i_PARITY_EN, r_PARITY_BIT)
	begin
		if i_EN = '0' then
			w_NX_ST  <= IDLE;
			o_TX_SDO <= '1';

		else
			w_NX_ST <= r_PR_ST;

			case r_PR_ST is
				when IDLE =>
					o_TX_SDO <= '1';
					if i_TX_STR = '1' then
						w_NX_ST <= START_BIT;
					end if;

				when START_BIT =>
					o_TX_SDO <= '0';
					w_NX_ST  <= DATA_BITS;

				when DATA_BITS =>
					o_TX_SDO <= r_TX_DATA(r_TX_DATA'left);

					if r_BIT_COUNT = WIDTH - 1 then
						if i_PARITY_EN = '1' then
							w_NX_ST <= PARITY_BIT;
						else
							w_NX_ST <= STOP_BIT;
						end if;
					end if;

				when PARITY_BIT =>
					o_TX_SDO <= r_PARITY_BIT;
					w_NX_ST  <= STOP_BIT;

				when STOP_BIT =>
					o_TX_SDO <= '1';
					if i_TX_STR = '1' then
						w_NX_ST <= START_BIT;
					else
						w_NX_ST <= IDLE;
					end if;

			end case;

		end if;
	end process combinational;

	o_TX_RDY <= '1' when r_PR_ST = IDLE or r_PR_ST = STOP_BIT else
		'0';

end RTL;
