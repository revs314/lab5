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
use IEEE.NUMERIC_STD.ALL;

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
    variable flags : std_logic_vector(3 downto 0);
    -- flags
    begin
    temp := (others => '0');
    flags := (others => '0');
    -- reset everything at start of operation
        case i_op is
            when "000" => -- ADD
                temp := c_A + c_B;
            when "001" => -- SUBTRACT
                temp := c_A - c_B;
            when "010" => -- AND
                temp(7 downto 0) := c_A(7 downto 0) and c_B(7 downto 0);
            when "011" => -- OR
                temp(7 downto 0) := c_A(7 downto 0) or c_B(7 downto 0);
            when others => -- RESET
                temp := (others => '0');
        end case;
      c_result <= temp(7 downto 0);
      o_result <= std_logic_vector(temp(7 downto 0));
      -- takes lower 8 bits of result and converts it to std_logic_vector
      
      -- flags
      flags(3) := temp(7);
      -- N(negative): MSB is the sign bit which signifies + or -
      -- can't compare c_result to 0 because it's signed
      if temp(7 downto 0) = to_signed(0, 8) then
        flags(2) := '1';
      else
        flags(2) := '0';
      end if;
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
      
      if i_op = "000" then
      -- overflow happens when inputs have the same sign but the result has a different sign
        if (c_A(7) = c_B(7)) and (temp(7) /= c_A(7)) then
            flags(0) := '1';
        else
            flags(0) := '0';
        end if;
      -- 7 is the signed MSB
      elsif i_op = "001" then
        if (c_A(7) /= c_B(7)) and (temp(7) /= c_A(7)) then
            flags(0) := '1';
        else
            flags(0) := '0';
        end if;
      
      else
          flags(0) := '0';
      end if;
      -- no overflow for logic ops (and or)
      
      o_flags <= flags;
      -- gets flags to output flags
     end process;
     


end Behavioral;
