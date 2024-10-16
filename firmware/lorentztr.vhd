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
             squared_const_times_const : signed(63 downto 0) := x"0000000040000000";
             fPrMass : signed(39 downto 0) := x"00000F0329"); --Mass of the particle
    Port ( clk_250 : in STD_LOGIC;
           reseth : in std_logic;
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
        signal fP1_fPx_std, fP1_fPy_std, fP1_fPz_std : std_logic_vector(msb downto lsb) :=  x"0000011111";
                   
        signal fP2_fPx, fP2_fPy, fP2_fPz : signed(msb downto lsb) :=  x"0000011111"; --initial x,y,z momentum for the second particle
                   
        signal fPtot_fPx, fPtot_fPy, fPtot_fPz : signed(msb downto lsb) :=  x"0000011111";           
        
        signal energy1, energy2 : signed(msb downto lsb) := x"0000011111"; --energy of respectively the first and secondo particle
        signal energy1_std, energy2_std : std_logic_vector(msb downto lsb) := x"0000011111";
        
        signal energytot : signed(msb downto lsb) := x"0000011111"; --total energy of the particle pair system
        
        signal betax, betay, betaz, beta2 : signed(msb downto lsb) := x"0000011111"; --x,y,z, and squared components of the relativistic velocities of the particle pair system
        
        
        signal gamma : signed(msb downto lsb) := x"0000011111"; --lorentz gamma
        signal gammatemp : signed(63 downto 0) := x"0000000000011111"; --lorentz gamma
        
        signal scale1, scale2 : signed(msb downto lsb) := (others=>'1'); --support scaling signals, scale1 is for fPr1, while scale2 is for fPr2
        signal scale1temp, scale2temp : signed(2*msb+1 downto lsb) := x"00000000000000011111"; --support scaling signals, scale1 is for fPr1, while scale2 is for fPr2
        
        signal gammaminusbeta : signed(msb downto lsb) := (others=>'1'); --support signal, represnt constant - gamma
        
        signal scaleoverbeta1 : signed(msb downto lsb) := x"0000011111";
        

        signal scaleoverbeta2 : signed(msb downto lsb) := x"0000011111";
          
        
        signal reset : std_logic := '1';
        
        signal valid_in_e1, valid_out_e1 : STD_LOGIC := '1';
        signal valid_in_e2, valid_out_e2 : STD_LOGIC := '1';
        signal valid_in_gamma, valid_out_gamma : STD_LOGIC := '1';
        
        signal casting_in_e1  : STD_LOGIC_VECTOR(39 DOWNTO 0) := x"0000011111";
        signal casting_out_e1 : signed(47 DOWNTO 0) := x"000000011111";
        signal casting_out_e1_exit : STD_LOGIC_VECTOR(23 DOWNTO 0) := (others=>'1');
        signal sqrt_out_e1 : signed(23 DOWNTO 0) := x"011111";
        
        signal casting_in_e2 : STD_LOGIC_VECTOR(39 DOWNTO 0) := x"0000011111";
        signal casting_out_e2 : signed(47 DOWNTO 0) := x"000000011111";
        signal casting_out_e2_exit : STD_LOGIC_VECTOR(23 DOWNTO 0) := (others=>'1');
        signal sqrt_out_e2 : signed(23 DOWNTO 0) := x"011111";
        
        signal casting_in_gamma : STD_LOGIC_VECTOR(39 DOWNTO 0) := x"0000011111";
        signal casting_out_gamma : STD_LOGIC_VECTOR(39 DOWNTO 0) := x"0000011111";
        signal casting_out_gamma_exit : STD_LOGIC_VECTOR(23 DOWNTO 0) := (others=>'1');
        signal sqrt_out_gamma : signed(23 DOWNTO 0) := (others=>'1');
        
        signal energy1_to_cast, energy2_to_cast, gamma_to_cast : signed(msb downto lsb) :=  x"0000011111";
        signal energy1_to_cast_trunc, energy2_to_cast_trunc: signed(2*msb+1 downto lsb) :=  x"0000000000F99E9F99E9";
        signal energy1_to_casttmp, energy2_to_casttmp : signed(2*msb+1-20 downto lsb) :=  "0000" & x"000000000F99E9";
        signal energy1_casted, energy2_casted, gamma_casted : signed(msb downto lsb) :=  x"0000011111";
        
        --some signals to optimze the code
        
       
        signal betaxfP2_fPx, betayfP2_fPy, betazfP2_fPz, sumbetafP2 : signed(2*msb+1 downto lsb) :=  x"00000000000011111111"; 
        
        
        
        
        signal and0 : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others=>'0');
        
        COMPONENT energy_sqaured_calc
         generic( 
           msb : integer := 39; --number of bit            
           lsb : integer := 0;
           consta : signed(39 downto 0) := x"0000100000"; --constant, is = 2^20 (so 2^(msb+1)/2)
           squared_const : signed(23 downto 0) := x"000400";
           fPrMass : signed(39 downto 0) := x"00000F0329"                         
           );
         PORT (
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           fP1_fPx : in signed(msb downto lsb);
           fP1_fPy : in signed(msb downto lsb);
           fP1_fPz : in signed(msb downto lsb);
           energy1_to_cast : out signed(msb downto lsb) 
         );
         END COMPONENT;
        
        COMPONENT cordic_0
          PORT (
            aclk : IN STD_LOGIC;
            s_axis_cartesian_tvalid : IN STD_LOGIC;
            s_axis_cartesian_tdata : IN STD_LOGIC_VECTOR(39 DOWNTO 0);
            m_axis_dout_tvalid : OUT STD_LOGIC;
            m_axis_dout_tdata : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
          );
        END COMPONENT;
        
        COMPONENT beta2_calc 
         generic( 
           msb : integer := 39; --number of bit            
           lsb : integer := 0                             
           );
         PORT (
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           betax : in signed(msb downto lsb);
           betay : in signed(msb downto lsb);
           betaz : in signed(msb downto lsb);
           beta2 : out signed(msb downto lsb)   
         );
         END COMPONENT;
        
        COMPONENT beta_calc 
         generic( 
           msb : integer := 39; --number of bit            
           lsb : integer := 0                             
           );
         PORT (
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           fPTot_fP : in signed(msb downto lsb);
           energytot : in signed(msb downto lsb);
           beta : out signed(msb downto lsb)  
         );
         END COMPONENT;
         
         COMPONENT scale_calc 
         generic( 
           msb : integer := 39; --number of bit            
           lsb : integer := 0                             
           );
         PORT (
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           fPx : in signed(msb downto lsb);
           fPy : in signed(msb downto lsb);
           fPz : in signed(msb downto lsb);
           betax : in signed(msb downto lsb);
           betay : in signed(msb downto lsb);
           betaz : in signed(msb downto lsb);
           scale : out signed(msb downto lsb)  
         );
         END COMPONENT;
         
         COMPONENT scaleoverbeta_calc 
         generic( 
           msb : integer := 39; --number of bit            
           lsb : integer := 0                             
           );
         PORT (
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           scale : in signed(msb downto lsb);
           beta2 : in signed(msb downto lsb);
           scaleoverbeta : out signed(msb downto lsb) 
         );
         END COMPONENT;
         
         COMPONENT fP_out_calc 
         generic( 
           msb : integer := 39; --number of bit            
           lsb : integer := 0                             
           );
         PORT (
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           fP_in : in signed(msb downto lsb);
           gamma : in signed(msb downto lsb);
           energy : in signed(msb downto lsb);
           beta : in signed(msb downto lsb);
           gammaminusbeta : in signed(msb downto lsb);
           scaleoverbeta : in signed(msb downto lsb);
           fP_out : out signed(msb downto lsb) 
         );
         END COMPONENT;
        
        
    COMPONENT ila_0
    PORT (
    	clk : IN STD_LOGIC;
    
    
    
    	probe0 : IN STD_LOGIC_VECTOR(39 DOWNTO 0);
    	probe1 : IN STD_LOGIC_VECTOR(39 DOWNTO 0)
    );
    END COMPONENT  ;
        
        
begin      --b <= "0000" & a;
    
       ----------------------------------------------
       ----------------------------------------------
       --energy1_to_cast calculation
       e1_to_cast : energy_sqaured_calc
       GENERIC MAP(
          msb => msb,
          lsb => lsb,
          consta => consta, --constant, is = 2^20 (so 2^(msb+1)/2)
          squared_const => squared_const,
          fPrMass =>  fPrMass             
        )
        PORT MAP (
          clk => clk_250,
          reset => reset,
          fP1_fPx => fP1_fPx,
          fP1_fPy => fP1_fPy,
          fP1_fPz => fP1_fPz,
          energy1_to_cast => energy1_to_cast
        );
        --energy2_to_cast calculation
       e2_to_cast : energy_sqaured_calc
       GENERIC MAP(
          msb => msb,
          lsb => lsb,
          consta => consta, --constant, is = 2^20 (so 2^(msb+1)/2)
          squared_const => squared_const,
          fPrMass =>  fPrMass                       
        )
        PORT MAP (
          clk => clk_250,
          reset => reset,
          fP1_fPx => fP2_fPx,
          fP1_fPy => fP2_fPy,
          fP1_fPz => fP2_fPz,
          energy1_to_cast => energy2_to_cast
        );


       ----------------------------------------------
       ----------------------------------------------
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
       ----------------------------------------------
       ----------------------------------------------
       --beta2 calculation
       beta2calc : beta2_calc
       GENERIC MAP(
          msb => msb,
          lsb => lsb                      
        )
        PORT MAP (
          clk => clk_250,
          reset => reset,
          betax  => betax,
          betay  => betay,
          betaz  => betaz,
          beta2  => beta2
        );
       ----------------------------------------------
       ----------------------------------------------
       --calculation of betax,betay and betaz
       fPtotconstx : beta_calc
       GENERIC MAP(
          msb => msb,
          lsb => lsb                      
        )
        PORT MAP (
          clk => clk_250,
          reset => reset,
          fPTot_fP => fPtot_fPx,
          energytot => energytot,
          beta  => betax 
        );
        
       fPtotconsty : beta_calc
       GENERIC MAP(
          msb => msb,
          lsb => lsb                      
        )
        PORT MAP (
          clk => clk_250,
          reset => reset,
          fPTot_fP => fPtot_fPy,
          energytot => energytot,
          beta  => betay 
        );
       
       fPtotconstz : beta_calc
       GENERIC MAP(
          msb => msb,
          lsb => lsb                      
        )
        PORT MAP (
          clk => clk_250,
          reset => reset,
          fPTot_fP => fPtot_fPz,
          energytot => energytot,
          beta  => betaz 
        );
        ----------------------------------------------
        
        ----------------------------------------------
        --calculation of scale1
        scale1calc : scale_calc
        GENERIC MAP(
          msb => msb,
          lsb => lsb                      
        )
        PORT MAP (
          clk => clk_250,
          reset => reset,
          fPx => fP1_fPx,
          fPy => fP1_fPy,
          fPz => fP1_fPz,
          betax => betax,
          betay => betay,
          betaz => betaz,
          scale => scale1
        );
        --calculation of scale2
        scale2calc : scale_calc
        GENERIC MAP(
          msb => msb,
          lsb => lsb                      
        )
        PORT MAP (
          clk => clk_250,
          reset => reset,
          fPx => fP2_fPx,
          fPy => fP2_fPy,
          fPz => fP2_fPz,
          betax => betax,
          betay => betay,
          betaz => betaz,
          scale => scale2
        );
       ----------------------------------------------
       ----------------------------------------------
       --calculation of scaleoverbeta1
       scaleoverbeta1_calc : scaleoverbeta_calc
       GENERIC MAP(
          msb => msb,
          lsb => lsb                      
        )
        PORT MAP (
          clk => clk_250,
          reset => reset,
          scale => scale1,
          beta2 => beta2,
          scaleoverbeta  => scaleoverbeta1
        );
        
        --calculation of scaleoverbeta1
       scaleoverbeta2_calc : scaleoverbeta_calc
       GENERIC MAP(
          msb => msb,
          lsb => lsb                      
        )
        PORT MAP (
          clk => clk_250,
          reset => reset,
          scale => scale2,
          beta2 => beta2,
          scaleoverbeta  => scaleoverbeta2
        );
       ----------------------------------------------
       ----------------------------------------------
       
       --fP1_fPx_out calculation
       fPout1x_calc : fP_out_calc
        GENERIC MAP(
          msb => msb,
          lsb => lsb                      
        )
        PORT MAP (
          clk => clk_250,
          reset => reset,
          fP_in => fP1_fPx,
          gamma => gamma,
          energy => energy1,
          beta => betax,
          gammaminusbeta => gammaminusbeta,
          scaleoverbeta => scaleoverbeta1,
          fP_out => fP1_fPx_out
        );
       
       --fP1_fPy_out calculation
       fPout1y_calc : fP_out_calc
        GENERIC MAP(
          msb => msb,
          lsb => lsb                      
        )
        PORT MAP (
          clk => clk_250,
          reset => reset,
          fP_in => fP1_fPy,
          gamma => gamma,
          energy => energy1,
          beta => betay,
          gammaminusbeta => gammaminusbeta,
          scaleoverbeta => scaleoverbeta1,
          fP_out => fP1_fPy_out
        );
       
       --fP1_fPz_out calculation
       fPout1z_calc : fP_out_calc
        GENERIC MAP(
          msb => msb,
          lsb => lsb                      
        )
        PORT MAP (
          clk => clk_250,
          reset => reset,
          fP_in => fP1_fPz,
          gamma => gamma,
          energy => energy1,
          beta => betaz,
          gammaminusbeta => gammaminusbeta,
          scaleoverbeta => scaleoverbeta1,
          fP_out => fP1_fPz_out
        );


       
       --fP2_fPx_out calculation
       fPout2x_calc : fP_out_calc
        GENERIC MAP(
          msb => msb,
          lsb => lsb                      
        )
        PORT MAP (
          clk => clk_250,
          reset => reset,
          fP_in => fP2_fPx,
          gamma => gamma,
          energy => energy2,
          beta => betax,
          gammaminusbeta => gammaminusbeta,
          scaleoverbeta => scaleoverbeta2,
          fP_out => fP2_fPx_out
        );
       
       --fP2_fPy_out calculation
       fPout2y_calc : fP_out_calc
        GENERIC MAP(
          msb => msb,
          lsb => lsb                      
        )
        PORT MAP (
          clk => clk_250,
          reset => reset,
          fP_in => fP2_fPy,
          gamma => gamma,
          energy => energy2,
          beta => betay,
          gammaminusbeta => gammaminusbeta,
          scaleoverbeta => scaleoverbeta2,
          fP_out => fP2_fPy_out
        );
       
       --fP1_fPz_out calculation
       fPout2z_calc : fP_out_calc
        GENERIC MAP(
          msb => msb,
          lsb => lsb                      
        )
        PORT MAP (
          clk => clk_250,
          reset => reset,
          fP_in => fP2_fPz,
          gamma => gamma,
          energy => energy2,
          beta => betaz,
          gammaminusbeta => gammaminusbeta,
          scaleoverbeta => scaleoverbeta2,
          fP_out => fP2_fPz_out
        );       
       ----------------------------------------------
       
       
       ----------------------------------------------
       
       ilaenergy : ila_0
        PORT MAP (
	       clk => clk_250,



	       probe0 => energy1_std,
	       probe1 => energy2_std
        );
       ilaimput : ila_0
        PORT MAP (
	       clk => clk_250,



	       probe0 => fP1_fPx_std,
	       probe1 => fP1_fPy_std
        );
       
       --assignment of the inputs
       fP1_fPx <= fP1_fPx_in;
       fP1_fPy <= fP1_fPy_in;
       fP1_fPz <= fP1_fPz_in;
       fP2_fPx <= fP2_fPx_in;
       fP2_fPy <= fP2_fPy_in;
       fP2_fPz <= fP2_fPz_in;
       
       reset <= reseth;
       
       fP1_fPx_std <= std_logic_vector(fP1_fPx);
       fP1_fPy_std <= std_logic_vector(fP1_fPy);
       
    process(clk_250)
    begin
    
        if(reset = '1' or reseth = '1') then
            null;
--        reset <= '0';
        else
        if(rising_edge(clk_250)) then
            --e1_to_cast
            --e2_to_cast
            
            --sqrt energy1
            ----------------------------------------------------------
            casting_in_e1 <= std_logic_vector(energy1_to_cast);
            if(valid_out_e1 = '1') then
                sqrt_out_e1 <= signed(casting_out_e1_exit);
                casting_out_e1 <= "00000000000000" & sqrt_out_e1 & "0000000000";
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
            energy1_std <= std_logic_vector(energy1);
            --sqrt energy2
            ------------------------------------------------------------
            casting_in_e2 <= std_logic_vector(energy2_to_cast);
            if(valid_out_e2 = '1') then
                sqrt_out_e2 <= signed(casting_out_e2_exit);
                casting_out_e2 <= "00000000000000" & sqrt_out_e2 & "0000000000";
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
            energy2_std <= std_logic_vector(energy2);
            ------------------------------------------------------------
            
            
            --sum of the 3 momentum components
            fPtot_fPx <= fP1_fPx + fP2_fPx;
            fPtot_fPy <= fP1_fPy + fP2_fPy;
            fPtot_fPz <= fP1_fPz + fP2_fPz;
            
            energytot <= energy1 + energy2;
            -- fPtotconstx
            -- fPtotconsty
            -- fPtotconstz
            
            
            --beta2calc
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
            
            gammatemp <= squared_const_times_const /gamma_casted; --how does it hands the division by 0?
            gamma <= gammatemp(msb downto lsb);
            
            --scale1 and scale 2 definition
            --scale1calc
            --scale2calc

            gammaminusbeta <= gamma - consta;
            
            --------------------
            --scaleoverbeta1_calc
            --scaleoverbeta2_calc
            --------------------
            
            
            --Lorentz transformation of fP1_fPx
            --fPout1x_calc

            --Lorentz transformation of fP1_fPy
            --fPout1y_calc

            --Lorentz transformation of fP1_fPz
            --fPout1z_calc
            
            --Lorentz transformation of fP2_fPx
            --fPout2x_calc
            
            --Lorentz transformation of fP2_fPy
            --fPout2y_calc

            --Lorentz transformation of fP2_fPz
            --fPout2z_calc
            
        end if;
        end if;
    end process;
end Behavioral;