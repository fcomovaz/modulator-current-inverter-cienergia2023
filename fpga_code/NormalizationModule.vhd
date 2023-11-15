LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY NormalizationModule IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        adc_value : IN UNSIGNED(11 DOWNTO 0);
        max_value : IN UNSIGNED(11 DOWNTO 0);

        normalized_adc_value : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
    );
END ENTITY NormalizationModule;

ARCHITECTURE main OF NormalizationModule IS
    CONSTANT valor_escala : INTEGER := 18000;

    SIGNAL scaled_value : UNSIGNED(23 DOWNTO 0); -- To avoid overflow during scaling
BEGIN
    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            -- Reset the normalization process if needed
            normalized_adc_value <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            -- Normalize the data based on the MATLAB code

            -- Step 1: Scale the adc_value using the max_value
            scaled_value <= (unsigned(adc_value) * valor_escala) / max_value;


            -- Now, V_A contains the normalized and scaled value
            -- We need to convert it back to STD_LOGIC_VECTOR before assigning to the output
            normalized_adc_value <= std_logic_vector(scaled_value);
        END IF;
    END PROCESS;
END main;
