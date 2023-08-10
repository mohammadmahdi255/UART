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
		i_RX_SDI    : in  std_logic
	);
end Receiver;

architecture RTL of Receiver is

	type t_FSM is (START_BIT, WAIT_CYCLE, DATA_BITS, PARITY_BIT, STOP_BIT);

	signal r_PR_ST       : t_FSM                                := START_BIT;
	signal r_RX_DATA     : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
	signal r_CYCLE_COUNT : integer range 0 to 15                := 0;
	signal w_SAMPLE_EN   : boolean                              := false;
	signal r_BIT_COUNT   : integer range 0 to WIDTH - 1         := 0;
	signal r_VALID_DATA  : std_logic                            := '0';

begin

	Receiver : process (i_EN, i_RX_CLK, i_RX_CLR, r_VALID_DATA)
	begin
		if i_EN = '0' then
			r_PR_ST       <= START_BIT;
			r_RX_DATA     <= (others => '0');
			o_RX_DATA     <= (others => '0');
			r_CYCLE_COUNT <= 0;
			r_BIT_COUNT   <= 0;
			r_VALID_DATA  <= '0';
			o_RX_RDY      <= '0';

		elsif rising_edge(i_RX_CLK) then
			r_CYCLE_COUNT <= r_CYCLE_COUNT + 1;

			if i_RX_CLR = '1' then
				o_RX_RDY <= '0';
			end if;

			if w_SAMPLE_EN then
				r_CYCLE_COUNT <= 0;
			end if;

			case r_PR_ST is

				when START_BIT =>
					if i_RX_SDI = '0' then
						r_PR_ST <= WAIT_CYCLE;
					else
						r_CYCLE_COUNT <= 0;
					end if;

				when WAIT_CYCLE =>
					if w_SAMPLE_EN then
						r_PR_ST <= DATA_BITS;
					end if;

				when DATA_BITS =>
					if w_SAMPLE_EN then
						r_RX_DATA   <= r_RX_DATA(r_RX_DATA'left - 1 downto 0) & i_RX_SDI;
						r_BIT_COUNT <= r_BIT_COUNT + 1;

						if r_BIT_COUNT = WIDTH - 1 then
							r_BIT_COUNT <= 0;

							if i_PARITY_EN = '1' then
								r_PR_ST <= PARITY_BIT;
							else
								r_VALID_DATA <= '1';
								r_PR_ST      <= STOP_BIT;
							end if;
						end if;

					end if;

				when PARITY_BIT =>
					if w_SAMPLE_EN then
						if calculate_parity_bit(r_RX_DATA) = i_RX_SDI then
							r_VALID_DATA <= '1';
						end if;
						r_PR_ST <= STOP_BIT;
					end if;

				when STOP_BIT =>

					if r_VALID_DATA = '1' then
						o_RX_RDY     <= '1';
						o_RX_DATA    <= r_RX_DATA;
						r_VALID_DATA <= '0';
					end if;

					if w_SAMPLE_EN then
						r_PR_ST <= START_BIT;
					end if;

			end case;

		end if;

	end process Receiver;

	w_SAMPLE_EN <= (i_U2X = '0' and r_CYCLE_COUNT = 7) or (i_U2X = '1' and r_CYCLE_COUNT = 3) when r_PR_ST = WAIT_CYCLE else
		(i_U2X = '0' and r_CYCLE_COUNT = 15) or (i_U2X = '1' and r_CYCLE_COUNT = 7);

end RTL;
