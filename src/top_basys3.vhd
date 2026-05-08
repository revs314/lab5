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
        btnL : in std_logic;
        
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
            o_flags : out std_logic_vector(3 downto 0)
        );
    end component;

    component controller_fsm
        Port (
            i_clk : in STD_LOGIC;
            i_reset : in STD_LOGIC;
            i_adv : in STD_LOGIC;
            o_cycle : out STD_LOGIC_VECTOR (3 downto 0)
        );
    end component;
    
        
    component clock_divider
        generic (k_DIV : natural := 100000);
        Port (
            i_clk    : in std_logic;
			i_reset  : in std_logic;
			o_clk    : out std_logic
        );
    end component;
    
    component twos_comp
        port (
            i_bin : in std_logic_vector(7 downto 0);
            o_sign : out std_logic;
            o_hund : out std_logic_vector(3 downto 0);
            o_tens : out std_logic_vector(3 downto 0);
            o_ones : out std_logic_vector(3 downto 0)
        );
    end component;
    
    component TDM4
        generic ( constant k_WIDTH : natural := 4);
        Port (
           i_clk		: in  STD_LOGIC;
           i_reset		: in  STD_LOGIC; -- asynchronous
           i_D3 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D2 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D1 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D0 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   o_data		: out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   o_sel		: out STD_LOGIC_VECTOR (3 downto 0)	-- selected data line (one-cold)
	    );
    end component;
    
    component sevenseg_decoder
        port (
            i_Hex : in STD_LOGIC_VECTOR (3 downto 0); -- INPUT that is 4 bits HEX -> takes in values 0-F
           o_seg : out STD_LOGIC_VECTOR (6 downto 0) -- OUTPUT that is 7 bits -> controls Sa - Sg
        );
    end component;
    
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
    signal digit_data : std_logic_vector(3 downto 0);
    signal seg_data : std_logic_vector(6 downto 0);
    signal an_data : std_logic_vector(3 downto 0);
    signal op_latched : std_logic_vector(2 downto 0) := "000";
    signal result_latched : std_logic_vector(7 downto 0) := (others => '0');
    signal btnC_sync, btnC_prev : std_logic := '0';
    signal btnC_pulse : std_logic;
    signal A_latched, B_latched : std_logic_vector(7 downto 0) := (others => '0');
    signal display_value : std_logic_vector(7 downto 0);

begin
	-- PORT MAPS ----------------------------------------
    clkdiv: clock_divider
        port map (
            i_clk => clk,
            -- connects input to clock
            i_reset => btnL,
            -- makes btnU the reset
            o_clk => slow_clk
            -- slows down everything
        );
        
    process(clk)
    begin
        if rising_edge(clk) then
            btnC_prev <= btnC_sync;
            btnC_sync <= btnC;
        end if;
    end process;
    
    btnC_pulse <= btnC_sync and (not btnC_prev);
    
    -- button_debounce
    -- 2 registers (A and B)
    -- 
    
    fsm: controller_fsm
        port map (
            i_clk => clk,
            i_reset => btnU,
            i_adv => btnC_pulse,
            o_cycle => w_cycle
            -- reset button resets FSM
            -- center button advances state
            -- ouptut is 1-hot state
        );    
        
    alu1: ALU
        port map (
            i_A => A_latched,
            i_B => B_latched,
            i_op => op_latched,
            -- lower 3 switches are the opcode
            o_result => w_result,
            o_flags => w_flags
        );
        
process(clk)
    begin
        if rising_edge(clk) then
            if btnU = '1' then
                A_latched <= (others => '0');
                B_latched <= (others => '0');
                result_latched <= (others => '0');
                op_latched <= (others => '0');
            elsif btnC_pulse = '1' then
                case w_cycle is
                    when "0010" =>
                        A_latched <= sw;
                        -- w_cycle <= "0100";
                        -- load A
                    when "0100" =>
                        B_latched <= sw;
                        op_latched <= sw(2 downto 0); -- the lower 3 bits become the opcode
                        -- w_cycle <= "1000";
                        -- load B
                    when "1000" =>
                        result_latched <= w_result;
                        -- w_cycle <= "0010";
                    when others =>
                        null;
                end case;
                
            end if;
        end if;
end process;

-- display
process(w_cycle, A_latched, B_latched, result_latched)
begin
    case w_cycle is -- if the 
        when "0010" =>
            display_value <= A_latched;
            -- displays A
        when "0100" =>
            display_value <= B_latched;
            -- displays B
        when "1000" =>
            display_value <= result_latched;
            -- displays result
            
        when others =>
            display_value <= (others => '0'); 
    end case;
end process;

        
    decimal_conversion: twos_comp
    port map(
        i_bin => display_value,
        o_sign => sign,
        o_hund => hundred,
        o_tens => tens,
        o_ones => ones
    );
    
    display: TDM4
    generic map(k_WIDTH => 4)
    port map(
        i_clk => slow_clk,
        i_reset => btnU,
        i_D3 => "0000", -- leftmost digit
        i_D2 => hundred,
        i_D1 => tens,
        i_D0 => ones,
        o_data => digit_data,
        o_sel => an_data
    );
    
    decoder: sevenseg_decoder
        port map(
            i_Hex => digit_data,
            o_seg => seg_data
        );
    -- converts 0101 into segments to rep 5
    
    process(sign, an_data, seg_data)
    begin
        if sign = '1' and an_data = "0111" then
            seg <= "0111111";
        else
            seg <= seg_data;
        end if;
        
        an <= an_data;
    end process;
    
    
    -- outputs
    led(3 downto 0) <= w_cycle;
    led(15 downto 12) <= w_flags;
    led(11 downto 4) <= (others => '0');

            
	
	
	-- CONCURRENT STATEMENTS ----------------------------
	-- display respective number for respective cycle
	
	
end top_basys3_arch;
