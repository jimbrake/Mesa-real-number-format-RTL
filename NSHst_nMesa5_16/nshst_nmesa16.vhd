----------------------------------------------------------------------------------
-- Create Date: 08/13/2026 10:10 PM
-- Module Name: nshst_nmesa5_16 - Behavioral
-- Target Devices: XCZU3EG-2SFVC784E
-- Tool Versions: vivado 26.1
-- Description: 
-- Convert ALU e9 f13 to narrow e5 f10 with zero & NAR, do saturation, HUB version
-- ALU register: z/nzr, sign, exp(8..0), msb, fract(11..1), half-bit
-- Narrow Mesa: sign, exp(4..0), fract(9...0) implicit leading 1.0 bit and implicit '1' trailing half-bit
-- Revision:
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.codec_constants.all;
use work.t_alu_record.all;

entity nshst_nmesa16 is Port (
    clk    : in STD_LOGIC;
    alu    : in t_alu_record;   -- zero-nar, sign, signed exp, fract, half bit; extra exp bit & mant bit
    memhub : out unsigned (15 downto 0)); -- sign, biased exp, implicit msb, fract, implicit HUB
end nshst_nmesa16;

architecture RTL of nshst_nmesa16 is
signal alureg    : t_alu_record;
-- input breakout
--signal zero_nar             : std_logic;
--signal alu_sign             : std_logic;
--signal alu_exp, alu_exp2    : unsigned(8 downto 0);
--signal alu_fract, alu_fract2: unsigned(12 downto 0);
-- output breakout
signal mem_sign     : std_logic;
signal mem_exp      : unsigned(4 downto 0);
signal mem_fract    : unsigned(9 downto 0);


begin
-- disassemble ALU
--zero_nar  <= alureg.znan;
--alu_sign  <= alureg.sign;
--alu_exp   <= unsigned(alureg.expon);
--alu_fract <= '1' & unsigned(alureg(11 downto 0)); -- prefix leading one bit, use half-bit in rounding

RTL: process (all) begin
--		default signal values
mem_sign  <= alureg.sign;
mem_exp   <= unsigned(not(alureg.expon(4)) & alureg.expon(3 downto 0));  -- for non-under/overflow
mem_fract <= alureg.frac(11 downto 2);      -- drop LSBs & implicit leading one bit
--      combinatorial logic
if alureg.znan = '1'                   then mem_exp <= "00000"; mem_fract <= "0000000000"; -- inset zero/NaR
elsif  alureg.expon >= "0000010010"    then mem_exp <= "11111"; mem_fract <= "0000000000"; -- check for saturation                     
elsif alureg.expon(4 downto 0)="10000" then mem_exp <= "11111"; mem_fract(9 downto 0)<= "1000000000";
elsif alureg.expon(4 downto 0)="01111" then mem_exp <= "11111"; mem_fract(8 downto 0)<= "100000000";
elsif alureg.expon(4 downto 0)="01110" then mem_exp <= "11111"; mem_fract(7 downto 0)<= "10000000";
elsif alureg.expon(4 downto 0)="01101" then mem_exp <= "11111"; mem_fract(6 downto 0)<= "1000000";
elsif alureg.expon(4 downto 0)="01100" then mem_exp <= "11111"; mem_fract(5 downto 0)<= "100000";
elsif alureg.expon(4 downto 0)="01011" then mem_exp <= "11111"; mem_fract(4 downto 0)<= "10000";
elsif alureg.expon(4 downto 0)="01010" then mem_exp <= "11111"; mem_fract(3 downto 0)<= "1000";
elsif alureg.expon(4 downto 0)="01001" then mem_exp <= "11111"; mem_fract(2 downto 0)<= "100";
elsif alureg.expon(4 downto 0)="01000" then mem_exp <= "11111"; mem_fract(1 downto 0)<= "10";
elsif alureg.expon(4 downto 0)="10001" then mem_exp <= "11111"; mem_fract(0)         <= '1';
elsif  alureg.expon <  "1111101110" then  -- check for underflow
    if    alureg.expon(4 downto 0)="00110" then mem_exp <= "00000"; mem_fract(9 downto 0)<= "1000000000";
    elsif alureg.expon(4 downto 0)="00111" then mem_exp <= "00000"; mem_fract(8 downto 0)<= "100000000";
    elsif alureg.expon(4 downto 0)="01000" then mem_exp <= "00000"; mem_fract(7 downto 0)<= "10000000";
    elsif alureg.expon(4 downto 0)="01001" then mem_exp <= "00000"; mem_fract(6 downto 0)<= "1000000";
    elsif alureg.expon(4 downto 0)="01010" then mem_exp <= "00000"; mem_fract(5 downto 0)<= "100000";
    elsif alureg.expon(4 downto 0)="01011" then mem_exp <= "00000"; mem_fract(4 downto 0)<= "10000";
    elsif alureg.expon(4 downto 0)="01100" then mem_exp <= "00000"; mem_fract(3 downto 0)<= "1000";
    elsif alureg.expon(4 downto 0)="01101" then mem_exp <= "00000"; mem_fract(2 downto 0)<= "100";
    elsif alureg.expon(4 downto 0)="01110" then mem_exp <= "00000"; mem_fract(1 downto 0)<= "10";
    else                                        mem_exp <= "00000"; mem_fract(0)         <= '1';
    end if;
end if;
end process;

update: process(clk)	-- register, register file, memory & state signal updates
begin
if (rising_edge(clk)) then 
    memhub <= mem_sign & mem_exp & mem_fract;   -- for HUB implicit trailing one bit
    alureg <= alu;  -- register input
    end if;
end process;
end RTL;
