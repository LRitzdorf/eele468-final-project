-- -------------------------------------------------------------
-- 
-- File Name: hdl_prj/hdlsrc/convolutionPlayback/Detect_Rise_Positive_block3.vhd
-- Created: 2024-05-04 23:42:16
-- 
-- Generated by MATLAB 23.2, HDL Coder 23.2, and Simulink 23.2
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: Detect_Rise_Positive_block3
-- Source Path: convolutionPlayback/convolutionPlayback/recordingConvolver/convolutionCore12/Detect Rise Positive
-- Hierarchy Level: 3
-- Model version: 1.104
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Detect_Rise_Positive_block3 IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        enb                               :   IN    std_logic;
        U                                 :   IN    std_logic;
        Y                                 :   OUT   std_logic
        );
END Detect_Rise_Positive_block3;


ARCHITECTURE rtl OF Detect_Rise_Positive_block3 IS

  -- Component Declarations
  COMPONENT Positive_rsvd_block3
    PORT( u                               :   IN    std_logic;
          y                               :   OUT   std_logic
          );
  END COMPONENT;

  -- Component Configuration Statements
  FOR ALL : Positive_rsvd_block3
    USE ENTITY work.Positive_rsvd_block3(rtl);

  -- Signals
  SIGNAL U_k                              : std_logic;
  SIGNAL U_k_1                            : std_logic;
  SIGNAL U_k_1_1                          : std_logic;
  SIGNAL FixPt_Relational_Operator_relop1 : std_logic;

BEGIN
  -- U(k)
  -- Edge

  u_Positive : Positive_rsvd_block3
    PORT MAP( u => U,
              y => U_k
              );

  -- 
  -- Store in Global RAM
  U_k_1 <= U_k;

  rd_0_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      U_k_1_1 <= '0';
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        U_k_1_1 <= U_k_1;
      END IF;
    END IF;
  END PROCESS rd_0_process;


  
  FixPt_Relational_Operator_relop1 <= '1' WHEN U_k > U_k_1_1 ELSE
      '0';

  Y <= FixPt_Relational_Operator_relop1;

END rtl;

