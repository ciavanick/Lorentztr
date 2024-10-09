----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/22/2024 09:49:14 AM
-- Design Name: 
-- Module Name: kutfu - Behavioral
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
--arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity energy_sqaured_calc is
    generic( msb : integer := 39; --number of bit
             lsb : integer := 0;
             consta : signed(39 downto 0) := x"0000100000"; --constant, is = 2^20 (so 2^(msb+1)/2)
             squared_const : signed(23 downto 0) := x"000400";
             fPrMass : signed(39 downto 0) := x"00000F0329"); --Mass of the particle
    Port ( clk : in STD_LOGIC;
           reset : in std_logic; 
           fP1_fPx : in signed(msb downto lsb);  --initial input for x momentum for the particle
           fP1_fPy : in signed(msb downto lsb);  --initial input for y momentum for the particle
           fP1_fPz : in signed(msb downto lsb);  --initial input for z momentum for the particle
           energy1_to_cast : out signed(msb downto lsb) 
    );
end energy_sqaured_calc;

architecture Behavioral of energy_sqaured_calc is
signal energy1_to_cast_trunc : signed(2*msb+1 downto lsb) :=  x"0000000000F99E9F99E9";
signal energy1_to_casttmp : signed(2*msb+1-20 downto lsb) :=  "0000" & x"000000000F99E9";
signal fP1_fPxmult, fP1_fPymult, fP1_fPzmult, fPrMassmult : STD_LOGIC_VECTOR(2*msb+1 downto lsb) :=  x"0000000000F99E9F99E9"; --outpud as std_logic_vector
signal fP1_fPxmult_signed, fP1_fPymult_signed, fP1_fPzmult_signed, fPrMassmult_signed : signed(2*msb+1 downto lsb) :=  x"0000000000F99E9F99E9"; --output as signed
signal fP1_fPxstd, fP1_fPystd, fP1_fPzstd,fPrMassstd : std_logic_vector(msb downto lsb) :=  x"0000011111";
signal zero : signed(2*msb+1 downto lsb) := (others=>'0');
signal zerostd : std_logic_vector(2*msb+1 downto lsb) := (others=>'0');
--defining the multiplier
COMPONENT mult_gen_0
  PORT (
    CLK : IN STD_LOGIC;
    A : IN STD_LOGIC_VECTOR(39 DOWNTO 0);
    B : IN STD_LOGIC_VECTOR(39 DOWNTO 0);
    P : OUT STD_LOGIC_VECTOR(79 DOWNTO 0)
  );
END COMPONENT;




begin
        fP1_fPx2 : mult_gen_0
        PORT MAP (
          CLK => clk,
          A => fP1_fPxstd,
          B => fP1_fPxstd,
          P => fP1_fPxmult
        );
        
        fP1_fPy2 : mult_gen_0
        PORT MAP (
          CLK => clk,
          A => fP1_fPystd,
          B => fP1_fPystd,
          P => fP1_fPymult
        );
        
        fP1_fPz2 : mult_gen_0
        PORT MAP (
          CLK => clk,
          A => fP1_fPzstd,
          B => fP1_fPzstd,
          P => fP1_fPzmult
        );
        
        fPrMass2 : mult_gen_0
        PORT MAP (
          CLK => clk,
          A => fPrMassstd,
          B => fPrMassstd,
          P => fPrMassmult
        );
  
        process(clk)
        begin
    
        if(reset = '1') then
            energy1_to_cast_trunc <= x"0000000000F99E9F99E9";
            energy1_to_casttmp <= "0000" & x"000000000F99E9";
--            fP1_fPxmult <= x"0000000000F99E9F99E9";
--            fP1_fPymult <= x"0000000000F99E9F99E9";
--            fP1_fPzmult <= x"0000000000F99E9F99E9";
--            fPrMassmult <= x"0000000000F99E9F99E9";
            fP1_fPxmult_signed <= x"0000000000F99E9F99E9";
            fP1_fPymult_signed <= x"0000000000F99E9F99E9";
            fP1_fPzmult_signed <= x"0000000000F99E9F99E9";
            fPrMassmult_signed <= x"0000000000F99E9F99E9";
            fP1_fPxstd <= x"0000011111";
            fP1_fPystd <= x"0000011111";
            fP1_fPzstd <= x"0000011111";
            fPrMassstd <= x"0000011111";
            zero <= (others=>'0');
            ------------ouput----------------
            energy1_to_cast <= x"0000011111";
            
        else
        if(rising_edge(clk)) then
        
            fP1_fPxstd <= std_logic_vector(fP1_fPx);
            fP1_fPystd <= std_logic_vector(fP1_fPy);
            fP1_fPzstd <= std_logic_vector(fP1_fPz);
            fPrMassstd <= std_logic_vector(fPrMass);
            if(fPrMassmult = zerostd) then
                fPrMassmult_signed<= x"0000000000F99E9F99E9";
            else
                fPrMassmult_signed <= signed(fPrMassmult);
            end if;
            
            fP1_fPxmult_signed <= signed(fP1_fPxmult);
            fP1_fPymult_signed <= signed(fP1_fPymult);
            fP1_fPzmult_signed <= signed(fP1_fPzmult);
            
            
       
            energy1_to_cast_trunc <= (fP1_fPxmult_signed  + fP1_fPymult_signed  + fP1_fPzmult_signed  + fPrMassmult_signed);       
            energy1_to_casttmp <= energy1_to_cast_trunc(2*msb+1 downto lsb+20);
            energy1_to_cast <= energy1_to_casttmp(msb downto lsb);
        end if;
        end if;
        end process;
end Behavioral;