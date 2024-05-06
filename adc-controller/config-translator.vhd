-- Lucas Ritzdorf
-- 01/27/2024
-- EELE 468

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


-- ADC config translator interface
entity Config_Translator is
    port (
        index  : in  std_logic_vector(3 downto 0);
        config : out std_logic_vector(5 downto 0)
    );
end entity;


-- ADC config translator implementation
architecture Config_Translator_Arch of Config_Translator is

    type table is array(0 to 15) of std_logic_vector(5 downto 0);
    constant lookup : table := (
        -- Rightmost two bits specify unipolar mode, sleep disabled
        -- Order is critical!
        b"100010",  -- Ch0
        b"110010",  -- Ch1
        b"100110",  -- Ch2
        b"110110",  -- Ch3
        b"101010",  -- Ch4
        b"111010",  -- Ch5
        b"101110",  -- Ch6
        b"111110",  -- Ch7
        b"000010",  -- Pr0, Ch0+
        b"010010",  -- Pr0, Ch1+
        b"000110",  -- Pr1, Ch2+
        b"010110",  -- Pr1, Ch3+
        b"001010",  -- Pr2, Ch4+
        b"011010",  -- Pr2, Ch5+
        b"001110",  -- Pr3, Ch6+
        b"011110"   -- Pr3, Ch7+
    );

begin

    config <= lookup(to_integer(unsigned(index)));

end architecture;
