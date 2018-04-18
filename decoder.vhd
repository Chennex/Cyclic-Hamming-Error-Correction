library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity decoder is
    port(
    dataInput : in STD_LOGIC;
    dataOutput : out STD_LOGIC;
    --New word is redundant. Can be used as a 'soft reset', setting the counter back to 0.
    clock, reset, newWord : in STD_LOGIC;
    --Define the total size of the word. Data + parity.
    wordSize : in std_logic_vector(0 to 3);
    --Define data size
    dataSize : in std_logic_vector(0 to 3)
    );
end decoder;

architecture syndromeCalculator of decoder is
  --Delay system defined here. Each additional register adds a 1 clockcycle delay.
  signal delayRegisters : std_logic_vector(0 to 7);

  signal regis : std_logic_vector(0 to 2);
  --Reginext describes the generator polynomial.
  signal regiNext : std_logic_vector(0 to 2);
  signal counter : std_logic_vector(0 to 2);
  --drain describes whether the s0 syndrome is found. Stuff happens when it is set to 1, until then we merely cycle through the registers.
  signal drain : std_logic;
  signal shouldCorrect : std_logic;
  
  
  
  begin
  regiNext(0) <= dataInput xor regis(2);
  regiNext(1) <= regis(0) xor regis(2);
  regiNext(2) <= regis(1);
  --Magic goes here.
  
  counterProc : process(clock, reset)
    begin
      if reset = '1' then
        regis <= (others => '0');
        counter <= (others => '0');
        drain <= '0';
      elsif rising_edge(clock) then
        counter <= counter + '1';
        regis <= regiNext;
        --Shift the delay.
        delayRegisters <= dataInput & delayRegisters(0 to 6);
        --Drain ALL the registers. Searching syndrome 101.
        shouldCorrect <= regis(0) and not regis(1) and regis(2);
        dataOutput <= delayRegisters(7) xor shouldCorrect;
      end if;
    end process;
end architecture;