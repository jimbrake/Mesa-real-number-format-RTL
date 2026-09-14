----------------------------------------------------------------------------------
-- Create Date: 06/04/2026 10:21:58 PM
-- Module Name:NS_st_pedestal16_zu3 - Behavioral
-- Target Devices: XCZU3EG-2SFVC784E
-- Tool Versions: vivado 25.2
-- Description: 
-- Convert ALU e9 f13 to pedestal e8 f7 with zero & NAR, do saturation, round ties to even
-- ALU register: z/nzr, sign, exp(8..0), msb, fract(11..1), hlf-bit
-- Pedestal: sign, exp(7..0), fract(6...0) implicit leading 1.0 bit and zero trailing half-bit
-- Revision:
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity alu_to_pedestalhub_zu3 is Port (
    clk    : in STD_LOGIC;
    alu    : in unsigned (22 downto 0); -- zero-nar, sign, exp, msb, fract, HUB
    memhub : out unsigned (15 downto 0)); -- sign, exp, implicit msb, fract, implicit HUB
end alu_to_pedestalhub_zu3;

architecture RTL of alu_to_pedestalhub_zu3 is
signal alureg    : unsigned (22 downto 0);
-- input breakout
signal zero_nar             : std_logic;
signal alu_sign             : std_logic;
signal alu_exp, alu_exp2    : unsigned(8 downto 0);
signal alu_fract, alu_fract2: unsigned(12 downto 0);
-- output breakout
signal mem_sign     : std_logic;
signal mem_exp      : unsigned(7 downto 0);
signal mem_fract    : unsigned(6 downto 0);


begin
-- disassemble ALU
zero_nar  <= alureg(22);
alu_sign  <= alureg(21);
alu_exp   <= unsigned(alureg(20 downto 12));
alu_fract <= '1' & unsigned(alureg(11 downto 0)); -- prefix leading one bit, use half-bit in rounding

RTL: process (all) begin
--		default signal values
mem_sign  <= alu_sign;
mem_exp   <= alu_exp(7 downto 0);
mem_fract <= alu_fract(11 downto 5);

alu_exp2   <= alu_exp;
alu_fract2 <= alu_fract;
--      combinatorial logic
if zero_nar = '1' then mem_exp <= "00000000"; mem_fract<= "0000000";        -- inset zero/NaR
elsif alu_fract(4) = '1' then              -- round, ties to even
        if alu_fract(3 downto 0) = "0000" 
            then mem_fract(0) <= '0';       -- set tie to even
            else alu_fract2(11 downto 5) <= alu_fract(11 downto 5) + 1; end if;  -- inclement fraction
        if alu_fract2(11 downto 5) = "0000000" then alu_exp2 <= alu_exp +1; mem_fract <= alu_fract2(11 downto 5); end if; end if; -- increment exponent if fraction overflowed
if alu_exp2 > "011111111" then mem_exp <= "01111111"; mem_fract<= "1111111"; end if; -- saturate if needed
end process;

update: process(clk)	-- register, register file, memory & state signal updates
begin
if (rising_edge(clk)) then memhub <= mem_sign & mem_exp & mem_fract;   alureg <= alu;
    end if;
end process;
end RTL;
