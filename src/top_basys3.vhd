--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    port(
        -- inputs
        clk     :   in std_logic; -- native 100MHz FPGA clock
        sw      :   in std_logic_vector(7 downto 0); -- operands and opcode
        btnU    :   in std_logic; -- reset
        btnC    :   in std_logic; -- fsm cycle
        
        -- outputs
        led :   out std_logic_vector(15 downto 0);
        -- 7-segment display segments (active-low cathodes)
        seg :   out std_logic_vector(6 downto 0);
        -- 7-segment display active-low enables (anodes)
        an  :   out std_logic_vector(3 downto 0)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
    component ALU
        Port (
            i_A : in std_logic_vector(7 downto 0);
            i_B : in std_logic_vector(7 downto 0);
            i_op : in std_logic_vector(2 downto 0);
            o_result : out std_logic_vector(7 downto 0);
            o_flags : out std_logic_vector(3 downto 0);
        );
    end component;

    component controller_fsm
        Port (
            i_reset : in STD_LOGIC;
            i_adv : in STD_LOGIC;
            o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
        );
    end component;
    
        
    component clock_divider
        generic (k_DIV : natural := 50000000);
        Port (
            i_clk    : in std_logic;
			i_reset  : in std_logic;
			o_clk    : out std_logic
        );
    end component;
    
    signal c_A, c_B : std_logic_vector(7 downto 0) := (others => '0');
    signal w_cycle : std_logic_vector(3 downto 0);
    -- FSM output
    signal w_result : std_logic_vector(7 downto 0);
    -- ALU result
    signal w_flags : std_logic_vector(3 downto 0);
    -- ALU flags
    
    signal slow_clk : std_logic;
    
    signal sign : std_logic;
    -- gives sign of number
    signal hundred : std_logic_vector(3 downto 0);
    -- 4 bits to rep tens digit
    signal tens : std_logic_vector(3 downto 0);
    -- 4 bits to rep ones digit
    signal ones : std_logic_vector(3 downto 0);

begin
	-- PORT MAPS ----------------------------------------
    clkdiv: clock_divider
        port map (
            i_clk => clk,
            -- connects input to clock
            i_reset => btnU,
            -- makes btnU the reset
            o_clk => slow_clk
            -- slows down everything
        );
    
    fsm: controller_fsm
        port map (
            i_reset => btnU,
            i_adv => btnC,
            o_cycle => w_cycle
            -- reset button resets FSM
            -- center button advances state
            -- ouptut is 1-hot state
        );    
    alu1: ALU
        port map (
            i_A => c_A,
            i_B => c_B,
            i_op => sw(2 downto 0),
            -- lower 3 switches are the opcode
            o_result => w_result,
            o_flags => w_flags
        );
    
    process(clk)
    begin
        if rising_edge(clk) then
            if btnU = '1' then
                c_A <= (others => '0');
                c_B <= (others => '0');
            else
                case w_cycle is
                    when "0010" =>
                        c_A <= sw;
                        -- load A
                    when "0100" =>
                        c_B <= sw;
                        -- load B
                    when others =>
                        null;
                end case;
                
            end if;
        end if;
    end process;
    
    -- outputs
    led(3 downto 0) <= w_cycle;
    led(15 downto 12) <= w_flags;
    led(11 downto 4) <= (others => '0');
    
    process(w_result)
    begin
        if w_result(7) = '1' then
            sign <= '1';
        else
            sign <= '0';
        end if;
        
        hund <= (others => '0');
        tens <= std_logic_vector(unsigned(w_result) / 10);
        ones <= std_logic_vector(unsigned(w_result) mod 10);
    end process;
    
    seg <= (others => '0');
    an <= "1111";
            
	
	
	-- CONCURRENT STATEMENTS ----------------------------
	
	
	
end top_basys3_arch;
