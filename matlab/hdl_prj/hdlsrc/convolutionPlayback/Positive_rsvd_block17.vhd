-- -------------------------------------------------------------
-- 
-- File Name: hdl_prj/hdlsrc/convolutionPlayback/Positive_rsvd_block17.vhd
-- Created: 2024-05-04 23:42:17
-- 
-- Generated by MATLAB 23.2, HDL Coder 23.2, and Simulink 23.2
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: Positive_rsvd_block17
-- Source Path: convolutionPlayback/convolutionPlayback/recordingConvolver/convolutionCore3/Detect Rise Positive/Positive
-- Hierarchy Level: 4
-- Model version: 1.104
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Positive_rsvd_block17 IS
  PORT( u                                 :   IN    std_logic;
        y                                 :   OUT   std_logic
        );
END Positive_rsvd_block17;


ARCHITECTURE rtl OF Positive_rsvd_block17 IS

  -- Signals
  SIGNAL Constant_out1                    : std_logic;
  SIGNAL Compare_relop1                   : std_logic;

BEGIN
  Constant_out1 <= '0';

  
  Compare_relop1 <= '1' WHEN u > Constant_out1 ELSE
      '0';

  y <= Compare_relop1;

END rtl;

