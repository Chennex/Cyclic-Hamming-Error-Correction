library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity encoder is
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
end encoder;
    
    architecture shiftRegister of encoder is
    signal counter : std_logic_vector(0 to 3);
    signal regis : std_logic_vector(0 to 2);
    signal delay : std_logic_vector(0 to 2);
    signal regiNext : std_logic_vector(0 to 2);
    begin
    
    --Definition of polynomial.
    regiNext(0) <= dataInput xor regis(2);
    regiNext(1) <= regis(0) xor regis(2);
    regiNext(2) <= regis(1);
    
    counterProc : process(clock, reset)
    begin
        if reset = '1' then
            counter <= (others => '0');
            regis <= (others => '0');
        elsif rising_edge(clock) then
              --Counter resets after each word -1. So for word of length 30, reset at 29. Also reset counter if sync signal is true.
              if counter = wordSize or newWord = '1' then
                counter <= (others => '0');
              else 
                counter <= counter + '1' after 10 ns;
              end if;
              delay <= datainput & delay(0 to 1);
                if counter <= wordSize - dataSize - 1 then
                  regis <= datainput & regis(0 to 1);
                  dataOutput <= regis(2) after 10 ns;
                else
                  regis <= regiNext after 10 ns;
                  dataOutput <= delay(2) after 10 ns;
                end if;
        end if;    
    end process;
end architecture;
