-- Create Date: 07/10/2026
-- Module Name: alu_constants
-- Target Devices: XCZU3EG-2SFVC784E
-- Tool Versions: vivado 26.1
-- Description: 
-- Constants to parameterize ALU records and memory formats

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

PACKAGE codec_constants is
constant expon_sz: integer :=  9;  -- ALU exponent width is 9 bits, to support Takums
constant frac_sz:  integer := 12;  -- ALU fraction width is 12 bits, includes half (HUB) bit & 11 Takum bits
constant mem_sz:   integer := 16;  -- codes operate to/from 16-bit memory

--constant expon_max: integer(std_logic_vector(expon_sz-1:0) := '0' & others=> '1');  -- max non-overflow exponent
--constant expon_min: integer(std_logic_vector(expon_sz-1:0) := '1' & others=> '0');  -- min non-underflow exponent
constant expon_max: signed(expon_sz downto 0) := "0111111111";  -- max non-overflow exponent
constant expon_min: signed(expon_sz downto 0) := "1000000000";  -- min non-underflow exponent
--END codec_constants;

----PACKAGE alu_record_type is
--type alu_record is record
--      sign:   std_logic;
--      znan:   std_logic;  -- zero or NAR
--      expon:  signed(expon_sz downto 0);  -- signed for ease of expansion (additional overflow bit)
--      mant:   unsigned(mant_sz downto 0);
-- end record alu_record;
-- END alu_record_type;
-- END package alu_record_type;
END codec_constants;
