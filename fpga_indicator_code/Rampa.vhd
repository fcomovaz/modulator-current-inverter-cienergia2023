LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Rampa IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        count_out : OUT INTEGER RANGE 0 TO 72000
    );
END ENTITY Rampa;

ARCHITECTURE main OF Rampa IS
    CONSTANT max_count : INTEGER := 72000;
    SIGNAL counter : INTEGER RANGE 0 TO max_count;
BEGIN
    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            -- Reset the counter
            counter <= 0;
        ELSIF rising_edge(clk) THEN
            -- Increment the counter
            IF counter = max_count THEN
                counter <= 0; -- Reset back to 0 when it reaches the maximum value
            ELSE
                counter <= counter + 1;
            END IF;
        END IF;
    END PROCESS;

    -- Output the counter value
    count_out <= counter;
END main;
