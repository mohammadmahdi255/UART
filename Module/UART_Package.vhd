library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

package UART_Package is

	-- Function to calculate the parity bit
	function calculate_parity_bit(data : std_logic_vector) return std_logic;
	function to_int(b : std_logic) return integer;

end UART_Package;

package body UART_Package is

	-- Function to calculate the parity bit
	function calculate_parity_bit(data : std_logic_vector) return std_logic is
		variable v_TEMP          : std_logic := '0';
	begin
		for i in data'range loop
			v_TEMP := v_TEMP xor data(i);
		end loop;

		return v_TEMP;
	end function;
	
	function to_int(b : std_logic) return integer is
	begin
		return to_integer(unsigned'("0" & b));
	end function;
 
end UART_Package;
