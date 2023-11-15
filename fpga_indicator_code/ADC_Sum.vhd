LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ADC_Sum IS
    GENERIC (
        ADC_BITS : INTEGER := 24 -- Number of ADC bits
    );
    PORT (
        clk : IN STD_LOGIC; -- Clock input
        reset : IN STD_LOGIC; -- Reset input
        adc : IN STD_LOGIC_VECTOR(ADC_BITS - 1 DOWNTO 0); -- Phase angle input
        adc_cum_sum : OUT UNSIGNED -- Cumulative sum output
    );
END ENTITY ADC_Sum;

ARCHITECTURE main OF ADC_Sum IS
    SIGNAL adc_val : unsigned(ADC_BITS - 1 DOWNTO 0); -- Phase angle input
    SIGNAL adc_cum_sum_val : unsigned(ADC_BITS - 1 DOWNTO 0); -- Cumulative sum of phase angle differences
    SIGNAL adc_prev_val : unsigned(ADC_BITS - 1 DOWNTO 0); -- Previous phase angle value

BEGIN
    adc_val <= unsigned(adc);

    PROCESS (clk)
        VARIABLE difference : unsigned(ADC_BITS - 1 DOWNTO 0); -- Difference between consecutive phase angles
        VARIABLE larger_val : unsigned(ADC_BITS - 1 DOWNTO 0); -- Larger value
        VARIABLE smaller_val : unsigned(ADC_BITS - 1 DOWNTO 0); -- Smaller value
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                adc_cum_sum_val <= (OTHERS => '0'); -- Reset the cumulative sum on reset
            ELSE
                -- Calculate the difference between consecutive phase angles
                IF adc_val >= adc_prev_val THEN
                    larger_val := adc_val;
                    smaller_val := adc_prev_val;
                ELSE
                    larger_val := adc_prev_val;
                    smaller_val := adc_val;
                END IF;

                difference := larger_val - smaller_val;

                -- Update the cumulative sum
                adc_cum_sum_val <= adc_cum_sum_val + difference;

            END IF;

            -- Update the previous phase angle value
            adc_prev_val <= adc_val;
        END IF;
    END PROCESS;

    adc_cum_sum <= adc_cum_sum_val;

END ARCHITECTURE main;