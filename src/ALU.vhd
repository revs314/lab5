----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:50:18 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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

-- implement operands
    -- 000: Add
    -- 001: Subtract
    -- 010: AND
    -- 011: OR
    -- flags: NZCV (Negative, Zero, Carry, Overflow)

entity ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end ALU;

architecture Behavioral of ALU is
    signal c_A : signed(8 downto 0);
    signal c_B : signed(8 downto 0);
    signal temp_result : signed(8 downto 0);
    signal c_result : signed(7 downto 0);

begin
    
    c_A <= resize(signed(i_A), 9);
    c_B <= resize(signed(i_B), 9);
-- resize(c_A, 9) makes A a 9-bit so we don't lose the carry
    -- run this whenevr A, B, or opcode changes
    process(c_A, c_B, i_op)
    variable temp : signed(8 downto 0);
    -- temp holds result before final output
    variable flags : std_logic_vector(3 downto 0)
    -- flags
    begin
    temp := (others => '0');
    flags := (others => '0');
    -- reset everything at start of operation
        case i_op is
            when "000" => -- ADD
                temp := a_s + b_s;
            when "001" => -- SUBTRACT
                temp := a_s - b_s;
            when "010" => -- AND
                temp(7 downto 0) := a_s(7 downto 0) and b_s(7 downto 0);
            when "011" => -- OR
                temp(7 downto 0) := a_s(7 downto 0) or b_s(7 downto 0);
            when others => -- RESET
                temp := (others => '0');
        end case;
      c_result <+ temp(7 downto 0);
      o_result <= std_logic_vector(c_result);
      -- takes lower 8 bits of result and converts it to std_logic_vector
      
      -- flags
      flags(3) := c_result(7);
      -- N(negative): MSB is the sign bit which signifies + or -
      flags(2) := '1' when c_result = 0 else '0';
      -- Z(zero): if result is 0, then Z is 1
      if i_op = "000" then
        flags(1) := temp(8);
      -- C(carry): addition, bit 8 is the carry out
      elsif i_op = "001" then
        flags(1) := temp(8);
      -- C(carry): subtraction, bit 8 is the borrow
      else
          flags(1) := '0';
      -- don't use the carry
      end if; 
      if i_op = "000" or i_op = "001" then
      -- arithmetic (add or sub)
      flags(0) := (c_A(8) = c_B(8)) and (temp(8) /= a_s(8));
      -- overflow happens when inputs have the same sign but the result has a different sign
      else
          flags(0) := '0';
      end if;
      -- no overflow for logic ops (and or)
      
      o_flags <= flags;
      -- gets flags to output flags
     end process;
     


end Behavioral;
