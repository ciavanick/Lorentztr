----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2024 11:34:40 AM
-- Design Name: 
-- Module Name: lorentztr - Behavioral
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

entity lorentztr is
    generic( msb : integer := 39; --number of bit
             lsb : integer := 0;
             consta : signed(39 downto 0) := x"0000100000"; --constant, is = 2^20 (so 2^(msb+1)/2)
             squared_const : signed(23 downto 0) := x"000400";
             fPrMass : signed(39 downto 0) := x"00000F0329"); --Mass of the particle
    Port ( clk_250 : in STD_LOGIC;
           fP1_fPx_in : in signed(msb downto lsb);  --initial input for x momentum for the first particle
           fP1_fPy_in : in signed(msb downto lsb);  --initial input for y momentum for the first particle
           fP1_fPz_in : in signed(msb downto lsb);  --initial input for z momentum for the first particle
           fP2_fPx_in : in signed(msb downto lsb);  --initial input for x momentum for the second particle
           fP2_fPy_in : in signed(msb downto lsb);  --initial input for y momentum for the second particle
           fP2_fPz_in : in signed(msb downto lsb);  --initial input for z momentum for the second particle 
           fP1_fPx_out : out signed(msb downto lsb); --final input for x momentum for the first particle 
           fP1_fPy_out : out signed(msb downto lsb); --final input for y momentum for the first particle 
           fP1_fPz_out : out signed(msb downto lsb); --final input for z momentum for the first particle 
           fP2_fPx_out : out signed(msb downto lsb); --final input for x momentum for the second particle
           fP2_fPy_out : out signed(msb downto lsb); --final input for y momentum for the second particle
           fP2_fPz_out : out signed(msb downto lsb)  --final input for z momentum for the second particle
          );
end lorentztr;

architecture Behavioral of lorentztr is
        signal fP1_fPx, fP1_fPy, fP1_fPz : signed(msb downto lsb) :=  x"0000011111"; --initial x,y,z momentum for the first particle
                   
        signal fP2_fPx, fP2_fPy, fP2_fPz : signed(msb downto lsb) :=  x"0000011111"; --initial x,y,z momentum for the second particle
                   
        signal fPtot_fPx, fPtot_fPy, fPtot_fPz : signed(msb downto lsb) :=  x"0000011111";           
        
        signal energy1, energy2 : signed(msb downto lsb) := x"0000011111"; --energy of respectively the first and secondo particle
        
        signal energytot : signed(msb downto lsb) := x"0000011111"; --total energy of the particle pair system
        
        signal betax, betay, betaz, beta2 : signed(msb downto lsb) := x"0000011111"; --x,y,z, and squared components of the relativistic velocities of the particle pair system
        signal betaxtemp, betaytemp, betaztemp, beta2temp : signed(2*msb+1 downto lsb) := x"00000000000000011111"; --x,y,z, and squared components of the relativistic velocities of the particle pair system
        
        signal gamma : signed(msb downto lsb) := x"0000011111"; --lorentz gamma
        signal gammatemp : signed(63 downto 0) := x"0000000000011111"; --lorentz gamma
        
        signal scale1, scale2 : signed(msb downto lsb) := (others=>'1'); --support scaling signals, scale1 is for fPr1, while scale2 is for fPr2
        signal scale1temp, scale2temp : signed(2*msb+1 downto lsb) := x"00000000000000011111"; --support scaling signals, scale1 is for fPr1, while scale2 is for fPr2
        
        signal gammaminusbeta : signed(msb downto lsb) := (others=>'1'); --support signal, represnt constant - gamma
        
        signal scaleoverbeta1_1x, gammabetaxenergy1_1x, betweenx_1x : signed(msb downto lsb) := x"0000011111"; --support scaling signals for the final equation (x component, first particle)
        signal scaleoverbeta1_1y, gammabetayenergy1_1y, betweeny_1y : signed(msb downto lsb) := x"0000011111"; --support scaling signals for the final equation (y component, first particle)
        signal scaleoverbeta1_1z, gammabetazenergy1_1z, betweenz_1z : signed(msb downto lsb) := x"0000011111"; --support scaling signals for the final equation (z component, first particle)
        
        signal scaleoverbeta1_1xtemp, scaleoverbeta1_1ytemp, scaleoverbeta1_1ztemp : signed(2*msb+1 downto lsb) := x"00000000000000011111"; --support scaling signals
        signal gammabetaxenergy1_1xtemp, gammabetayenergy1_1ytemp, gammabetazenergy1_1ztemp : signed(3*msb+2 downto lsb) := x"000000000000000000000000011111"; --support scaling signals    
        signal betweenx_1xtemp, betweeny_1ytemp, betweenz_1ztemp : signed(3*msb+2 downto lsb) := x"000000000000000000000000011111"; --support scaling signals 
        
        
        signal scaleoverbeta2_2x, gammabetaxenergy2_2x, betweenx_2x : signed(msb downto lsb) := x"0000011111"; --support scaling signals for the final equation (x component, second particle)
        signal scaleoverbeta2_2y, gammabetayenergy2_2y, betweeny_2y : signed(msb downto lsb) := x"0000011111"; --support scaling signals for the final equation (y component, second particle)
        signal scaleoverbeta2_2z, gammabetazenergy2_2z, betweenz_2z : signed(msb downto lsb) := x"0000011111"; --support scaling signals for the final equation (z component, second particle)
        
        signal scaleoverbeta2_2xtemp, scaleoverbeta2_2ytemp, scaleoverbeta2_2ztemp : signed(2*msb+1 downto lsb) := x"00000000000000011111"; --support scaling signals  
        signal gammabetaxenergy2_2xtemp, gammabetayenergy2_2ytemp, gammabetazenergy2_2ztemp : signed(3*msb+2 downto lsb) := x"000000000000000000000000011111"; --support scaling signals          
        signal betweenx_2xtemp, betweeny_2ytemp, betweenz_2ztemp : signed(3*msb+2 downto lsb) := x"000000000000000000000000011111"; --support scaling signals 
        
        
        signal reset : std_logic := '0';
        
        signal valid_in_e1, valid_out_e1 : STD_LOGIC := '1';
        signal valid_in_e2, valid_out_e2 : STD_LOGIC := '1';
        signal valid_in_gamma, valid_out_gamma : STD_LOGIC := '1';
        
        signal casting_in_e1  : STD_LOGIC_VECTOR(39 DOWNTO 0) := x"0000011111";
        signal casting_out_e1 : signed(47 DOWNTO 0) := x"000000011111";
        signal casting_out_e1_exit : STD_LOGIC_VECTOR(23 DOWNTO 0) := (others=>'1');
        signal sqrt_out_e1 : signed(23 DOWNTO 0) := (others=>'1');
        
        signal casting_in_e2 : STD_LOGIC_VECTOR(39 DOWNTO 0) := x"0000011111";
        signal casting_out_e2 : signed(47 DOWNTO 0) := x"000000011111";
        signal casting_out_e2_exit : STD_LOGIC_VECTOR(23 DOWNTO 0) := (others=>'1');
        signal sqrt_out_e2 : signed(23 DOWNTO 0) := (others=>'1');
        
        signal casting_in_gamma : STD_LOGIC_VECTOR(39 DOWNTO 0) := x"0000011111";
        signal casting_out_gamma : STD_LOGIC_VECTOR(39 DOWNTO 0) := x"0000011111";
        signal casting_out_gamma_exit : STD_LOGIC_VECTOR(23 DOWNTO 0) := (others=>'1');
        signal sqrt_out_gamma : signed(23 DOWNTO 0) := (others=>'1');
        
        signal energy1_to_cast, energy2_to_cast, gamma_to_cast : signed(msb downto lsb) :=  x"0000011111";
        signal energy1_to_casttmp, energy2_to_casttmp : signed(2*msb+1 downto lsb) :=  x"00000000000000011111";
        signal energy1_casted, energy2_casted, gamma_casted : signed(msb downto lsb) :=  x"0000011111";
        
        
        
        signal and0 : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others=>'0');
        
        COMPONENT cordic_0
          PORT (
            aclk : IN STD_LOGIC;
            s_axis_cartesian_tvalid : IN STD_LOGIC;
            s_axis_cartesian_tdata : IN STD_LOGIC_VECTOR(39 DOWNTO 0);
            m_axis_dout_tvalid : OUT STD_LOGIC;
            m_axis_dout_tdata : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
          );
        END COMPONENT;
        
        
begin      --b <= "0000" & a;
    sqrt_energy1 : cordic_0
        PORT MAP (
          aclk => clk_250,
          s_axis_cartesian_tvalid => valid_in_e1,
          s_axis_cartesian_tdata => casting_in_e1,
          m_axis_dout_tvalid => valid_out_e1,
          m_axis_dout_tdata => casting_out_e1_exit
        );
    sqrt_energy2 : cordic_0
        PORT MAP (
          aclk => clk_250,
          s_axis_cartesian_tvalid => valid_in_e2,
          s_axis_cartesian_tdata => casting_in_e2,
          m_axis_dout_tvalid => valid_out_e2,
          m_axis_dout_tdata => casting_out_e2_exit
        );
     sqrt_gamma : cordic_0
        PORT MAP (
          aclk => clk_250,
          s_axis_cartesian_tvalid => valid_in_gamma,
          s_axis_cartesian_tdata => casting_in_gamma,
          m_axis_dout_tvalid => valid_out_gamma,
          m_axis_dout_tdata => casting_out_gamma_exit
        );
       
       --assignment of the inputs
       fP1_fPx <= fP1_fPx_in;
       fP1_fPy <= fP1_fPy_in;
       fP1_fPz <= fP1_fPz_in;
       fP2_fPx <= fP2_fPx_in;
       fP2_fPy <= fP2_fPy_in;
       fP2_fPz <= fP2_fPz_in;
       
    process(clk_250)
    begin
    
        if(reset = '1') then
        
        elsif(rising_edge(clk_250)) then
            
            
            energy1_to_casttmp <= (fP1_fPx*fP1_fPx + fP1_fPy*fP1_fPy + fP1_fPz*fP1_fPz + fPrMass*fPrMass)/consta;
            energy1_to_cast <= energy1_to_casttmp(msb downto lsb);
            energy2_to_casttmp <= (fP2_fPx*fP2_fPx + fP2_fPy*fP2_fPy + fP2_fPz*fP2_fPz + fPrMass*fPrMass)/consta;
            energy2_to_cast <= energy2_to_casttmp(msb downto lsb);
            --sqrt energy1
            ----------------------------------------------------------
            casting_in_e1 <= std_logic_vector(energy1_to_cast);
            if(valid_out_e1 = '1') then
                sqrt_out_e1 <= signed(casting_out_e1_exit);
                casting_out_e1 <= squared_const*sqrt_out_e1;
                energy1_casted <= casting_out_e1(msb downto lsb);
            else
                energy1_casted <= x"0000011111";
            end if;
            
            --break the code if this value enter, to delete
            -- Remember to put in the txt file this hexa value as token
            if(fP1_fPx /= x"8000000"  or fP1_fPy /= x"8000000" or fP1_fPz /= x"8000000" or fP2_fPx /= x"8000000"  or fP2_fPy /= x"8000000" or fP2_fPz /= x"8000000") then
                valid_in_e1 <= '1';
            else
                valid_in_e1 <= '0';
            end if;
            energy1 <= energy1_casted;
            
            --sqrt energy2
            ------------------------------------------------------------
            casting_in_e2 <= std_logic_vector(energy2_to_cast);
            if(valid_out_e2 = '1') then
                sqrt_out_e2 <= signed(casting_out_e2_exit);
                casting_out_e2 <= squared_const*sqrt_out_e2;
                energy2_casted <= casting_out_e2(msb downto lsb);
            else
                energy2_casted <= x"0000011111";
            end if;
            
            --break the code if this value enter, to delete
            -- Remember to put in the txt file this hexa value as token
            if(fP1_fPx /= x"8000000"  or fP1_fPy /= x"8000000" or fP1_fPz /= x"8000000" or fP2_fPx /= x"8000000"  or fP2_fPy /= x"8000000" or fP2_fPz /= x"8000000") then
                valid_in_e2 <= '1';
            else
                valid_in_e2 <= '0';
            end if;
            energy2 <= energy2_casted;
            ------------------------------------------------------------
            
            
            --sum of the 3 momentum components
            fPtot_fPx <= fP1_fPx + fP2_fPx;
            fPtot_fPy <= fP1_fPy + fP2_fPy;
            fPtot_fPz <= fP1_fPz + fP2_fPz;
            
            energytot <= energy1 + energy2;
            
            betaxtemp <= (fPtot_fPx * consta)/energytot;
            betaytemp <= (fPtot_fPy * consta)/energytot;
            betaztemp <= (fPtot_fPz * consta)/energytot;
            
            betax <= betaxtemp(39 downto 0);
            betay <= betaytemp(39 downto 0);
            betaz <= betaztemp(39 downto 0);
            
            
            beta2temp <= (betax*betax + betay*betay + betaz*betaz)/consta;
            beta2 <= beta2temp(msb downto lsb);
            gamma_to_cast <= consta - beta2;
            
            --sqrt gamma
            ----------------------------------------------------------
            casting_in_gamma <= std_logic_vector(gamma_to_cast);
            if(valid_out_gamma = '1') then
                casting_out_gamma <= and0 & casting_out_gamma_exit;
                gamma_casted <= signed(casting_out_gamma);
            else
                gamma_casted <= x"0000011111";
            end if;
            
            --break the code if this value enter, to delete
            -- Remember to put in the txt file this hexa value as token
            if(fP1_fPx /= x"8000000"  or fP1_fPy /= x"8000000" or fP1_fPz /= x"8000000" or fP2_fPx /= x"8000000"  or fP2_fPy /= x"8000000" or fP2_fPz /= x"8000000") then
                valid_in_gamma <= '1';
            else
                valid_in_gamma <= '0';
            end if;
            
            gammatemp <= (squared_const*consta)/gamma_casted; --how does it hands the division by 0?
            gamma <= gammatemp(msb downto lsb);
            
            --scale1 and scale 2 definition
            scale1temp <= (betax*fP1_fPx + betay*fP1_fPy + betaz*fP1_fPz)/consta;
            scale2temp <= (betax*fP2_fPx + betay*fP2_fPy + betaz*fP2_fPz)/consta;

            scale1 <=  scale1temp(msb downto lsb);
            scale2 <=  scale2temp(msb downto lsb);

            gammaminusbeta <= gamma - consta;

            --Lorentz transformation of fP1_fPx
            scaleoverbeta1_1xtemp <= scale1*consta/beta2;
            scaleoverbeta1_1x <= scaleoverbeta1_1xtemp(msb downto lsb);
            gammabetaxenergy1_1xtemp <= (gamma*betax*energy1)/(consta*consta);
            gammabetaxenergy1_1x <= gammabetaxenergy1_1xtemp(msb downto lsb);
            betweenx_1xtemp <= (gammaminusbeta*betax*scaleoverbeta1_1x)/(consta*consta);
            betweenx_1x <= betweenx_1xtemp(msb downto lsb);
            fP1_fPx_out <= fP1_fPx + betweenx_1x - gammabetaxenergy1_1x;

            --Lorentz transformation of fP1_fPy
            scaleoverbeta1_1ytemp <= scale1*consta/beta2;
            scaleoverbeta1_1y <= scaleoverbeta1_1ytemp(msb downto lsb);
            gammabetayenergy1_1ytemp <= (gamma*betay*energy1)/(consta*consta);
            gammabetayenergy1_1y <= gammabetayenergy1_1ytemp(msb downto lsb);
            betweeny_1ytemp <= (gammaminusbeta*betay*scaleoverbeta1_1y)/(consta*consta);
            betweeny_1y <= betweeny_1ytemp(msb downto lsb);
            fP1_fPy_out <= fP1_fPy + betweeny_1y - gammabetayenergy1_1y;

            --Lorentz transformation of fP1_fPz
            scaleoverbeta1_1ztemp <= scale1*consta/beta2;
            scaleoverbeta1_1z <= scaleoverbeta1_1ztemp(msb downto lsb);
            gammabetazenergy1_1ztemp <= (gamma*betaz*energy1)/(consta*consta);
            gammabetazenergy1_1z <= gammabetazenergy1_1ztemp(msb downto lsb);
            betweenz_1ztemp <= (gammaminusbeta*betaz*scaleoverbeta1_1z)/(consta*consta);
            betweenz_1z <= betweenz_1ztemp(msb downto lsb);
            fP1_fPz_out <= fP1_fPz + betweenz_1z - gammabetazenergy1_1z;

            --Lorentz transformation of fP2_fPx
            scaleoverbeta2_2xtemp <= scale2*consta/beta2;
            scaleoverbeta2_2x <= scaleoverbeta2_2xtemp(msb downto lsb);
            gammabetaxenergy2_2xtemp <= (gamma*betax*energy2)/(consta*consta);
            gammabetaxenergy2_2x <= gammabetaxenergy2_2xtemp(msb downto lsb);
            betweenx_2xtemp <= (gammaminusbeta*betax*scaleoverbeta2_2x)/(consta*consta);
            betweenx_2x <= betweenx_2xtemp(msb downto lsb);
            fP2_fPx_out <= fP2_fPx + betweenx_2x - gammabetaxenergy2_2x;

            --Lorentz transformation of fP2_fPy
            scaleoverbeta2_2ytemp <= scale2*consta/beta2;
            scaleoverbeta2_2y <= scaleoverbeta2_2ytemp(msb downto lsb);
            gammabetayenergy2_2ytemp <= (gamma*betay*energy2)/(consta*consta);
            gammabetayenergy2_2y <= gammabetayenergy2_2ytemp(msb downto lsb);
            betweeny_2ytemp <= (gammaminusbeta*betay*scaleoverbeta2_2y)/(consta*consta);
            betweeny_2y <= betweeny_2ytemp(msb downto lsb);
            fP2_fPy_out <= fP2_fPy + betweeny_2y - gammabetayenergy2_2y;

            --Lorentz transformation of fP2_fPz
            scaleoverbeta2_2ztemp <= scale2*consta/beta2;
            scaleoverbeta2_2z <= scaleoverbeta2_2ztemp(msb downto lsb);
            gammabetazenergy2_2ztemp <= (gamma*betaz*energy2)/(consta*consta);
            gammabetazenergy2_2z <= gammabetazenergy2_2ztemp(msb downto lsb);
            betweenz_2ztemp <= (gammaminusbeta*betaz*scaleoverbeta2_2z)/(consta*consta);
            betweenz_2z <= betweenz_2ztemp(msb downto lsb);
            fP2_fPz_out <= fP2_fPz + betweenz_2z - gammabetazenergy2_2z;
            
        end if;
    end process;
end Behavioral;