----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/29/2024 11:13:45 AM
-- Design Name: 
-- Module Name: fP_out_calc - Behavioral
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

entity fP_out_calc is
    generic( msb : integer := 39; --number of bit
             lsb : integer := 0); --Mass of the particle
    Port ( clk : in STD_LOGIC;
           reset : in std_logic; 
           fP_in : in signed(msb downto lsb);
           gamma : in signed(msb downto lsb);
           energy : in signed(msb downto lsb);
           beta : in signed(msb downto lsb);
           gammaminusbeta : in signed(msb downto lsb);
           scaleoverbeta : in signed(msb downto lsb);
           fP_out : out signed(msb downto lsb)  
          );
end fP_out_calc;

architecture Behavioral of fP_out_calc is
signal gammabetaenergytemp : signed(3*msb+2 downto lsb) := x"000000000000000000000000011111"; --support scaling signals    
signal gammabetaenergysup, betweensup : signed(2*msb+1 downto lsb) := x"00000000000011111111";
signal gammabetaenergy, between : signed(msb downto lsb) := x"0000011111"; --support scaling signals for the final equation (x component, first particle)
signal betweentemp, betweeny_1ytemp, betweenz_1ztemp : signed(3*msb+2 downto lsb) := x"000000000000000000000000011111"; --support scaling signals 

begin
        process(clk)
        begin
    
        if(reset = '1') then
            gammabetaenergysup <= x"00000000000011111111";
            betweensup <= x"00000000000011111111";
            gammabetaenergy <= x"0000011111";
            between <= x"0000011111";
            ------------------output-------------------------------
            fP_out <= x"0000011111";
        else
        if(rising_edge(clk)) then
            gammabetaenergytemp <= (gamma*beta*energy);
            gammabetaenergysup <= gammabetaenergytemp(3*msb+2 downto lsb+msb+1);
            gammabetaenergy <= gammabetaenergysup(msb downto lsb);
            betweentemp <= (gammaminusbeta*beta*scaleoverbeta);
            betweensup <= betweentemp(3*msb+2 downto lsb+msb+1);
            between <= betweensup(msb downto lsb);
            fP_out <= fP_in + between - gammabetaenergy;
        end if;
        end if;
        end process;

end Behavioral;
