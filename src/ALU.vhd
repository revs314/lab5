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
    component adder is
        Port ( i_a : in STD_LOGIC_VECTOR (7 downto 0);
               i_b : in STD_LOGIC_VECTOR (7 downto 0);
               c_in : in STD_LOGIC;
               sum : out STD_LOGIC_VECTOR (7 downto 0);
               c_out : out STD_LOGIC);
    end component adder;
    
    signal b_signal : std_logic_vector(7 downto 0);
    signal op_signal : std_logic;
    signal sum_signal : std_logic_vector(7 downto 0);
    signal out_signal : std_logic;
    signal result : std_logic_vector(7 downto 0);
    signal negative : std_logic;
    signal zero : std_logic;
    signal carry : std_logic;
    signal overflow : std_logic;

begin
    

    adder_inst: adder port map (
            i_a => i_A,
            i_b => b_signal,
            c_in => op_signal,
            sum => sum_signal,
            c_out => out_signal
        );
    
    op_signal <= '0' when (i_op = "000") else
            '1' when (i_op = "001") else
            '0';
            
    b_signal <= not(i_b) when (i_op = "001") else
            i_b;
           
    result <= sum_signal when ((i_op = "000") or (i_op = "001")) else
            (i_a and i_b) when (i_op = "010") else
            (i_a or i_b) when (i_op = "011");
            
    negative <= '1' when (result(7) = '1') else '0';
    
    zero <= '1' when (result = "00000000") else '0';
        
    carry <= out_signal when ((i_op = "000") or (i_op = "001")) else '0';
    
    overflow <= (i_A(7) xor sum_signal(7)) and not(i_A(7) xor  b_signal(7))
        when ((i_op = "000") or (i_op = "001")) else
        '0';
    
    o_result <= result;
    
    o_flags <= negative & zero & carry & overflow;


end Behavioral;
