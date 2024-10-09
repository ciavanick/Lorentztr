----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/04/2024 11:18:32 AM
-- Design Name: 
-- Module Name: triple_product - Behavioral
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

entity triple_product is
    generic( msb : integer := 39; --number of bit
             lsb : integer := 0);
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           A : in signed(msb downto lsb);
           B : in signed(msb downto lsb);
           C : in signed(msb downto lsb);
           P : out signed(3*msb+2 downto lsb)
    );
end triple_product;

architecture Behavioral of triple_product is
signal A_std, B_std, C_std : STD_LOGIC_VECTOR(msb downto lsb) := (others=>'0');--x"0000011111";  
signal absC : signed(msb downto lsb) := (others=>'0');
signal absP1out : signed(2*msb+1 downto lsb) := (others=>'0');
signal P1out_std: STD_LOGIC_VECTOR(2*msb+1 downto lsb) := (others=>'0'); --x"00000000000011111111"; 
signal P1out_signed: signed(2*msb+1 downto lsb) := (others=>'0');--x"00000000000011111111"; 
signal zeros : signed(2*msb+1 downto 0) := (others=>'0');
signal zero : signed(3*msb+2 downto 0) := (others=>'0');
signal unos : signed(2*msb+1 downto 0) := (others=>'1');
 
--type arraytest is array(127 downto 0) of unsigned(7 downto 0);
--type arraytest2d is array(127 downto 0) of arraytest;

--signal ciao : arraytest2d := (others=>(others=>(others=>'0')));

type arrayofsigned is array(79 downto 0) of signed(119 downto 0);
signal ressignal : arrayofsigned := (others=>(others=>'0'));
    COMPONENT mult_gen_0
      PORT (
        CLK : IN STD_LOGIC;
        A : IN STD_LOGIC_VECTOR(39 DOWNTO 0);
        B : IN STD_LOGIC_VECTOR(39 DOWNTO 0);
        P : OUT STD_LOGIC_VECTOR(79 DOWNTO 0)
      );
    END COMPONENT;
begin
        first : mult_gen_0
        PORT MAP (
          CLK => clk, 
          A => A_std,
          B => B_std,
          P => P1out_std
        );
        
        process(clk)
--        variable res, restemp, restempA, counter : signed(3*msb+2 downto 0):= (others=>'0');
        begin
        if(reset = '1') then
            A_std <= (others=>'0');
            B_std <= (others=>'0');
            C_std <= (others=>'0');
            ----------output--------------
            P <= (others=>'0');
        elsif(rising_edge(clk)) then
--            res := (others=>'0');
            A_std <= std_logic_vector(A);
            B_std <= std_logic_vector(B);
            P1out_signed <= signed(P1out_std);
--                counter := (others=>'1'); 
                if((P1out_signed(2*msb+1) = '0' and C(msb) = '0')) then
                    if(P1out_signed(0) = '1') then
--                        restempA := zeros(79 downto 0) & C;
                          ressignal(0) <= zeros(79 downto 0) & C;
                    else 
--                        restempA := (others=>'0');
                          ressignal(0) <= (others=>'0');
                    end if;
                    for i in 1 to 79 loop
                    
                        if(P1out_signed(i) = '1') then
--                            restemp := zeros(79-i downto 0) & C & zeros(i-1 downto 0) ;
                              ressignal(i) <= zeros(79-i downto 0) & C & zeros(i-1 downto 0) + ressignal(i-1);
                              
                        else 
--                            restemp := (others=>'0');
                              ressignal(i) <= zero + ressignal(i-1);
                        end if;
                    end loop;
                    P <= ressignal(79);
                 elsif((P1out_signed(2*msb+1) = '1' and C(msb) = '1')) then
                    absC <= abs(C);
                    absP1out <= abs(P1out_signed);
                    if(absP1out(0) = '1') then
--                        restempA := zeros(79 downto 0) & absC;
                          ressignal(0) <= zeros(79 downto 0) & absC;
                    else 
--                        restempA := (others=>'0');
                          ressignal(0) <= (others=>'0');
                    end if;
                    for i in 1 to 79 loop
--                    restemp := (others=>'0');
                        if(absP1out(i) = '1') then
--                            restemp := zeros(79-i downto 0) & absC & zeros(i-1 downto 0) ;
                              ressignal(i) <= zeros(79-i downto 0) & absC & zeros(i-1 downto 0) + ressignal(i-1);
                        else 
--                            restemp := (others=>'0');
                              ressignal(i) <= zero + ressignal(i-1);
                        end if;
--                        res := res + restemp;
                    end loop;
                    P <= ressignal(79);
                 elsif ((P1out_signed(2*msb+1) = '0' and C(msb) = '1')) then
                    if(P1out_signed(0) = '1') then
--                        restempA := unos(79 downto 0) & C;
                          ressignal(0) <= unos(79 downto 0) & C;
                    else 
--                        restempA := (others=>'0');
                          ressignal(0) <= (others=>'0');

                    end if;
                    for i in 1 to 79 loop
                    
                        if(P1out_signed(i) = '1') then
--                            restemp := unos(79-i downto 0) & C & zeros(i-1 downto 0) ;
                              ressignal(i) <= unos(79-i downto 0) & C & zeros(i-1 downto 0) + ressignal(i-1);
                        else 
--                            restemp := (others=>'0');
                              ressignal(i) <= zero + ressignal(i-1);
                        end if;
--                        res := res + restemp;
                    end loop;
                    P <= ressignal(79);
                  elsif ((P1out_signed(2*msb+1) = '1' and C(msb) = '0')) then
                    if(C(0) = '1') then
--                        restempA := unos(39 downto 0) & P1out_signed;
                          ressignal(0) <= unos(39 downto 0) & P1out_signed;

                    else 
--                        restempA := (others=>'0');
                          ressignal(0) <= (others=>'0');
                    end if;
                    for i in 1 to 39 loop
                    
                        if(C(i) = '1') then
--                            restemp := unos(39-i downto 0) & P1out_signed & zeros(i-1 downto 0) ;
                              ressignal(i) <= unos(39-i downto 0) & P1out_signed & zeros(i-1 downto 0) + ressignal(i-1);
                        else 
--                            restemp := (others=>'0');
                              ressignal(i) <= zero + ressignal(i-1);
                        end if;
--                        res := res + restemp;
                    end loop;
                    P <= ressignal(39);
                 end if;
                 
        end if;
        end process;
        

end Behavioral;
