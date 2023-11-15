library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ExtremaFinder is
  generic (
    ADC_BITS : integer := 12; -- Number of ADC bits
    MAX_VALUE : integer := 4095 -- Default maximum value
  );
  port (
    ADC_VALUE : in  std_logic_vector(ADC_BITS - 1 downto 0);
    MAX_OUT   : out std_logic_vector(ADC_BITS - 1 downto 0);
    MIN_OUT   : out std_logic_vector(ADC_BITS - 1 downto 0)
  );
end entity ExtremaFinder;

architecture behavioral of ExtremaFinder is
  -- Signal declarations
  signal max_val : unsigned(ADC_BITS - 1 downto 0);
  signal min_val : unsigned(ADC_BITS - 1 downto 0);
  signal adc_val : unsigned(ADC_BITS - 1 downto 0);
begin
  -- Convert ADC_VALUE to unsigned
  adc_val <= unsigned(ADC_VALUE);

  process(adc_val)
  begin
    -- Find maximum value
    if adc_val > max_val then
      max_val <= adc_val; -- Update maximum value
    end if;

    -- Find minimum value
    if adc_val < min_val then
      min_val <= adc_val; -- Update minimum value
    end if;
  end process;

  -- Convert maximum and minimum values back to std_logic_vector
  MAX_OUT <= std_logic_vector(max_val);
  MIN_OUT <= std_logic_vector(min_val);

end architecture behavioral;
