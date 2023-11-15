LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Switches IS
    PORT (
        ratio1 : IN INTEGER;
        sawtoothSignal : IN INTEGER;
        switch1 : OUT STD_LOGIC;
        switch2 : OUT STD_LOGIC
    );
END ENTITY Switches;

ARCHITECTURE main OF Switches IS
BEGIN
    PROCESS (ratio1, sawtoothSignal)
    BEGIN
        IF ratio1 >= sawtoothSignal THEN
            switch1 <= '1';
            switch2 <= '0';
        ELSE
            switch1 <= '0';
            switch2 <= '1';
        END IF;
    END PROCESS;
END main;