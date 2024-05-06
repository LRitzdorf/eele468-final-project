-- -------------------------------------------------------------
-- 
-- File Name: hdl_prj/hdlsrc/convolutionPlayback/convolutionCore7.vhd
-- Created: 2024-05-04 23:42:17
-- 
-- Generated by MATLAB 23.2, HDL Coder 23.2, and Simulink 23.2
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: convolutionCore7
-- Source Path: convolutionPlayback/convolutionPlayback/recordingConvolver/convolutionCore7
-- Hierarchy Level: 2
-- Model version: 1.104
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY convolutionCore7 IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        enb                               :   IN    std_logic;
        sample                            :   IN    std_logic_vector(23 DOWNTO 0);  -- sfix24_En23
        preload                           :   IN    std_logic_vector(39 DOWNTO 0);  -- sfix40_En23
        new_sample                        :   IN    std_logic;
        impulse                           :   IN    std_logic_vector(23 DOWNTO 0);  -- sfix24_En23
        new_impulse                       :   IN    std_logic;
        result                            :   OUT   std_logic_vector(39 DOWNTO 0);  -- sfix40_En23
        old_sample                        :   OUT   std_logic_vector(23 DOWNTO 0);  -- sfix24_En23
        valid                             :   OUT   std_logic
        );
END convolutionCore7;


ARCHITECTURE rtl OF convolutionCore7 IS

  ATTRIBUTE multstyle : string;

  -- Component Declarations
  COMPONENT S_R_Flip_Flop_block20
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb                             :   IN    std_logic;
          in1                             :   IN    std_logic;
          in2                             :   IN    std_logic;
          out1                            :   OUT   std_logic
          );
  END COMPONENT;

  COMPONENT DualPortRAM_generic
    GENERIC( AddrWidth                    : integer;
             DataWidth                    : integer
             );
    PORT( clk                             :   IN    std_logic;
          enb                             :   IN    std_logic;
          wr_din                          :   IN    std_logic_vector(DataWidth - 1 DOWNTO 0);  -- generic width
          wr_addr                         :   IN    std_logic_vector(AddrWidth - 1 DOWNTO 0);  -- generic width
          wr_en                           :   IN    std_logic;
          rd_addr                         :   IN    std_logic_vector(AddrWidth - 1 DOWNTO 0);  -- generic width
          wr_dout                         :   OUT   std_logic_vector(DataWidth - 1 DOWNTO 0);  -- generic width
          rd_dout                         :   OUT   std_logic_vector(DataWidth - 1 DOWNTO 0)  -- generic width
          );
  END COMPONENT;

  COMPONENT Detect_Rise_Positive_block21
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb                             :   IN    std_logic;
          U                               :   IN    std_logic;
          Y                               :   OUT   std_logic
          );
  END COMPONENT;

  -- Component Configuration Statements
  FOR ALL : S_R_Flip_Flop_block20
    USE ENTITY work.S_R_Flip_Flop_block20(rtl);

  FOR ALL : DualPortRAM_generic
    USE ENTITY work.DualPortRAM_generic(rtl);

  FOR ALL : Detect_Rise_Positive_block21
    USE ENTITY work.Detect_Rise_Positive_block21(rtl);

  -- Signals
  SIGNAL new_sample_1                     : std_logic;
  SIGNAL new_sample_2                     : std_logic;
  SIGNAL count_step                       : unsigned(10 DOWNTO 0);  -- ufix11
  SIGNAL count_from                       : unsigned(10 DOWNTO 0);  -- ufix11
  SIGNAL count_reset                      : unsigned(10 DOWNTO 0);  -- ufix11
  SIGNAL zero_1                           : std_logic;
  SIGNAL count                            : unsigned(10 DOWNTO 0);  -- ufix11
  SIGNAL range_hit                        : std_logic;
  SIGNAL count_1                          : unsigned(10 DOWNTO 0);  -- ufix11
  SIGNAL need_to_wrap                     : std_logic;
  SIGNAL count_value                      : unsigned(10 DOWNTO 0);  -- ufix11
  SIGNAL S_R_Flip_Flop_out1               : std_logic;
  SIGNAL count_2                          : unsigned(10 DOWNTO 0);  -- ufix11
  SIGNAL count_3                          : unsigned(10 DOWNTO 0);  -- ufix11
  SIGNAL count_hit                        : std_logic;
  SIGNAL ReadIndex_out2                   : std_logic;
  SIGNAL S_R_Flip_Flop_out1_1             : std_logic;
  SIGNAL S_R_Flip_Flop_out1_2             : std_logic;
  SIGNAL preload_signed                   : signed(39 DOWNTO 0);  -- sfix40_En23
  SIGNAL preload_1                        : signed(39 DOWNTO 0);  -- sfix40_En23
  SIGNAL count_step_1                     : unsigned(10 DOWNTO 0);  -- ufix11
  SIGNAL count_4                          : unsigned(10 DOWNTO 0);  -- ufix11
  SIGNAL count_5                          : unsigned(10 DOWNTO 0);  -- ufix11
  SIGNAL count_6                          : unsigned(10 DOWNTO 0);  -- ufix11
  SIGNAL Add1_stage2_sub_cast             : signed(12 DOWNTO 0);  -- sfix13
  SIGNAL Add1_stage2_sub_cast_1           : signed(12 DOWNTO 0);  -- sfix13
  SIGNAL Add1_stage2_sub_temp             : signed(12 DOWNTO 0);  -- sfix13
  SIGNAL Add1_op_stage1                   : signed(11 DOWNTO 0);  -- sfix12
  SIGNAL Constant_out1                    : unsigned(10 DOWNTO 0);  -- ufix11
  SIGNAL Add1_stage3_sub_cast             : signed(12 DOWNTO 0);  -- sfix13
  SIGNAL Add1_stage3_sub_temp             : signed(12 DOWNTO 0);  -- sfix13
  SIGNAL Add1_out1                        : unsigned(10 DOWNTO 0);  -- ufix11
  SIGNAL conv_data                        : std_logic_vector(23 DOWNTO 0);  -- ufix24
  SIGNAL StreamRAM_out2                   : std_logic_vector(23 DOWNTO 0);  -- ufix24
  SIGNAL count_step_2                     : unsigned(10 DOWNTO 0);  -- ufix11
  SIGNAL count_7                          : unsigned(10 DOWNTO 0);  -- ufix11
  SIGNAL count_8                          : unsigned(10 DOWNTO 0);  -- ufix11
  SIGNAL count_9                          : unsigned(10 DOWNTO 0);  -- ufix11
  SIGNAL Add2_stage2_add_cast             : signed(12 DOWNTO 0);  -- sfix13
  SIGNAL Add2_stage2_add_cast_1           : signed(12 DOWNTO 0);  -- sfix13
  SIGNAL Add2_stage2_add_temp             : signed(12 DOWNTO 0);  -- sfix13
  SIGNAL Add2_op_stage1                   : unsigned(11 DOWNTO 0);  -- ufix12
  SIGNAL Constant1_out1                   : unsigned(10 DOWNTO 0);  -- ufix11
  SIGNAL Add2_stage3_sub_cast             : signed(12 DOWNTO 0);  -- sfix13
  SIGNAL Add2_stage3_sub_cast_1           : signed(12 DOWNTO 0);  -- sfix13
  SIGNAL Add2_stage3_sub_temp             : signed(12 DOWNTO 0);  -- sfix13
  SIGNAL Add2_out1                        : unsigned(10 DOWNTO 0);  -- ufix11
  SIGNAL StreamRAM_out2_signed            : signed(23 DOWNTO 0);  -- sfix24_En23
  SIGNAL conv_data_1                      : std_logic_vector(23 DOWNTO 0);  -- ufix24
  SIGNAL ImpulseRAM_out2                  : std_logic_vector(23 DOWNTO 0);  -- ufix24
  SIGNAL ImpulseRAM_out2_signed           : signed(23 DOWNTO 0);  -- sfix24_En23
  SIGNAL mulOutput                        : signed(47 DOWNTO 0);  -- sfix48_En46
  SIGNAL Switch1_out1                     : signed(39 DOWNTO 0);  -- sfix40_En23
  SIGNAL Saturation1_out1                 : signed(39 DOWNTO 0);  -- sfix40_En23
  SIGNAL Switch2_out1                     : signed(39 DOWNTO 0);  -- sfix40_En23
  SIGNAL Switch2_out1_1                   : signed(39 DOWNTO 0);  -- sfix40_En23
  SIGNAL MultiplyAccumulator_add_add_cast : signed(63 DOWNTO 0);  -- sfix64_En46
  SIGNAL MultiplyAccumulator_add_add_cast_1 : signed(63 DOWNTO 0);  -- sfix64_En46
  SIGNAL MultiplyAccumulator_out1         : signed(63 DOWNTO 0);  -- sfix64_En46
  SIGNAL dtc_out                          : signed(39 DOWNTO 0);  -- sfix40_En23
  SIGNAL Detect_Rise_Positive_out1        : std_logic;

  ATTRIBUTE multstyle OF mulOutput : SIGNAL IS "dsp";

BEGIN
  -- Cycle Counter
  -- Accumulator Cycle
  -- Impulse Storage
  -- Sample Storage

  u_S_R_Flip_Flop_inst : S_R_Flip_Flop_block20
    PORT MAP( clk => clk,
              reset => reset,
              enb => enb,
              in1 => new_sample_1,
              in2 => ReadIndex_out2,
              out1 => S_R_Flip_Flop_out1_1
              );

  u_StreamRAM : DualPortRAM_generic
    GENERIC MAP( AddrWidth => 11,
                 DataWidth => 24
                 )
    PORT MAP( clk => clk,
              enb => enb,
              wr_din => sample,
              wr_addr => std_logic_vector(count_4),
              wr_en => new_sample_1,
              rd_addr => std_logic_vector(Add1_out1),
              wr_dout => conv_data,
              rd_dout => StreamRAM_out2
              );

  u_ImpulseRAM : DualPortRAM_generic
    GENERIC MAP( AddrWidth => 11,
                 DataWidth => 24
                 )
    PORT MAP( clk => clk,
              enb => enb,
              wr_din => impulse,
              wr_addr => std_logic_vector(count_7),
              wr_en => new_impulse,
              rd_addr => std_logic_vector(Add2_out1),
              wr_dout => conv_data_1,
              rd_dout => ImpulseRAM_out2
              );

  u_Detect_Rise_Positive : Detect_Rise_Positive_block21
    PORT MAP( clk => clk,
              reset => reset,
              enb => enb,
              U => ReadIndex_out2,
              Y => Detect_Rise_Positive_out1
              );

  rd_0_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      new_sample_1 <= '0';
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        new_sample_1 <= new_sample;
      END IF;
    END IF;
  END PROCESS rd_0_process;


  rd_6_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      new_sample_2 <= '0';
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        new_sample_2 <= new_sample_1;
      END IF;
    END IF;
  END PROCESS rd_6_process;


  -- Count limited, Unsigned Counter
  --  initial value   = 0
  --  step value      = 1
  --  count to value  = 1999
  count_step <= to_unsigned(16#001#, 11);

  count_from <= to_unsigned(16#000#, 11);

  count_reset <= to_unsigned(16#000#, 11);

  zero_1 <= '0';

  
  range_hit <= '1' WHEN count > to_unsigned(16#7FE#, 11) ELSE
      '0';

  count_1 <= count + count_step;

  
  count_value <= count_1 WHEN need_to_wrap = '0' ELSE
      count_from;

  
  count_2 <= count WHEN S_R_Flip_Flop_out1 = '0' ELSE
      count_value;

  
  count_3 <= count_2 WHEN new_sample_1 = '0' ELSE
      count_reset;

  rd_3_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      count <= to_unsigned(16#000#, 11);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        count <= count_3;
      END IF;
    END IF;
  END PROCESS rd_3_process;


  
  need_to_wrap <= '1' WHEN count = to_unsigned(16#7CF#, 11) ELSE
      '0';

  count_hit <= need_to_wrap OR range_hit;

  
  ReadIndex_out2 <= count_hit WHEN new_sample_1 = '0' ELSE
      zero_1;

  rd_2_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      S_R_Flip_Flop_out1 <= '0';
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        S_R_Flip_Flop_out1 <= S_R_Flip_Flop_out1_1;
      END IF;
    END IF;
  END PROCESS rd_2_process;


  rd_7_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      S_R_Flip_Flop_out1_2 <= '0';
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        S_R_Flip_Flop_out1_2 <= S_R_Flip_Flop_out1;
      END IF;
    END IF;
  END PROCESS rd_7_process;


  preload_signed <= signed(preload);

  rd_5_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      preload_1 <= to_signed(0, 40);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        preload_1 <= preload_signed;
      END IF;
    END IF;
  END PROCESS rd_5_process;


  -- Free running, Unsigned Counter
  --  initial value   = 0
  --  step value      = 1
  count_step_1 <= to_unsigned(16#001#, 11);

  count_5 <= count_4 + count_step_1;

  
  count_6 <= count_4 WHEN new_sample_1 = '0' ELSE
      count_5;

  rd_1_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      count_4 <= to_unsigned(16#000#, 11);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        count_4 <= count_6;
      END IF;
    END IF;
  END PROCESS rd_1_process;


  Add1_stage2_sub_cast <= signed(resize(count_4, 13));
  Add1_stage2_sub_cast_1 <= signed(resize(count, 13));
  Add1_stage2_sub_temp <= Add1_stage2_sub_cast - Add1_stage2_sub_cast_1;
  Add1_op_stage1 <= Add1_stage2_sub_temp(11 DOWNTO 0);

  Constant_out1 <= to_unsigned(16#001#, 11);

  Add1_stage3_sub_cast <= signed(resize(Constant_out1, 13));
  Add1_stage3_sub_temp <= resize(Add1_op_stage1, 13) - Add1_stage3_sub_cast;
  Add1_out1 <= unsigned(Add1_stage3_sub_temp(10 DOWNTO 0));

  -- Free running, Unsigned Counter
  --  initial value   = 0
  --  step value      = 1
  count_step_2 <= to_unsigned(16#001#, 11);

  count_8 <= count_7 + count_step_2;

  
  count_9 <= count_7 WHEN new_impulse = '0' ELSE
      count_8;

  rd_4_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      count_7 <= to_unsigned(16#000#, 11);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        count_7 <= count_9;
      END IF;
    END IF;
  END PROCESS rd_4_process;


  Add2_stage2_add_cast <= signed(resize(count_7, 13));
  Add2_stage2_add_cast_1 <= signed(resize(count, 13));
  Add2_stage2_add_temp <= Add2_stage2_add_cast + Add2_stage2_add_cast_1;
  Add2_op_stage1 <= unsigned(Add2_stage2_add_temp(11 DOWNTO 0));

  Constant1_out1 <= to_unsigned(16#7D0#, 11);

  Add2_stage3_sub_cast <= signed(resize(Add2_op_stage1, 13));
  Add2_stage3_sub_cast_1 <= signed(resize(Constant1_out1, 13));
  Add2_stage3_sub_temp <= Add2_stage3_sub_cast - Add2_stage3_sub_cast_1;
  Add2_out1 <= unsigned(Add2_stage3_sub_temp(10 DOWNTO 0));

  StreamRAM_out2_signed <= signed(StreamRAM_out2);

  ImpulseRAM_out2_signed <= signed(ImpulseRAM_out2);

  mulOutput <= StreamRAM_out2_signed * ImpulseRAM_out2_signed;

  
  Switch2_out1 <= Switch1_out1 WHEN S_R_Flip_Flop_out1_2 = '0' ELSE
      Saturation1_out1;

  rd_8_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      Switch2_out1_1 <= to_signed(0, 40);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        Switch2_out1_1 <= Switch2_out1;
      END IF;
    END IF;
  END PROCESS rd_8_process;


  
  Switch1_out1 <= Switch2_out1_1 WHEN new_sample_2 = '0' ELSE
      preload_1;

  MultiplyAccumulator_add_add_cast <= resize(Switch1_out1 & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 64);
  MultiplyAccumulator_add_add_cast_1 <= resize(mulOutput, 64);
  MultiplyAccumulator_out1 <= MultiplyAccumulator_add_add_cast + MultiplyAccumulator_add_add_cast_1;

  
  dtc_out <= X"7FFFFFFFFF" WHEN (MultiplyAccumulator_out1(63) = '0') AND (MultiplyAccumulator_out1(62) /= '0') ELSE
      X"8000000000" WHEN (MultiplyAccumulator_out1(63) = '1') AND (MultiplyAccumulator_out1(62) /= '1') ELSE
      MultiplyAccumulator_out1(62 DOWNTO 23);

  
  Saturation1_out1 <= to_signed(8388607, 40) WHEN dtc_out > to_signed(8388607, 40) ELSE
      to_signed(-8388608, 40) WHEN dtc_out < to_signed(-8388608, 40) ELSE
      dtc_out;

  result <= std_logic_vector(Saturation1_out1);

  old_sample <= StreamRAM_out2;

  valid <= Detect_Rise_Positive_out1;

END rtl;

