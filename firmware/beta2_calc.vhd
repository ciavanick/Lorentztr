----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/29/2024 12:54:44 PM
-- Design Name: 
-- Module Name: beta2_calc - Behavioral
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

entity beta2_calc is
    generic( msb : integer := 39; --number of bit
             lsb : integer := 0); --Mass of the particle
    Port ( clk : in STD_LOGIC;
           reset : in std_logic;
           betax : in signed(msb downto lsb);
           betay : in signed(msb downto lsb);
           betaz : in signed(msb downto lsb);
           beta2 : out signed(msb downto lsb)  
          );
end beta2_calc;

architecture Behavioral of beta2_calc is
signal betaxxbetax, betayxbetay, betazxbetaz, sumbeta : signed(2*msb+1 downto lsb) :=  x"00000000000011111111";
signal betaxxbetax_std, betayxbetay_std, betazxbetaz_std : STD_LOGIC_VECTOR(2*msb+1 downto lsb) :=  x"00000000000011111111";
signal beta2temp : signed(2*msb+1-20 downto lsb) := "0000" & x"000000000F99E9"; --x,y,z, and squared components of the relativistic velocities of the particle pair system
signal betax_std, betay_std, betaz_std  : std_logic_vector(msb downto lsb) :=  x"0000011111";
signal zero : signed(2*msb+1-20 downto lsb) := (others=>'0');

    COMPONENT mult_gen_0
      PORT (
        CLK : IN STD_LOGIC;
        A : IN STD_LOGIC_VECTOR(39 DOWNTO 0);
        B : IN STD_LOGIC_VECTOR(39 DOWNTO 0);
        P : OUT STD_LOGIC_VECTOR(79 DOWNTO 0)
      );
    END COMPONENT;

begin
    betax2 : mult_gen_0
    PORT MAP (
      CLK => clk,
      A => betax_std,
      B => betax_std,
      P => betaxxbetax_std
    );
    betay2 : mult_gen_0
    PORT MAP (
      CLK => clk,
      A => betay_std,
      B => betay_std,
      P => betayxbetay_std
    );
    betaz2 : mult_gen_0
    PORT MAP (
      CLK => clk,
      A => betaz_std,
      B => betaz_std,
      P => betazxbetaz_std
    );

    process(clk)
        begin
    
        if(reset = '1') then
--            betaxxbetax <= x"00000000000011111111";
--            betayxbetay <= x"00000000000011111111";
--            betazxbetaz <= x"00000000000011111111";
            beta2temp <= "0000" & x"000000000F99E9";
            -------------output---------------------
            beta2 <= x"0000011111";
        else
        if(rising_edge(clk)) then
            betax_std <= std_logic_vector(betax);
            betay_std <= std_logic_vector(betay); 
            betaz_std <= std_logic_vector(betaz); 
        
            betaxxbetax <= signed(betaxxbetax_std);
            betayxbetay <= signed(betayxbetay_std);
            betazxbetaz <= signed(betazxbetaz_std);
            sumbeta <= betaxxbetax + betayxbetay +betazxbetaz;
            beta2temp <= sumbeta(2*msb+1 downto lsb+20); --optimization of the divsion by constant
            if(beta2temp = zero) then
                beta2 <= x"0000011111";
            else
                beta2 <= beta2temp(msb downto lsb);
            end if;
        end if;
        end if;
        end process;

end Behavioral;
