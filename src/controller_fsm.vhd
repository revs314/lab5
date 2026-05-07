----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:42:49 PM
-- Design Name: 
-- Module Name: controller_fsm - FSM
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

entity controller_fsm is
    Port ( 
           i_clk : in STD_LOGIC;
           i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
end controller_fsm;
-- reset = 1: go back to starting state
-- i_adv is btnC: each press moves FSM forward one step
-- o_cycle: 4-bit output that tells the system what state you're in

architecture FSM of controller_fsm is

type state_type is (S0, S1, S2, S3);
-- defines 4 states:
    -- S0: reset/idle
    -- S1: load operand A
    -- S2: load operand B
    -- S3: compute result
signal state : state_type := S0;
-- init to S0

signal adv_curr : std_logic := '0';
-- adv_curr = current button state (same as clock)

signal adv_prev : std_logic := '0';
-- adv_prev = previous clock cycle

signal adv_pulse : std_logic := '0';
-- adv_pulse = when button is pressed

begin
process(i_clk)
begin
    if rising_edge(i_clk) then
    -- once the clock ticks
        adv_prev <= adv_curr;
        -- stores the previous value of the button
        adv_curr <= i_adv;
        -- reads the button press and stores it in a register
        -- in order to not have multiple clock cycles change when we press the button, we use the previous to track if the button has been pressed before
        adv_pulse <= adv_curr and (not adv_prev);
        -- if the button is currently pressed AND it hasn't been held down
    end if;
end process;

process(i_clk)
begin
-- runs when clock ticks
    if rising_edge(i_clk) then
    
        if i_reset = '1' then
            state <= S0;
        elsif adv_pulse = '1' then
            case state is
                when S0 => state <= S1;
                when S1 => state <= S2;
                when S2 => state <= S3;
                when S3 => state <= S0;
                -- loop is: S0, S1, S2, S3, S0, repeat
            end case;
        end if;
    end if;
end process;

o_cycle <= "0001" when state = S0 else
           "0010" when state = S1 else
           "0100" when state = S2 else
           "1000";


end FSM;
