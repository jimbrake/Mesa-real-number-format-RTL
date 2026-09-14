----------------------------------------------------------------------------------
-- Create Date: 06/04/2026 10:21:58 PM
-- Module Name:NSHld_pedestal16_zu3 - Behavioral
-- Target Devices: XCZU3EG-2SFVC784E
-- Tool Versions: vivado 25.2
-- Description: 
-- Convert pedestal16 HUB to ALU e9 f13
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
    alu    : out unsigned (23 downto 0); -- zero-nar, sign, exp, msb, fract   registered
    mem    : in unsigned (15 downto 0)); -- sign, exp, implicit msb, fract    registered
end alu_to_pedestalhub_zu3;

architecture RTL of alu_to_pedestalhub_zu3 is
signal alureg    : unsigned (23 downto 0);
-- output breakout
signal zero_nar     : std_logic;
signal alu_sign     : std_logic;
signal alu_exp      : unsigned(8 downto 0);
signal alu_fract    : unsigned(12 downto 0);
-- input breakout
signal memreg       : unsigned (15 downto 0);
signal mem_sign     : std_logic;
signal mem_exp      : unsigned(7 downto 0);
signal mem_fract    : unsigned(6 downto 0);


begin
-- disassemble pedestal
mem_sign  <= memreg(15);
mem_exp   <= memreg(14 downto 7);
mem_fract <= memreg(6 downto 0);

-- output
alu <= alureg;

RTL: process (all) begin
--		ALU signal values
zero_nar <= '0';
if mem_exp & mem_fract = "0000000000000000" then zero_nar <= '1'; end if;
alu_sign  <= mem_sign;
alu_exp   <= unsigned(mem_exp(7) & mem_exp(7 downto 0));  -- extend exponent
alu_fract <= unsigned('1' & mem_fract & "00000"); -- prefix leading one bit, sufffix zeros

end process;

update: process(clk)	-- register, register file, memory & state signal updates
begin
if (rising_edge(clk)) then 
    alureg <= zero_nar & alu_sign & alu_exp & alu_fract; 
    memreg <= mem; end if;
end process;
end RTL;
