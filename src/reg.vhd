----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/08/2026 02:40:30 PM
-- Design Name: 
-- Module Name: reg - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity reg is
    Port ( LD : in STD_LOGIC;
           CLK : in STD_LOGIC;
           D_IN : in STD_LOGIC_VECTOR (7 downto 0);
           D_OUT : out STD_LOGIC_VECTOR (7 downto 0));
end reg;

architecture Behavioral of reg is
begin
    process (CLK,LD)
    begin
        if (LD = '1' and rising_edge(CLK)) then
            D_OUT <= D_IN;
        end if;
    end process;




end Behavioral;
