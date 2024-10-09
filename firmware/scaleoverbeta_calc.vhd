----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/29/2024 10:50:14 AM
-- Design Name: 
-- Module Name: scaleoverbeta_calc - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity scaleoverbeta_calc is
    generic( msb : integer := 39; --number of bit
             lsb : integer := 0); --Mass of the particle
    Port ( clk : in STD_LOGIC;
           reset : in std_logic; 
           scale : in signed(msb downto lsb);
           beta2 : in signed(msb downto lsb);
           scaleoverbeta : out signed(msb downto lsb)
          );
end scaleoverbeta_calc;

architecture Behavioral of scaleoverbeta_calc is
signal scaleoverbetatemp, scaleconsta : signed(2*msb+1-20 downto lsb) := x"000000000011111";
begin
    process(clk)
        begin
    
        if(reset = '1') then
            scaleoverbetatemp <= x"000000000011111";
            scaleconsta <= x"000000000011111";
            -----------------output----------------------
            scaleoverbeta <= x"0000011111";
        else
        if(rising_edge(clk)) then
            scaleconsta <= scale & "00000000000000000000";
            scaleoverbetatemp <= scaleconsta/beta2;
            scaleoverbeta <= scaleoverbetatemp(msb downto lsb);
        end if;
        end if;
        end process;

end Behavioral;
