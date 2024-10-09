----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/29/2024 10:24:07 AM
-- Design Name: 
-- Module Name: scale_calc - Behavioral
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

entity scale_calc is
    generic( msb : integer := 39; --number of bit
             lsb : integer := 0); --Mass of the particle
    Port ( clk : in STD_LOGIC;
           reset : in std_logic; 
           fPx : in signed(msb downto lsb);
           fPy : in signed(msb downto lsb);
           fPz : in signed(msb downto lsb);
           betax : in signed(msb downto lsb);
           betay : in signed(msb downto lsb);
           betaz : in signed(msb downto lsb);
           scale : out signed(msb downto lsb)  
          );
end scale_calc;

architecture Behavioral of scale_calc is
signal betax_std, betay_std, betaz_std, fPx_std, fPy_std, fPz_std : std_logic_vector(msb downto lsb) :=  x"0000011111";
signal betaxfPx, betayfPy, betazfPz, sumbeta : signed(2*msb+1 downto lsb) :=  x"00000000000011111111"; 
signal betaxfPx_std, betayfPy_std, betazfPz_std : std_logic_vector(2*msb+1 downto lsb) :=  x"00000000000011111111"; 
signal scaletemp : signed(2*msb+1-20 downto lsb) := "0000" & x"000000000F99E9"; --support scaling signals, scale is for fPr

    COMPONENT mult_gen_0
      PORT (
        CLK : IN STD_LOGIC;
        A : IN STD_LOGIC_VECTOR(39 DOWNTO 0);
        B : IN STD_LOGIC_VECTOR(39 DOWNTO 0);
        P : OUT STD_LOGIC_VECTOR(79 DOWNTO 0)
      );
    END COMPONENT;

begin
    betaxfPxcalc : mult_gen_0
    PORT MAP (
      CLK => clk,
      A => betax_std,
      B => fPx_std,
      P => betaxfPx_std
    );
    betayfPycalc : mult_gen_0
    PORT MAP (
      CLK => clk,
      A => betay_std,
      B => fPy_std,
      P => betayfPy_std
    );
    betazfPzcalc : mult_gen_0
    PORT MAP (
      CLK => clk,
      A => betaz_std,
      B => fPz_std,
      P => betazfPz_std
    );
    process(clk)
        begin
    
        if(reset = '1') then
            betaxfPx <= x"00000000000011111111";
            betayfPy <= x"00000000000011111111";
            betazfPz <= x"00000000000011111111";
            sumbeta <= x"00000000000011111111";
            scaletemp <= "0000" & x"000000000F99E9";
            ----------------output-------------------
            scale <= x"0000011111";
        else
        if(rising_edge(clk)) then
            betax_std <= std_logic_vector(betax);
            betay_std <= std_logic_vector(betay);
            betaz_std <= std_logic_vector(betaz);
            fPx_std <= std_logic_vector(fPx);
            fPy_std <= std_logic_vector(fPy);
            fPz_std <= std_logic_vector(fPz);
            
            
            betaxfPx <= signed(betaxfPx_std);
            betayfPy <= signed(betayfPy_std);
            betazfPz <= signed(betazfPz_std);
            
            sumbeta <= betaxfPx + betayfPy + betazfPz;
            scaletemp <= sumbeta(2*msb+1 downto lsb+20);
            scale <=  scaletemp(msb downto lsb);
        end if;
        end if;
        end process;

end Behavioral;
