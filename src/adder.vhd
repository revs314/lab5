----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/08/2026 01:45:04 PM
-- Design Name: 
-- Module Name: adder - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values


-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity adder is
    Port ( i_a : in STD_LOGIC_VECTOR (7 downto 0);
           i_b : in STD_LOGIC_VECTOR (7 downto 0);
           c_in : in STD_LOGIC;
           sum : out STD_LOGIC_VECTOR (7 downto 0);
           c_out : out STD_LOGIC);
end adder;

architecture Behavioral of adder is
    signal result: unsigned (8 downto 0);
    

begin

    result <= unsigned('0' & i_a) + unsigned('0' & i_b) + (0 => c_in);
    sum <= std_logic_vector(result(7 downto 0));
    c_out <= result(8);

end Behavioral;
