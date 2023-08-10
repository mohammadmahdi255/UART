LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY Clock_Generator_Logic_TB IS
END Clock_Generator_Logic_TB;
 
ARCHITECTURE behavior OF Clock_Generator_Logic_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Clock_Generation_Logic
    PORT(
         i_EN : IN  std_logic;
         i_CLK : IN  std_logic;
         i_U2X : IN  std_logic;
         i_UCD : IN  std_logic_vector(15 downto 0);
         o_TX_CLK : OUT  std_logic;
         o_RX_CLK : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal i_EN : std_logic := '0';
   signal i_CLK : std_logic := '0';
   signal i_U2X : std_logic := '0';
   signal i_UCD : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal o_TX_CLK : std_logic;
   signal o_RX_CLK : std_logic;

   -- Clock period definitions
   constant i_CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Clock_Generation_Logic PORT MAP (
          i_EN => i_EN,
          i_CLK => i_CLK,
          i_U2X => i_U2X,
          i_UCD => i_UCD,
          o_TX_CLK => o_TX_CLK,
          o_RX_CLK => o_RX_CLK
        );

   -- Clock process definitions
   i_CLK_process :process
   begin
		i_CLK <= '0';
		wait for i_CLK_period/2;
		i_CLK <= '1';
		wait for i_CLK_period/2;
   end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
--      wait for i_CLK_period*10;
	  i_EN <= '1';
	  i_UCD <= x"0000";
	  i_U2X <= '1';


      wait for i_CLK_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
