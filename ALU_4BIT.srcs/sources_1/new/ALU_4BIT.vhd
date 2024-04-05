library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use ieee.NUMERIC_STD.all;
entity ALU_4BIT is
    generic ( 
     constant N: natural := 8
    );
    Port ( clock_100Mhz , reset : in STD_LOGIC;-- 100Mhz clock on Nexys-4-DDR FPGA board
           input_1, input_2,operation : in STD_LOGIC_VECTOR (3 downto 0);-- 4 input signals
           Anode_Activate : out STD_LOGIC_VECTOR (N-1 downto 0);-- 8 Anode signals
           LED_out : out STD_LOGIC_VECTOR (6 downto 0)
    );
end ALU_4BIT;

architecture Behavioral of ALU_4BIT is

signal LED_BCD: STD_LOGIC_VECTOR (4 downto 0);
signal temp_inp1,temp_inp2,temp_output,output: STD_LOGIC_VECTOR (N-1 downto 0);
signal refresh_counter: STD_LOGIC_VECTOR (19 downto 0):="00000000000000000000";
signal ones : STD_LOGIC_VECTOR (3 downto 0):= "1111";
signal LED_activating_counter: std_logic_vector(2 downto 0);

begin
-- VHDL code for BCD to 7-segment decoder
-- Cathode patterns of the 7-segment LED display 
process(LED_BCD)
begin
    case LED_BCD is
    when "00000" => LED_out <= "1000000"; -- "0"     
    when "00001" => LED_out <= "1111001"; -- "1" 
    when "00010" => LED_out <= "0100100"; -- "2" 
    when "00011" => LED_out <= "0110000"; -- "3" 
    when "00100" => LED_out <= "0011001"; -- "4" 
    when "00101" => LED_out <= "0010010"; -- "5" 
    when "00110" => LED_out <= "0000010"; -- "6" 
    when "00111" => LED_out <= "1111000"; -- "7" 
    when "01000" => LED_out <= "0000000"; -- "8"     
    when "01001" => LED_out <= "0010000"; -- "9" 
    when "01010" => LED_out <= "0100000"; -- a
    when "01011" => LED_out <= "0000011"; -- b
    when "01100" => LED_out <= "1000110"; -- C
    when "01101" => LED_out <= "0100001"; -- d
    when "01110" => LED_out <= "0000110"; -- E
    when "01111" => LED_out <= "0001110"; -- F
    when others  => LED_out <= "1111111"; --null "LED_BCD whose MSB is 1 will be printed as null"
    end case;
end process;
-- 7-segment display controller
-- generate refresh period of 13.1082ms
process(clock_100Mhz,reset)
begin 
    if(reset='1') then
        refresh_counter <= (others => '0');
    elsif(rising_edge(clock_100Mhz)) then
        refresh_counter <= refresh_counter + 1;
    end if;
end process;
 LED_activating_counter <= refresh_counter(19 downto 17);--13.1082ms
-- 8-to-1 MUX to generate anode activating signals for 8 LEDs 
process(LED_activating_counter,input_1,input_2,output,ones)
begin
    case LED_activating_counter is
    when "000" =>
        Anode_Activate <= "11111111";
        LED_BCD <= "10000";
    when "001" =>
        Anode_Activate <= "11111110";
        LED_BCD <= ("0" & output(3 downto 0)); -- "0 &"  means this output will be printed on that seven segment
    when "010" =>
        Anode_Activate <= "11011111";
        LED_BCD <= ("0" & input_2); 
    when "011" =>
        Anode_Activate <= "01111111";
        LED_BCD <= ("0" & input_1); 
    when "100" =>
        Anode_Activate <= "11111101";
        if (output(7 downto 4)="0000") then
            LED_BCD <= ("1" & output(7 downto 4)); -- "1 &"  means null will be printed on that particular seven segment  
        else    
            LED_BCD <= ("0" & output(7 downto 4));  
        end if;   
    when others =>
        Anode_Activate <= "10100011"; 
        LED_BCD <= ("1" & ones); 
    end case;
end process;
-- Calculating the output to be displayed on 7-segment Display 
-- on Nexys-4-DDR FPGA board
process(clock_100Mhz,operation,temp_output,temp_inp1,temp_inp2,input_1,input_2)
begin
temp_inp1<="0000" & input_1;
temp_inp2<="0000" & input_2;
if(rising_edge(clock_100Mhz)) then
    case operation is
        when "0000"=> temp_output <="00000000";--nothing
        when "0001"=> temp_output <=temp_inp1 and temp_inp2;--and
        when "0010"=> temp_output <=temp_inp1 or temp_inp2;--or
        when "0011"=> temp_output <=temp_inp1 xor temp_inp2;--xor
        when "0100"=> temp_output <=("0000" & (temp_inp1(3 downto 0) nand temp_inp2(3 downto 0)));--nand
        when "0101"=> temp_output <=("0000" & (temp_inp1(3 downto 0) nor temp_inp2(3 downto 0)));--nor
        when "0110"=> temp_output <=temp_inp1 + temp_inp2;--add
        when "0111"=>--absolute subtraction
            if(temp_inp1>temp_inp2) then
                temp_output <= temp_inp1-temp_inp2;
            else
                temp_output <= temp_inp2-temp_inp1;
            end if;
        when "1000"=> temp_output <=std_logic_vector(to_unsigned(to_integer(unsigned(temp_inp1)) * to_integer(unsigned(temp_inp2)),N));--multiply
        when "1001"=> temp_output <=std_logic_vector(to_unsigned(to_integer(unsigned(temp_inp1)) / to_integer(unsigned(temp_inp2)),N));--divide
        when "1010"=> temp_output <=std_logic_vector(to_unsigned(to_integer(unsigned(temp_inp1)) rem to_integer(unsigned(temp_inp2)),N));--remainder
        when "1011"=> temp_output <=std_logic_vector(unsigned(temp_inp1) sll 1);--shift to left
        when "1100"=> temp_output <=std_logic_vector(unsigned(temp_inp1) srl 1);--shift to left
        when others => temp_output <= "00000000"; ---null
    end case;
end if;
output<=temp_output;
end process;
end Behavioral;