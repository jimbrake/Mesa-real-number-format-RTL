----------------------------------------------------------------------------------
-- Create Date: 08/22/2026
-- Module Name: nshld_nmesa16 - Behavioral
-- Target Devices: XCZU3EG-2SFVC784E
-- Tool Versions: vivado 26.1
-- Description: 
-- Convert narrow mesa16 HUB to ALU record
-- ALU register: z/nar, sign, signed exp(8..0), msb, fract(11..1), half-bit
-- memory format nmesa: sign & exp(4..0) & fract(9...0) implicit leading 1.0 bit and implicit trailing half-bit
-- gradual underflow at exp=0 & 31, fracion with trailing zero count, not including half bit
-- zero, NAR and +/-1.0 do not have the HUB bit set, +/- 1.0 at maximum fraction & exponent
-- input and output registers for timing info, 
-- Revision:
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.codec_constants.all;
use work.t_alu_record.all;

entity nshld_nmesa16 is Port (
    clk    		: in STD_LOGIC;
    alu_in		: out t_alu_record; 			-- zero-nar, sign, exp, msb, fract   to register
    mem_out    	: in unsigned (15 downto 0));	-- sign, exp, implicit msb, fract    from register
end nshld_nmesa16;

architecture RTL of nshld_nmesa16 is
signal alu_temp    : t_alu_record;
-- input breakout
signal memreg       : unsigned (15 downto 0);
signal mem_sign     : std_logic;
signal mem_exp      : signed(4 downto 0);
signal mem_frac     : unsigned(9 downto 0);

begin
mem_sign <= memreg(15);
mem_exp  <= signed(not (memreg(14)) & memreg(13 downto 10));	-- convert from biased to 2's complement
mem_frac <= memreg(9 downto 0);

RTL: process (all) begin

alu_temp.sign  <= mem_sign;
alu_temp.znan <= '0';
if mem_exp = "00000" and mem_frac = "0000000000" then alu_temp.znan <= '1'; end if;
alu_temp.expon <= resize(signed(mem_exp),expon_sz + 1);  -- extend exponent sign
alu_temp.frac  <= unsigned('1' & mem_frac & "10"); -- prefix leading one bit, suffix HUB bit and zero bit

-- handle gradual underflow and gradula overflow
if memreg(14 downto 10) = "00000" and mem_frac /= "0000000000" then 
    alu_temp.frac(1) <= '0';    -- fraction has HUB bit
    if    mem_frac(0) = '1' then alu_temp.expon <= "1111110000";
	elsif mem_frac(1) = '1' then alu_temp.expon <= "1111101111";
	elsif mem_frac(2) = '1' then alu_temp.expon <= "1111101110";
	elsif mem_frac(3) = '1' then alu_temp.expon <= "1111101101";
	elsif mem_frac(4) = '1' then alu_temp.expon <= "1111101100";
	elsif mem_frac(5) = '1' then alu_temp.expon <= "1111101011";
	elsif mem_frac(6) = '1' then alu_temp.expon <= "1111101010";
	elsif mem_frac(7) = '1' then alu_temp.expon <= "1111101001";
	elsif mem_frac(8) = '1' then alu_temp.expon <= "1111101000";
	else                         alu_temp.expon <= "1111100111";
	end if;
elsif memreg(14 downto 10) = "11111" then 
    alu_temp.frac(1) <= '0';    -- fraction has HUB bit	
    if    mem_frac(0) = '1' then alu_temp.expon <= "0000010000";
	elsif mem_frac(1) = '1' then alu_temp.expon <= "0000010001";
	elsif mem_frac(2) = '1' then alu_temp.expon <= "0000010010";
	elsif mem_frac(3) = '1' then alu_temp.expon <= "0000010011";
	elsif mem_frac(4) = '1' then alu_temp.expon <= "0000010100";
	elsif mem_frac(5) = '1' then alu_temp.expon <= "0000010101";
	elsif mem_frac(6) = '1' then alu_temp.expon <= "0000010110";
	elsif mem_frac(7) = '1' then alu_temp.expon <= "0000010111";
	elsif mem_frac(8) = '1' then alu_temp.expon <= "0000011000";
	else                         alu_temp.expon <= "0000011001";
	end if;
 end if;

if mem_exp = "11111" and mem_frac = "1111111111" then  -- handle +/- 1.0
    alu_temp.frac <= "1000000000000"; 
    alu_temp.expon <= "0100000000"; end if;
    
end process;

update: process(clk)	-- memory & alu register updates
begin
if (rising_edge(clk)) then 
    alu_in  <= alu_temp;
    memreg <= mem_out; end if;
end process;
end RTL;
