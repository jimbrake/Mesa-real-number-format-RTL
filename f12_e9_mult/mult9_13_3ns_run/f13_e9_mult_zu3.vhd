----------------------------------------------------------------------------------
-- Create Date: 06/18/2026 10:38 PM
-- Module Name: f13_e9_mult_zu3 - Behavioral
-- Target Devices: XCZU3EG-2SFVC784E
-- Tool Versions: vivado 26.1
-- Description: 
-- Regiter to register single cycle ALU multiply, round inexact to odd
-- NaR/zero bit and saturation bit included (24-bits total)
-- Implicit leading one bit not incldued
-- Sign, unsigned biased exponent and unsigned fraction
-- Revision:
-- Revision 0.01 - File Created
-- Revision 1.00 - initial draft 260710
-- Revision 1.10 - initial reasonable LUT, FF & DSP counts 260727
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.codec_constants.all;
use work.t_alu_record.all;

entity f13_e9_mult_zu3 is Port(
    clk         : in std_logic;
    operanda    : in t_alu_record;   -- zero-nar, sign, exp, fract, half bit; extra exp bit & mant bit
    operandb    : in t_alu_record;   -- zero-nar, sign, exp, fract, half bit; extra exp bit & mant bit
    result		: out t_alu_record);  -- znan, sign, exp++, 1.fract
end f13_e9_mult_zu3;

architecture RTL of f13_e9_mult_zu3 is
--		intermediate signals
signal product_temp:	unsigned(frac_sz * 2 + 1 downto 0);
signal exp_temp: signed(expon_sz downto 0);
signal alu_ina, alu_inb, alu_out:  t_alu_record;  -- registered input values and output value

begin
product_temp	<= unsigned(alu_ina.frac)  *  unsigned(alu_inb.frac);  -- included hidden leading one bits

RTL: process (all) begin
--		default signal values
alu_out.znan 	<= '0';
alu_out.sign	<= alu_ina.sign xor alu_inb.sign;
exp_temp    	<= alu_ina.expon  + alu_inb.expon;
alu_out.frac    <= product_temp(frac_sz*2-1 downto frac_sz-1);

--      combinatorial logic
if product_temp(frac_sz*2+1) = '0' 		-- normalize fraction if needed
	then alu_out.frac <= product_temp(frac_sz*2 downto frac_sz); end if; -- avoid LUT logic loop

if product_temp(frac_sz*2+1) = '0' then alu_out.expon <= exp_temp; else alu_out.expon <= exp_temp + 1; end if;

if product_temp(frac_sz downto 0) /= 0 then alu_out.frac(0) <= '1'; end if;    -- round inexact result to odd

if (alu_ina.znan = '1') or (alu_inb.znan = '1') then    alu_out.znan <= '1';			  -- insert zero/NaR
		if (alu_ina.sign = '1') or (alu_inb.sign = '1') then alu_out.sign <= '1'; end if;  -- negative if either NAR, positive if both zero
	end if;
-- 		saturation tests & fraction update
if exp_temp >= expon_max then alu_out.expon <= expon_max; alu_out.frac <= (others => '1'); end if;	-- upper limit
if exp_temp <  expon_min then alu_out.expon <= expon_min; alu_out.frac <= (others => '1'); end if;	-- lower limit
end process;

update: process(clk)
  begin
    if rising_edge(clk) then alu_ina <= operanda; alu_inb <= operandb; result <= alu_out; end if;
end process;

end RTL;
