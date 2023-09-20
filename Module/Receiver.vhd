library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.uart_package.all;

entity Receiver is
	generic
	(
		WIDTH : integer := 16
	);
	port
	(
		i_EN        : in  std_logic;
		i_RX_CLK    : in  std_logic;
		i_U2X       : in  std_logic;
		i_PARITY_EN : in  std_logic;
		i_RX_CLR    : in  std_logic;
		o_RX_DATA   : out std_logic_vector (WIDTH - 1 downto 0);
		o_RX_RDY    : out std_logic;
		o_RX_DV     : out std_logic;
		i_RX_SDI    : in  std_logic
	);
end Receiver;

architecture RTL of Receiver is

	type t_FSM is (IDLE, START_BIT, DATA_BITS, PARITY_BIT, STOP_BIT);

	signal r_PR_ST       : t_FSM                                := IDLE;
	signal r_NX_ST       : t_FSM                                := IDLE;
	signal r_RX_DATA     : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
	signal r_CYCLE_COUNT : integer range 0 to 15                := 0;
	signal r_BIT_COUNT   : integer range 0 to WIDTH             := 0;
	signal r_VALID_DATA  : std_logic                            := '0';

begin

	Sequential : process (i_EN, i_RX_CLK)
	begin

		if i_EN = '0' then
			r_CYCLE_COUNT <= 0;
			r_PR_ST       <= IDLE;
		elsif rising_edge(i_RX_CLK) then

			if r_PR_ST = IDLE or r_CYCLE_COUNT = 15 - 8 * to_int(i_U2X) then
				r_CYCLE_COUNT <= 0;
			else
				r_CYCLE_COUNT <= r_CYCLE_COUNT + 1;
			end if;

			r_PR_ST <= r_NX_ST;
		end if;

		if i_EN = '0' then
			r_RX_DATA    <= (others => '0');
			o_RX_DATA    <= (others => '0');
			o_RX_RDY     <= '0';
			o_RX_DV      <= '0';
			r_BIT_COUNT  <= 0;
			r_VALID_DATA <= '0';

		elsif rising_edge(i_RX_CLK) then

			if i_RX_CLR = '1' then
				o_RX_RDY <= '0';
				o_RX_DV  <= '0';
			end if;

			case r_PR_ST is
				when IDLE | START_BIT =>
					r_BIT_COUNT <= 0;

				when DATA_BITS =>
					if r_CYCLE_COUNT = 7 - 4 * to_int(i_U2X) then
						r_RX_DATA   <= r_RX_DATA(r_RX_DATA'left - 1 downto 0) & i_RX_SDI;
						r_BIT_COUNT <= r_BIT_COUNT + 1;
					elsif r_CYCLE_COUNT = 15 - 8 * to_int(i_U2X) then
						r_VALID_DATA <= not i_PARITY_EN;
					end if;

				when PARITY_BIT =>
					if r_CYCLE_COUNT = 7 - 4 * to_int(i_U2X) and calculate_parity_bit(r_RX_DATA) = i_RX_SDI then
						r_VALID_DATA <= '1';
					end if;

				when STOP_BIT =>
					if r_CYCLE_COUNT = 15 - 8 * to_int(i_U2X) then
						o_RX_RDY     <= '1';
						o_RX_DATA    <= r_RX_DATA;
						o_RX_DV      <= r_VALID_DATA;
						r_VALID_DATA <= '0';
					end if;

			end case;
		end if;

	end process Sequential;

	combinational : process (i_EN, r_PR_ST, i_RX_SDI, i_U2X, r_CYCLE_COUNT, r_BIT_COUNT, i_PARITY_EN)
	begin
		if i_EN = '0' then
			r_NX_ST <= IDLE;

		else

			r_NX_ST <= r_PR_ST;

			case r_PR_ST is

				when IDLE =>
					if i_RX_SDI = '0' then
						r_NX_ST <= START_BIT;
					end if;

				when START_BIT =>
					if r_CYCLE_COUNT = 8 - 4 * to_int(i_U2X) and i_RX_SDI = '1' then
						r_NX_ST <= IDLE;

					elsif r_CYCLE_COUNT = 15 - 8 * to_int(i_U2X) then
						r_NX_ST <= DATA_BITS;

					end if;

				when DATA_BITS =>
					if r_CYCLE_COUNT = 15 - 8 * to_int(i_U2X) and r_BIT_COUNT = WIDTH then

						if i_PARITY_EN = '1' then
							r_NX_ST <= PARITY_BIT;
						else
							r_NX_ST <= STOP_BIT;
						end if;

					end if;

				when PARITY_BIT =>
					if r_CYCLE_COUNT = 15 - 8 * to_int(i_U2X) then
						r_NX_ST <= STOP_BIT;
					end if;

				when STOP_BIT =>

					if r_CYCLE_COUNT = 15 - 8 * to_int(i_U2X) then
						if i_RX_SDI = '0' then
							r_NX_ST <= START_BIT;
						else
							r_NX_ST <= IDLE;
						end if;
					end if;

			end case;

		end if;

	end process combinational;

end RTL;
