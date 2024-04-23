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
             const : signed(msb to lsb) := x"100000"; --constant, is = 2^20 (so 2^(msb+1)/2)
             squared_const : signed(msb to lsb) := x"400";
             fPrMass : signed(msb to lsb) := x"F0329"); --Mass of the particle
    Port ( clk_250 : in STD_LOGIC);
end lorentztr;

architecture Behavioral of lorentztr is
        signal fP1_fPx, fP1_fPy, fP1_fPz : signed(msb downto lsb) :=  (others=>'0'); --initial x,y,z momentum for the first particle
                   
        signal fP2_fPx, fP2_fPy, fP2_fPz : signed(msb downto lsb) :=  (others=>'0'); --initial x,y,z momentum for the second particle
                   
        signal fPtot_fPx, fPtot_fPy, fPtot_fPz : signed(msb downto lsb) :=  (others=>'0'); --total x,y,z momentum of the particles
        
        signal energy1, energy2 : signed(msb downto lsb) := (others=>'0'); --energy of respectively the first and secondo particle
        
        signal energytot : signed(msb downto lsb) := (others=>'0'); --total energy of the particle pair system
        
        signal betax, betay, betaz, beta2 : signed(msb downto lsb) := (others=>'0'); --x,y,z, and squared components of the relativistic velocities of the particle pair system
        
        signal gamma : signed(msb downto lsb) := (others=>'0'); --lorentz gamma
        
        signal scale1, scale2 : signed(msb downto lsb) := (others=>'0'); --support scaling signals, scale1 is for fPr1, while scale2 is for fPr2
        
        signal gammaminusbeta : signed(msb downto lsb) := (others=>'0'); --support signal, represnt constant - gamma
        
        signal scaleoverbeta1_1x, gammabetaxenergy1_1x, betweenx_1x : signed(msb downto lsb) := (others=>'0'); --support scaling signals for the final equation (x component, first particle)
        signal scaleoverbeta1_1y, gammabetayenergy1_1y, betweeny_1y : signed(msb downto lsb) := (others=>'0'); --support scaling signals for the final equation (y component, first particle)
        signal scaleoverbeta1_1z, gammabetazenergy1_1z, betweenz_1z : signed(msb downto lsb) := (others=>'0'); --support scaling signals for the final equation (z component, first particle)
      
        signal scaleoverbeta2_2x, gammabetaxenergy2_2x, betweenx_2x : signed(msb downto lsb) := (others=>'0'); --support scaling signals for the final equation (x component, second particle)
        signal scaleoverbeta2_2y, gammabetayenergy2_2y, betweeny_2y : signed(msb downto lsb) := (others=>'0'); --support scaling signals for the final equation (y component, second particle)
        signal scaleoverbeta2_2z, gammabetazenergy2_2z, betweenz_2z : signed(msb downto lsb) := (others=>'0'); --support scaling signals for the final equation (z component, second particle)
        
        
        signal fP1_fPx_out, fP1_fPy_out, fP1_fPz_out: signed(msb downto lsb) :=  (others=>'0'); --final x,y,z momentum for the first particle
                                           
        signal fP2_fPx_out, fP2_fPy_out, fP2_fPz_out : signed(msb downto lsb) :=  (others=>'0'); --final x,y,z momentum for the second particle
        
        signal reset : std_logic := '0';
        
        signal valid_in_e1, valid_out_e1 : STD_LOGIC := '0';
        signal valid_in_e2, valid_out_e2 : STD_LOGIC := '0';
        signal valid_in_gamma, valid_out_gamma : STD_LOGIC := '0';
        
        signal casting_in_e1, casting_out_e1 : STD_LOGIC_VECTOR(39 DOWNTO 0) := (others => '0');
        signal casting_in_e2, casting_out_e2 : STD_LOGIC_VECTOR(39 DOWNTO 0) := (others => '0');
        signal casting_in_gamma, casting_out_gamma : STD_LOGIC_VECTOR(39 DOWNTO 0) := (others => '0');
        
        signal energy1_to_cast, energy2_to_cast, gamma_to_cast : signed(2*msb+1 downto lsb) :=  (others=>'0');
        signal energy1_casted, energy2_casted, gamma_casted : signed(2*msb+1 downto lsb) :=  (others=>'0');
        
        COMPONENT cordic_0
          PORT (
            aclk : IN STD_LOGIC;
            s_axis_cartesian_tvalid : IN STD_LOGIC;
            s_axis_cartesian_tdata : IN STD_LOGIC_VECTOR(39 DOWNTO 0);
            m_axis_dout_tvalid : OUT STD_LOGIC;
            m_axis_dout_tdata : OUT STD_LOGIC_VECTOR(39 DOWNTO 0)
          );
        END COMPONENT;
        
        
begin
    sqrt_energy1 : cordic_0
        PORT MAP (
          aclk => clk_250,
          s_axis_cartesian_tvalid => valid_in_e1,
          s_axis_cartesian_tdata => casting_in_e1,
          m_axis_dout_tvalid => valid_out_e1,
          m_axis_dout_tdata => casting_out_e1
        );
    sqrt_energy2 : cordic_0
        PORT MAP (
          aclk => clk_250,
          s_axis_cartesian_tvalid => valid_in_e2,
          s_axis_cartesian_tdata => casting_in_e2,
          m_axis_dout_tvalid => valid_out_e2,
          m_axis_dout_tdata => casting_out_e2
        );
     sqrt_gamma : cordic_0
        PORT MAP (
          aclk => clk_250,
          s_axis_cartesian_tvalid => valid_in_gamma,
          s_axis_cartesian_tdata => casting_in_gamma,
          m_axis_dout_tvalid => valid_out_gamma,
          m_axis_dout_tdata => casting_out_gamma
        );
        
    process(clk_250)
    begin
        if(reset = '1') then
        
        elsif(rising_edge(clk_250)) then
        
            energy1_to_cast <= fP1_fPx*fP1_fPx + fP1_fPy*fP1_fPy + fP1_fPz*fP1_fPz + fPrMass*fPrMass;
            energy2_to_cast <= fP2_fPx*fP2_fPx + fP2_fPy*fP2_fPy + fP2_fPz*fP2_fPz + fPrMass*fPrMass;
            
            --sqrt energy1
            ----------------------------------------------------------
            casting_in_e1 <= std_logic_vector(energy1_to_cast);
            if(valid_out_e1 = '1') then
                energy1_casted <= signed(casting_out_e1);
            else
                energy1_casted <= x"0";
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
                energy2_casted <= signed(casting_out_e2);
            else
                energy2_casted <= x"0";
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
            
            betax <= (fPtot_fPx * const)/energytot;
            betay <= (fPtot_fPy * const)/energytot;
            betaz <= (fPtot_fPz * const)/energytot;
            beta2 <= (betax*betax + betay*betay + betaz*betaz);
            
            gamma_to_cast <= const - beta2;
            
            --sqrt gamma
            ----------------------------------------------------------
            casting_in_gamma <= std_logic_vector(gamma_to_cast);
            if(valid_out_gamma = '1') then
                gamma_casted <= signed(casting_out_gamma);
            else
                gamma_casted <= x"0";
            end if;
            
            --break the code if this value enter, to delete
            -- Remember to put in the txt file this hexa value as token
            if(fP1_fPx /= x"8000000"  or fP1_fPy /= x"8000000" or fP1_fPz /= x"8000000" or fP2_fPx /= x"8000000"  or fP2_fPy /= x"8000000" or fP2_fPz /= x"8000000") then
                valid_in_gamma <= '1';
            else
                valid_in_gamma <= '0';
            end if;
            
            gamma <= (squared_const*const)/gamma_casted; --how does it hands the division by 0?
            
            --scale1 and scale 2 definition
            scale1 <= (betax*fP1_fPx + betay*fP1_fPy + betaz*fP1_fPz)/const;
            scale2 <= (betax*fP2_fPx + betay*fP2_fPy + betaz*fP2_fPz)/const;

            gammaminusbeta <= gamma - const;

            --Lorentz transformation of fP1_fPx
            scaleoverbeta1_1x <= scale1*const/beta2;
            gammabetaxenergy1_1x <= (gamma*betax*energy1)/(const*const);
            betweenx_1x <= (gammaminusbeta*betax*scaleoverbeta1_1x)/(const*const);
            fP1_fPx_out <= fP1_fPx + betweenx_1x - gammabetaxenergy1_1x;

            --Lorentz transformation of fP1_fPy
            scaleoverbeta1_1y <= scale1*const/beta2;
            gammabetayenergy1_1y <= (gamma*betay*energy1)/(const*const);
            betweeny_1y <= (gammaminusbeta*betay*scaleoverbeta1_1y)/(const*const);
            fP1_fPy_out <= fP1_fPy + betweeny_1y - gammabetayenergy1_1y;

            --Lorentz transformation of fP1_fPz
            scaleoverbeta1_1z <= scale1*const/beta2;
            gammabetazenergy1_1z <= (gamma*betaz*energy1)/(const*const);
            betweenz_1z <= (gammaminusbeta*betaz*scaleoverbeta1_1z)/(const*const);
            fP1_fPz_out <= fP1_fPz + betweeny_1z - gammabetazenergy1_1z;

            --Lorentz transformation of fP2_fPx
            scaleoverbeta2_2x <= scale2*const/beta2;
            gammabetaxenergy2_2x <= (gamma*betax*energy2)/(const*const);
            betweenx_2x <= (gammaminusbeta*betax*scaleoverbeta2_2x)/(const*const);
            fP2_fPx_out <= fP2_fPx + betweenx_2x - gammabetaxenergy2_2x;

            --Lorentz transformation of fP2_fPy
            scaleoverbeta2_2y <= scale2*const/beta2;
            gammabetayenergy2_2y <= (gamma*betay*energy2)/(const*const);
            betweeny_2y <= (gammaminusbeta*betay*scaleoverbeta2_2y)/(const*const);
            fP2_fPy_out <= fP2_fPy + betweeny_2y - gammabetayenergy2_2y;

            --Lorentz transformation of fP2_fPz
            scaleoverbeta2_2z <= scale2*const/beta2;
            gammabetazenergy2_2z <= (gamma*betaz*energy2)/(const*const);
            betweenz_2z <= (gammaminusbeta*betaz*scaleoverbeta2_2z)/(const*const);
            fP2_fPz_out <= fP2_fPz + betweeny_2z - gammabetazenergy2_1z;
            
        end if;
    end process;
end Behavioral;
