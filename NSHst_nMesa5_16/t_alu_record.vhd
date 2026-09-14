-- Create Date: 07/10/2026
-- Module Name: alu_record - Behavioral
-- Target Devices: XCZU3EG-2SFVC784E
-- Tool Versions: vivado 26.1
-- Description: 
-- ALU record type
-- field sizes from codec_constants.vhd
-- ALU has an additional exponent bit to catch over/under flow
-- ALU has an additional mantissa bit to support the hidden leading one bit
-- ALU exponent is two's complement

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.codec_constants.all;

package t_alu_record is
    -- Define the record type
    type t_alu_record is record
      sign:   std_logic;
      znan:   std_logic;  -- zero or NAR
      expon:  signed(expon_sz downto 0);  -- signed for ease of expansion (additional overflow bit)
      frac:   unsigned(frac_sz downto 0);  -- include hidden leading bit
 end record;

--    -- Optional: Define a constant for easy resetting/initialization
--    constant alu_rec_init : alu_record := (
--        sign   => '0',
--        znan   => '0'
--        expon  => (others => '0'),
--        mant   => (others => '0'),
-- );
end package t_alu_record;