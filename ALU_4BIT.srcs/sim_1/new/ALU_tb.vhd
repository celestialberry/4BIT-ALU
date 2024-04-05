library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use ieee.NUMERIC_STD.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU_tb is
--  Port ( );
end ALU_tb;

architecture Behavioral of ALU_tb is
component ALU_4BIT is
    generic ( 
     constant N: natural := 8  -- number of shited or rotated bits
    );
    Port ( clock_100Mhz , reset : in STD_LOGIC;-- 100Mhz clock on Nexys-4-DDR FPGA board
               input_1, input_2,operation : in STD_LOGIC_VECTOR (3 downto 0);-- 4 input signals
               Anode_Activate : out STD_LOGIC_VECTOR (N-1 downto 0);-- 8 Anode signals
               LED_out : out STD_LOGIC_VECTOR (6 downto 0)
        );
end component;

signal clock: STD_LOGIC;
signal reset_tb: STD_LOGIC := '0';
signal input_1_tb: STD_LOGIC_VECTOR (3 downto 0) := "0000";
signal input_2_tb: STD_LOGIC_VECTOR (3 downto 0) := "0000";
signal operation_tb: STD_LOGIC_VECTOR (3 downto 0) := "0000";
signal Anode_Activate_tb: STD_LOGIC_VECTOR (7 downto 0);
signal LED_out_tb: STD_LOGIC_VECTOR (6 downto 0);
constant N_tb: natural := 8;
begin

uut: entity work.ALU_4BIT(Behavioral)
    generic map(N => N_tb)
    port map(
         clock_100Mhz => clock,
         reset => reset_tb,
         input_1 => input_1_tb,
         input_2 => input_2_tb,
         operation => operation_tb,
         Anode_Activate => Anode_Activate_tb,
         LED_out => LED_out_tb
         );

clk_process: process
begin
        clock <= '0';
        wait for 10 ns; 
        clock <= '1';
        wait for 10 ns;
end process;

input_process: process
begin
    for i in 0 to 1 loop
        for j in 0 to 15 loop 
            for k in 0 to 15 loop
                for m in 0 to 15 loop
                wait for 20 ms;
                input_2_tb<= (input_2_tb + '1'); 
        end loop;
                wait for 20 ms;  
                input_1_tb <= (input_1_tb + '1');    
        end loop;
                wait for 20 ms;
                operation_tb <= (operation_tb + '1');
        end loop;
                wait for 20 ms;
                reset_tb <= (reset_tb xor '1');                                                                 
       end loop;
                wait for 10 ms;
end process;
end Behavioral;