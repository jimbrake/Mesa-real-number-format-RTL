----------------------------------------------------------------------------------
-- Create Date: 08/22/2026
-- Module Name: ns_ld_nmesa16 - Behavioral
-- Target Devices: XCZU3EG-2SFVC784E
-- Tool Versions: vivado 26.1
-- Description: 
-- Convert narrow mesa16 standard to ALU record, half-bit clear
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

entity ns_ld_nmesa16 is Port (
    clk    		: in STD_LOGIC;
    alu_in		: out t_alu_record; 			-- zero-nar, sign, exp, msb, fract   to register
    mem_out    	: in unsigned (15 downto 0));	-- sign, exp, implicit msb, fract    from register
end ns_ld_nmesa16;

architecture RTL of ns_ld_nmesa16 is
signal alu_temp    : t_alu_record;
-- input breakout
signal memreg       : unsigned (15 downto 0);
signal mem_sign     : std_logic;
signal mem_exp      : signed(4 downto 0);
signal mem_frac     : unsigned(9 downto 0);
--signal zeros_cnt	: unsigned(3 downto 0);	-- memory fraction of all ones gives a count of zero and ranges up to nine

begin
mem_sign <= memreg(15);
mem_exp  <= signed(not (memreg(14)) & memreg(13 downto 10));	-- convert from biased to 2's complement
mem_frac <= memreg(9 downto 0);

RTL: process (all) begin

alu_temp.znan <= '0';
alu_temp.sign  <= mem_sign;
alu_temp.frac <= '1' & mem_frac & "00"; -- prefix leading one bit, sufffix zeros & zero HUB bit
if mem_exp = "00000" and mem_frac = "0000000000" then alu_temp.znan <= '1'; end if;

-- handle gradual underflow and gradula overflow, clear one bit that terminates zeros count
if memreg(14 downto 10) = "00000" and mem_frac /= "0000000000" then 
	if    mem_frac(0) = '1' then alu_temp.expon <= "1111110000"; alu_temp.frac(2)<='0';
	elsif mem_frac(1) = '1' then alu_temp.expon <= "1111101111"; alu_temp.frac(3)<='0';
	elsif mem_frac(2) = '1' then alu_temp.expon <= "1111101110"; alu_temp.frac(4)<='0';
	elsif mem_frac(3) = '1' then alu_temp.expon <= "1111101101"; alu_temp.frac(5)<='0';
	elsif mem_frac(4) = '1' then alu_temp.expon <= "1111101100"; alu_temp.frac(6)<='0';
	elsif mem_frac(5) = '1' then alu_temp.expon <= "1111101011"; alu_temp.frac(7)<='0';
	elsif mem_frac(6) = '1' then alu_temp.expon <= "1111101010"; alu_temp.frac(8)<='0';
	elsif mem_frac(7) = '1' then alu_temp.expon <= "1111101001"; alu_temp.frac(9)<='0';
	elsif mem_frac(8) = '1' then alu_temp.expon <= "1111101000"; alu_temp.frac(10)<='0';
	else                         alu_temp.expon <= "1111100111"; alu_temp.frac(11)<='0';
	end if;
elsif memreg(14 downto 10) = "11111" then 
	if    mem_frac(0) = '1' then alu_temp.expon <= "0000010000"; alu_temp.frac(2)<='0';
	elsif mem_frac(1) = '1' then alu_temp.expon <= "0000010001"; alu_temp.frac(3)<='0';
	elsif mem_frac(2) = '1' then alu_temp.expon <= "0000010010"; alu_temp.frac(4)<='0';
	elsif mem_frac(3) = '1' then alu_temp.expon <= "0000010011"; alu_temp.frac(5)<='0';
	elsif mem_frac(4) = '1' then alu_temp.expon <= "0000010100"; alu_temp.frac(6)<='0';
	elsif mem_frac(5) = '1' then alu_temp.expon <= "0000010101"; alu_temp.frac(7)<='0';
	elsif mem_frac(6) = '1' then alu_temp.expon <= "0000010110"; alu_temp.frac(8)<='0';
	elsif mem_frac(7) = '1' then alu_temp.expon <= "0000010111"; alu_temp.frac(9)<='0';
	elsif mem_frac(8) = '1' then alu_temp.expon <= "0000011000"; alu_temp.frac(10)<='0';
	else                         alu_temp.expon <= "0000011001"; alu_temp.frac(11)<='0';
	end if;
else alu_temp.expon <= resize(mem_exp,expon_sz + 1);
end if;

--alu_temp.frac(12) <= '1';
--alu_temp.frac(1 downto 0) <= "00"; -- prefix leading one bit, sufffix zeros & zero HUB bit
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
