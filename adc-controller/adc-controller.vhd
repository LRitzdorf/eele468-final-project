-- Lucas Ritzdorf
-- 01/23/2024
-- EELE 468

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


-- ADC controller interface
entity ADC_Controller is
    port (
        -- External interface
        clk        : in  std_logic;
        reset      : in  std_logic;
        config_reg : in  std_logic_vector(15 downto 0);
        sample     : out std_logic_vector(11 downto 0);
        sample_wr  : out std_logic;
        sample_idx : out std_logic_vector(3 downto 0);
        -- ADC control interface
        convst : out std_logic;
        sck    : out std_logic;
        sdi    : out std_logic;
        sdo    : in  std_logic
    );
end entity;


-- ADC controller implementation
architecture ADC_Controller_Arch of ADC_Controller is

    -- State machine signals
    type t_state is (
        s_search,       -- Search config register, wait for ADC conversion
        s_communicate,  -- Communicate with ADC
        s_store         -- Store sample reading, wait for ADC acquisition
    );
    signal current_state, next_state : t_state;
    signal state_counter : natural;

    -- Status flags
    signal pause, discard_sample : boolean;

    -- Traverser status/control signals
    signal traverser_launch, traverser_found : std_logic;

    -- Shift register signals
    signal shift_clk : std_logic;
    signal config_idx  : std_logic_vector(3 downto 0);
    signal config_data : std_logic_vector(5 downto 0);
    signal config_load : std_logic;

    -- IP components
    component serial2parallel_8 is
        port (
            clock   : in std_logic;
            shiftin : in std_logic;
            q       : out std_logic_vector(11 downto 0)
        );
    end component;
    component parallel2serial_8 is
        port (
            clock    : in std_logic;
            data     : in std_logic_vector(5 downto 0);
            load     : in std_logic;
            shiftout : out std_logic
        );
    end component;

begin

    -- CONTROL STATE MACHINE

    -- Control Flow:
    --   - Search
    --     - Set convst
    --     - If pause:
    --       - If not 1 found:
    --         - Stay in Search
    --       - Else 1 found:
    --         - Clear pause
    --     - Else not pause:
    --       - Wait 70 cycles for searching, ADC conversion
    --       - If not 1 found:
    --         - Set pause
    --     - Clear convst
    --   - Communicate
    --     - Translate config index to config vector
    --     - Generate SCK @ 25 MHz
    --     - Wait 24 cycles for communication
    --   - Store
    --     - If not discard_sample:
    --       - Pulse sample_wr
    --     - Shift config_idx -> sample_idx, pause -> discard_sample
    --     - Wait 6 cycles for ADC acquisition

    -- Transition between states and manage the in-state counter
    state_transitioner : process (clk) is
    begin
        if rising_edge(clk) then
            if reset then
                state_counter <= 0;
                current_state <= s_search;
            else
                -- Reset counter when state changes
                if next_state = current_state then
                    state_counter <= state_counter + 1;
                else
                    state_counter <= 0;
                end if;
                current_state <= next_state;
            end if;
        end if;
    end process;

    -- Determine which state occurs next
    state_controller : process (all) is
    begin
        case current_state is

            when s_search =>
                if pause then
                    -- Traverse config register until a 1 is found
                    if traverser_found then
                        next_state <= s_communicate;
                    else
                        next_state <= s_search;
                    end if;
                elsif state_counter >= 69 then
                    -- Wait 70 cycles, for config register search to complete
                    next_state <= s_communicate;
                else
                    -- We're not paused, and have waited long enough to continue
                    next_state <= s_search;
                end if;

            when s_communicate =>
                -- Wait 25 cycles (i.e. 12.5 cycles of the 25 MHz SCK), for ADC communication
                if state_counter >= 24 then
                    next_state <= s_store;
                else
                    next_state <= s_communicate;
                end if;

            when s_store =>
                -- Wait 5 cycles, to fill remaining time for a 2 us sampling frequency
                if state_counter >= 4 then
                    next_state <= s_search;
                else
                    next_state <= s_store;
                end if;

        end case;
    end process;

    -- Generate control signals based on current state and progress
    output_controller : process (clk) is
    begin
        if rising_edge(clk) then
            if reset then
                traverser_launch <= '0';
                shift_clk <= '0';
                sck <= '0';
                sample_wr <= '0';
                -- Discard first (unconfigured) sample after reset
                discard_sample <= true;
                -- Run after reset, duh
                pause <= false;
            else
                case current_state is

                    when s_search =>
                        -- Launch the traverser after entering the search state
                        if state_counter = 0 then
                            traverser_launch <= '1';
                        else
                            traverser_launch <= '0';
                        end if;
                        shift_clk <= '0';
                        sck <= '0';
                        sample_wr <= '0';

                    when s_communicate =>
                        if state_counter = 0 then
                            -- Pause next time if no samples are requested
                            pause <= ?? (not traverser_found);
                        end if;
                        -- Generate 25 MHz clocks for ADC communication
                        shift_clk <= not to_unsigned(state_counter, 1)(0);  -- Starts 20 ns sooner
                        sck       <=     to_unsigned(state_counter, 1)(0);  -- Rises as shift_clk falls
                        traverser_launch <= '0';
                        sample_wr <= '0';

                    when s_store =>
                        -- End-of-sample tasks
                        if state_counter = 0 then
                            -- Pulse the sample write signal for one clock cycle
                            if discard_sample then
                                sample_wr <= '0';
                            else
                                sample_wr <= '1';
                            end if;
                            -- If we need to pause next time, the following
                            -- reading should be discarded.
                            discard_sample <= pause;
                        else
                            sample_wr <= '0';
                        end if;
                        if next_state = s_search then
                            -- The kind of config we just found determines the
                            -- kind of reading we'll receive next time.
                            sample_idx <= config_idx;
                        end if;
                        traverser_launch <= '0';
                        shift_clk <= '0';
                        sck <= '0';

                end case;
            end if;
        end if;
    end process;
    -- Keep CONVST high while searching, to enter nap state while paused and
    -- continuously searching.
    convst <= '1' when current_state = s_search else '0';


    -- COMPONENTS

    -- Traverser component, wired to pause itself upon success
    traverser : entity work.Vector_Traverser
    generic map (
        WIDTH => 16
    )
    port map (
        clk    => clk,
        reset  => reset,
        vector => config_reg,
        -- Run until a 1 is found, or if explicitly launched
        run    => (not traverser_found) or traverser_launch,
        index  => config_idx,
        value  => traverser_found
    );

    -- ADC config translator component (sequential)
    translator : entity work.Config_Translator
    port map (
        index  => config_idx,
        config => config_data
    );

    -- Shift registers
    -- Capture serial input data into parallel vector
    serial2parallel_8_inst : serial2parallel_8 port map (
        clock   => shift_clk,
        shiftin => sdo,
        q       => sample
    );
    -- Transmit configuration vector in serial form
    parallel2serial_8_inst : parallel2serial_8 port map (
        clock    => shift_clk,
        data     => config_data,
        load     => config_load,
        shiftout => sdi
    );
    -- Parallel load signal for P2S shift register
    config_load <= '1'
                   when (current_state = s_communicate)
                   and (state_counter = 0)
               else '0';

end architecture;
