-- -------------------------------------------------------------
-- 
-- File Name: hdl_prj/hdlsrc/convolutionPlayback/S_R_Flip_Flop_block8.vhd
-- Created: 2024-05-04 23:42:16
-- 
-- Generated by MATLAB 23.2, HDL Coder 23.2, and Simulink 23.2
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: S_R_Flip_Flop_block8
-- Source Path: convolutionPlayback/convolutionPlayback/recordingConvolver/convolutionCore18/S-R Flip Flop
-- Hierarchy Level: 3
-- Model version: 1.104
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.convolutionPlayback_pkg.ALL;

ENTITY S_R_Flip_Flop_block8 IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        enb                               :   IN    std_logic;
        in1                               :   IN    std_logic;
        in2                               :   IN    std_logic;
        out1                              :   OUT   std_logic
        );
END S_R_Flip_Flop_block8;


ARCHITECTURE rtl OF S_R_Flip_Flop_block8 IS

  -- Constants
  CONSTANT S_R_Flip_FlopDirect_Lookup_Table_data : vector_of_unsigned3(0 TO 7) := 
    (to_unsigned(16#1#, 3), to_unsigned(16#2#, 3), to_unsigned(16#1#, 3), to_unsigned(16#1#, 3),
     to_unsigned(16#2#, 3), to_unsigned(16#2#, 3), to_unsigned(16#0#, 3), to_unsigned(16#0#, 3));  -- ufix3 [8]

  -- Signals
  SIGNAL out1_1                           : std_logic;
  SIGNAL Previous_Q                       : std_logic;
  SIGNAL InpCombined                      : unsigned(2 DOWNTO 0);  -- ufix3
  SIGNAL OutCombined                      : unsigned(2 DOWNTO 0);  -- ufix3

BEGIN
  S_R_Flip_Flop_memory_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      Previous_Q <= '0';
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        Previous_Q <= out1_1;
      END IF;
    END IF;
  END PROCESS S_R_Flip_Flop_memory_process;


  InpCombined <= unsigned'(in1 & in2 & Previous_Q);

  OutCombined <= S_R_Flip_FlopDirect_Lookup_Table_data(to_integer(InpCombined));

  out1_1 <= OutCombined(1);

  out1 <= out1_1;

END rtl;

