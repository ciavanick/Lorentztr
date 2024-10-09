----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/27/2024 04:35:56 PM
-- Design Name: 
-- Module Name: fPTot_const - Behavioral
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
--library UNISIM;
--use UNISIM.VComponents.all;

entity beta_calc is
    generic( msb : integer := 39; --number of bit
             lsb : integer := 0); --Mass of the particle
    Port ( clk : in STD_LOGIC;
           reset : in std_logic; 
           fPTot_fP : in signed(msb downto lsb);
           energytot : in signed(msb downto lsb);
           beta : out signed(msb downto lsb)
           );
end beta_calc;

architecture Behavioral of beta_calc is
signal fPtot_fPxconsta : signed(2*msb+1-20 downto lsb) :=  x"000000011111111";
signal betatemp : signed(2*msb+1-20 downto lsb) := x"000000000011111";
signal zero : signed(msb downto lsb) := (others=>'0');
 
begin
    process(clk)
        begin
    
        if(reset = '1') then
            fPtot_fPxconsta <= x"000000011111111";
            betatemp <= x"000000000011111";
            -------------------output------------------
            beta <= x"0000011111";
        else
        if(rising_edge(clk)) then
            fPtot_fPxconsta <= fPtot_fP & "00000000000000000000"; --to optimize -- a & "00000"
            --fPtot_fP(msb) & fPtot_fP(msb) & fPtot_fP(msb) & fPtot_fP(msb) & fPtot_fP(msb) & fPtot_fP(msb) & fPtot_fP(msb) & fPtot_fP(msb) & fPtot_fP(msb) & fPtot_fP(msb) & fPtot_fP(msb) & fPtot_fP(msb) & fPtot_fP(msb) & fPtot_fP(msb) & fPtot_fP(msb) & fPtot_fP(msb) & fPtot_fP(msb) & fPtot_fP(msb) & fPtot_fP(msb) & fPtot_fP(msb) &
            if(energytot = zero) then
                betatemp <= x"000000000011111";
            else
                betatemp <= fPtot_fPxconsta/energytot;
            end if;
            beta <= betatemp(msb downto lsb);
        end if;
        end if;
        end process;

end Behavioral;
