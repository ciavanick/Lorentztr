----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/10/2024 12:18:16 PM
-- Design Name: 
-- Module Name: top_lorentz - Behavioral
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

entity top_lorentz is
    Port ( clock_in_n : in STD_LOGIC;
           clock_in_p : in STD_LOGIC);
end top_lorentz;

architecture Behavioral of top_lorentz is
constant i_max : integer := 0;

type arrayofsigned is array(i_max downto 0) of signed(39 downto 0);
type arrayofstd is array(i_max downto 0) of std_logic_vector(39 downto 0);
type arrayofreset is array(i_max downto 0) of std_logic;
--signal ressignal : arrayofsigned := (others=>(others=>'0'));

signal resetl :arrayofreset := (others=>'1');
signal reset : std_logic := '1';
signal clk : std_logic := '0';
signal msb : integer := 39;
signal lsb : integer := 0;
signal consta : signed(39 downto 0) := x"0000100000"; --constant, is = 2^20 (so 2^(msb+1)/2)
signal squared_const : signed(23 downto 0) := x"000400";
signal squared_const_times_const : signed(63 downto 0) := x"0000000040000000";
signal fPrMass : signed(39 downto 0) := x"00000F0329";

signal fP1_fPx, fP1_fPy, fP1_fPz : arrayofsigned := (others=>x"0000011111");  
signal fP2_fPx, fP2_fPy, fP2_fPz : arrayofsigned := (others=>x"0000011111");

signal fP1_fPx_std, fP1_fPy_std, fP1_fPz_std : arrayofstd := (others=>x"0000011111");
signal fP2_fPx_std, fP2_fPy_std, fP2_fPz_std : arrayofstd := (others=>x"0000011111");

signal fP1_fPx_out, fP1_fPy_out, fP1_fPz_out : arrayofsigned := (others=>x"0000011111");
signal fP2_fPx_out, fP2_fPy_out, fP2_fPz_out : arrayofsigned := (others=>x"0000011111");

signal fP1_fPx_out_std, fP1_fPy_out_std, fP1_fPz_out_std :  arrayofstd := (others=>x"0000011111");
signal fP2_fPx_out_std, fP2_fPy_out_std, fP2_fPz_out_std :  arrayofstd := (others=>x"0000011111");

COMPONENT lorentztr
    generic( msb : integer := 39; --number of bit
             lsb : integer := 0;
             consta : signed(39 downto 0) := x"0000100000"; --constant, is = 2^20 (so 2^(msb+1)/2)
             squared_const : signed(23 downto 0) := x"000400";
             squared_const_times_const : signed(63 downto 0) := x"0000000040000000";
             fPrMass : signed(39 downto 0) := x"00000F0329"); --Mass of the particle
    Port ( clk_250 : in STD_LOGIC;
           reseth : in STD_LOGIC;
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
END COMPONENT;

COMPONENT vio_1
  PORT (
    clk : IN STD_LOGIC;
    probe_in0 : IN STD_LOGIC_VECTOR(39 DOWNTO 0);
    probe_in1 : IN STD_LOGIC_VECTOR(39 DOWNTO 0);
    probe_in2 : IN STD_LOGIC_VECTOR(39 DOWNTO 0);
    probe_in3 : IN STD_LOGIC_VECTOR(39 DOWNTO 0);
    probe_in4 : IN STD_LOGIC_VECTOR(39 DOWNTO 0);
    probe_in5 : IN STD_LOGIC_VECTOR(39 DOWNTO 0);
    probe_out0 : OUT STD_LOGIC_VECTOR(39 DOWNTO 0);
    probe_out1 : OUT STD_LOGIC_VECTOR(39 DOWNTO 0);
    probe_out2 : OUT STD_LOGIC_VECTOR(39 DOWNTO 0);
    probe_out3 : OUT STD_LOGIC_VECTOR(39 DOWNTO 0);
    probe_out4 : OUT STD_LOGIC_VECTOR(39 DOWNTO 0);
    probe_out5 : OUT STD_LOGIC_VECTOR(39 DOWNTO 0);
    probe_out6 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
  );
END COMPONENT;

  component clk_wiz_0
port
 (-- Clock in ports
  -- Clock out ports
  clk_out1          : out    std_logic;
  -- Status and control signals
  reset             : in     std_logic;
  locked            : out    std_logic;
  clk_in1_p         : in     std_logic;
  clk_in1_n         : in     std_logic
 );
end component;


begin
              clockmanagment : clk_wiz_0
               port map ( 
              -- Clock out ports  
               clk_out1 => clk,
              -- Status and control signals                
               reset => '0',
               locked => open,
               -- Clock in ports
               clk_in1_p => clock_in_p,
               clk_in1_n => clock_in_n
             );

          asynchronus_loop : for i in 0 to i_max generate
            ltr : lorentztr
            GENERIC MAP(
                      msb => msb,
                      lsb => lsb,
                      consta => consta,
                      squared_const => squared_const,
                      squared_const_times_const => squared_const_times_const,
                      fPrMass => fPrMass                 
                    )
                    PORT MAP (
                      clk_250 => clk,
                      reseth => resetl(i),
                      fP1_fPx_in => fP1_fPx(i),
                      fP1_fPy_in => fP1_fPy(i),
                      fP1_fPz_in => fP1_fPz(i),
                      fP2_fPx_in => fP2_fPx(i),
                      fP2_fPy_in => fP2_fPy(i),
                      fP2_fPz_in => fP2_fPz(i),
                      fP1_fPx_out => fP1_fPx_out(i),
                      fP1_fPy_out => fP1_fPy_out(i),
                      fP1_fPz_out => fP1_fPz_out(i),
                      fP2_fPx_out => fP2_fPx_out(i),
                      fP2_fPy_out => fP2_fPy_out(i),
                      fP2_fPz_out => fP2_fPz_out(i)
                    );
                   -----
                   virtualio : vio_1
              PORT MAP (
                clk => clk,
                probe_in0 => fP1_fPx_std(i),
                probe_in1 => fP1_fPy_std(i),
                probe_in2 => fP1_fPz_std(i),
                probe_in3 => fP2_fPx_std(i),
                probe_in4 => fP2_fPy_std(i),
                probe_in5 => fP2_fPz_std(i),
                probe_out0 => fP1_fPx_out_std(i),
                probe_out1 => fP1_fPy_out_std(i),
                probe_out2 => fP1_fPz_out_std(i),
                probe_out3 => fP2_fPx_out_std(i),
                probe_out4 => fP2_fPy_out_std(i),
                probe_out5 => fP2_fPz_out_std(i),
                probe_out6(0) => resetl(i)
              );
              

            
            --process(clk)
            
            
            --        begin
            --        if(reset = '1') then
            --        elsif(rising_edge(clk)) then
                    
            --        end if;
            --end process;
            
            fP1_fPx_std(i) <= std_logic_vector(fP1_fPx_out(i));
            fP1_fPy_std(i) <= std_logic_vector(fP1_fPy_out(i));
            fP1_fPz_std(i) <= std_logic_vector(fP1_fPz_out(i));
            fP2_fPx_std(i) <= std_logic_vector(fP2_fPx_out(i));
            fP2_fPy_std(i) <= std_logic_vector(fP2_fPy_out(i));
            fP2_fPz_std(i) <= std_logic_vector(fP2_fPz_out(i));
            
            
            fP1_fPx(i) <= signed(fP1_fPx_out_std(i));
            fP1_fPy(i) <= signed(fP1_fPy_out_std(i));
            fP1_fPz(i) <= signed(fP1_fPz_out_std(i));
            fP2_fPx(i) <= signed(fP2_fPx_out_std(i));
            fP2_fPy(i) <= signed(fP2_fPy_out_std(i));
            fP2_fPz(i) <= signed(fP2_fPz_out_std(i));

          end generate;

end Behavioral;
