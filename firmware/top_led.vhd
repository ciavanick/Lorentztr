----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/28/2024 11:33:24 AM
-- Design Name: 
-- Module Name: top_led - Behavioral
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

entity top_led is
    generic(msb : integer := 7;
            lsb : integer := 0);
    Port ( clock_in_p : in STD_LOGIC;
           clock_in_n : in STD_LOGIC);
end top_led;

architecture Behavioral of top_led is
    constant const : integer := 5;
    signal a : unsigned (msb downto 0) := "00000000"; --
    signal b : std_logic_vector (msb downto 0) := "00000000"; -- 
    signal clk, reset : std_logic := '0'; -- 
    signal probe_in0, probe_out0 : std_logic_vector (msb downto 0):= "00000000";  
    signal cnt_s : integer := 0;  
    signal cnt_s0 : integer := 0;  
    signal cnt_s1 : integer := 0;  
    signal cnt_s2 : integer := 0;  
    signal cnt_s3 : integer := 0;  
    signal cnt_s4 : integer := 0;  
    signal cnt_s5 : integer := 0;  
    signal cnt_s6 : integer := 0;  
    signal cnt_s7 : integer := 0;  
    signal cnt_s8 : integer := 0;  
    signal cnt_s9 : integer := 0;  
    
    type fsm_ex is (idle, start, stop, cnt_adv); --tipo
    signal op : fsm_ex := idle;
    
    type array_cnt is array (9 downto 0) of integer;
    
--    component ggg 
--    generic(msb : integer := 7;
--            lsb : integer := 0);
--    Port ( clock_in_p : in STD_LOGIC;
--           clock_in_n : in STD_LOGIC);
--end component;
    COMPONENT vio_0
      PORT (
        clk : IN STD_LOGIC;
        probe_in0 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        probe_out0 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
    END COMPONENT;

begin

   IBUFDS_inst : IBUFDS
   port map (
      O => clk,   -- 1-bit output: Buffer output
      I => clock_in_p,   -- 1-bit input: Diff_p buffer input (connect directly to top-level port)
      IB => clock_in_n  -- 1-bit input: Diff_n buffer input (connect directly to top-level port)
   ); --mapping di un component

-- istanziamo un VIO 
    your_instance_name : vio_0
      PORT MAP (
        clk => clk,
        probe_in0 => probe_in0,
        probe_out0 => probe_out0
      );

--a<= to_unsigned(const, a'length); --assegnazione asincrona



process(clk) 
    variable cnt : integer := 0; 
    variable cnt_0 : integer := 0; 
    variable cnt_1 : integer := 0; 
    variable cnt_2 : integer := 0; 
    variable cnt_3 : integer := 0; 
    variable cnt_4 : integer := 0; 
    variable cnt_5 : integer := 0; 
    variable cnt_6 : integer := 0; 
    variable cnt_7 : integer := 0; 
    variable cnt_8 : integer := 0; 
    variable cnt_9 : integer := 0;
    
begin
    cnt_0 := cnt_0 + 1;
    cnt_s0 <= cnt_0;
    if(reset = '1') then
        a <= (others=>'1'); --salvo tutti i bit come 1 
        cnt_1 := cnt_1 + 1;
        cnt_s1 <= cnt_1;
        cnt_1 := cnt_1 + 1;
        cnt_s2 <= cnt_1;
    elsif(rising_edge(clk)) then
--        a<= to_unsigned(const, a'length);
          a<= unsigned(probe_out0);
          probe_in0 <= not std_logic_vector(a);
          
          
          cnt := 7;
          cnt := 8;
--          cnt_s<= cnt;
          
          for i in 0 to 7 loop
          
          cnt_2 := cnt_2 +1;
          cnt_s3 <= cnt_2;
--          cnt_s <= cnt_s +1;
          
          b(i)<= not a(i);
          end loop;
          --cnt := cnt_s; 
          
              cnt_4 := cnt_4 + 1;
              cnt_s5 <= cnt_4;
          --case 
          case op is
          when idle =>
              cnt_s <= 0;
              op <= start;
          when start =>
              if (cnt_s /= 0) then
                cnt_s <= cnt_s - 7;
              else 
                cnt_s <= 0;
              end if;
              op <= cnt_adv;
          when cnt_adv =>
              cnt_s <= cnt_s + 1;
              if (cnt_s < 10) then
                null; -- o op <= cnt_adv
              else
                op <= stop;
              end if;
              
          when stop =>
              op <= start;
          when others => 
          
          end case;
    end if;
    
   
    cnt_3 := cnt_3 + 1;
    cnt_s4 <= cnt_3;

end process;

asynchronus_loop : for i in 0 to 7 generate
          b(i)<= not a(i);
          end generate;

--variables 
end Behavioral;
