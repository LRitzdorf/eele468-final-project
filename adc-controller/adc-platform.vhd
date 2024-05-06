-- altera vhdl_input_version vhdl_2008

-- Lucas Ritzdorf
-- 02/01/2024
-- EELE 468

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- HPS interface for color LED module
entity ADC_Platform is
    port (
        clk   : in std_logic; -- system clock
        reset : in std_logic; -- system reset, active high

        -- Memory-mapped Avalon agent interface
        avs_s1_read      : in  std_logic;
        avs_s1_write     : in  std_logic;
        avs_s1_address   : in  std_logic_vector(4 downto 0);
        avs_s1_readdata  : out std_logic_vector(31 downto 0);
        avs_s1_writedata : in  std_logic_vector(31 downto 0);

        -- ADC control interface
        convst : out std_logic;
        sck    : out std_logic;
        sdi    : out std_logic;
        sdo    : in  std_logic
    );
end entity;


architecture ADC_Platform_Arch of ADC_Platform is

    -- Avalon-mapped registers
    -- Configuration
    signal config_single, config_diff : std_logic_vector(7 downto 0);
    -- Sample data
    type t_sample_array is array (natural range <>) of std_logic_vector(11 downto 0);
    signal samples : t_sample_array(15 downto 0);

    -- Sample return signals
    signal sample_value : std_logic_vector(11 downto 0);
    signal sample_wr    : std_logic;
    signal sample_addr  : std_logic_vector(3 downto 0);

    -- ADC controller component
    component ADC_Controller is
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
    end component;

begin

    -- Manage reading from mapped registers
    avalon_register_read : process (clk) is
    begin
        if rising_edge(clk) and avs_s1_read = '1' then
            case to_integer(unsigned(avs_s1_address)) is
                when 0 to 15 =>
                    -- Sample data registers
                    avs_s1_readdata <= 20x"0" & samples(to_integer(unsigned(avs_s1_address)));
                when 16 =>
                    -- Single-ended configuration register
                    avs_s1_readdata <= 24x"0" & config_single;
                when 17 =>
                    -- Differential configuration register
                    avs_s1_readdata <= 24x"0" & config_diff;
                when others =>
                    -- Unused registers: zeros
                    avs_s1_readdata <= (others => '0');
            end case;
        end if;
    end process;

    -- Manage writing to mapped registers
    avalon_register_write : process (clk, reset) is
    begin
        if rising_edge(clk) then
            if reset then
                -- Clear config registers
                config_single <= x"00";
                config_diff   <= x"00";
            elsif avs_s1_write then
                case to_integer(unsigned(avs_s1_address)) is
                    when 0 to 15 =>
                        -- Sample data registers: read-only
                        null;
                    when 16 =>
                        -- Single-ended configuration register
                        config_single <= avs_s1_writedata(7 downto 0);
                    when 17 =>
                        -- Differential configuration register
                        config_diff <= avs_s1_writedata(7 downto 0);
                    when others =>
                        -- Unused registers: ignored
                        null;
                end case;
            end if;
        end if;
    end process;

    -- Instantiate ADC controller itself
    controller : ADC_Controller
        port map (
            clk        => clk,
            reset      => reset,
            config_reg => config_diff & config_single,
            sample     => sample_value,
            sample_wr  => sample_wr,
            sample_idx => sample_addr,
            convst => convst,
            sck    => sck,
            sdi    => sdi,
            sdo    => sdo
        );

    -- Save data returned by ADC controller
    sample_data_write : process(clk) is
    begin
        if rising_edge(clk) then
            if reset then
                -- Clear sample registers
                samples <= (others => 12x"0");
            elsif sample_wr then
                -- Store sample data in appropriate register
                samples(to_integer(unsigned(sample_addr))) <= sample_value;
            end if;
        end if;
    end process;

end architecture;
