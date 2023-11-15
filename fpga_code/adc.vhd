LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY adc IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;

        consvst : OUT STD_LOGIC;
        scl : OUT STD_LOGIC;
        sdi : OUT STD_LOGIC;
        sdo : IN STD_LOGIC;

        sextants : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
    );
END ENTITY adc;

ARCHITECTURE main OF adc IS
    SIGNAL adc_val : STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL scl_aux : STD_LOGIC := '0';
    SIGNAL adc_cum_sum : unsigned(23 DOWNTO 0);
    SIGNAL adc_max_value : STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL max_value_adc : unsigned(11 DOWNTO 0);
    SIGNAL value_adc_norm : STD_LOGIC_VECTOR(23 DOWNTO 0);
    SIGNAL sawtoothSignal : INTEGER RANGE 0 TO 72000;
    SIGNAL sextant_value : INTEGER RANGE 1 TO 6;
    SIGNAL ratio1_value : INTEGER RANGE 0 TO 18000;
    SIGNAL switch1 : STD_LOGIC;
    SIGNAL switch2 : STD_LOGIC;

    -- ADC IP WIZARD
    COMPONENT adcip IS
        PORT (
            CLOCK : IN STD_LOGIC := '0'; --                clk.clk
            ADC_SCLK : OUT STD_LOGIC; -- external_interface.SCLK
            ADC_CS_N : OUT STD_LOGIC; --                   .CS_N
            ADC_DOUT : IN STD_LOGIC := '0'; --                   .DOUT
            ADC_DIN : OUT STD_LOGIC; --                   .DIN
            CH0 : OUT STD_LOGIC_VECTOR(11 DOWNTO 0); --           readings.CH0
            CH1 : OUT STD_LOGIC_VECTOR(11 DOWNTO 0); --                   .CH1
            CH2 : OUT STD_LOGIC_VECTOR(11 DOWNTO 0); --                   .CH2
            CH3 : OUT STD_LOGIC_VECTOR(11 DOWNTO 0); --                   .CH3
            CH4 : OUT STD_LOGIC_VECTOR(11 DOWNTO 0); --                   .CH4
            CH5 : OUT STD_LOGIC_VECTOR(11 DOWNTO 0); --                   .CH5
            CH6 : OUT STD_LOGIC_VECTOR(11 DOWNTO 0); --                   .CH6
            CH7 : OUT STD_LOGIC_VECTOR(11 DOWNTO 0); --                   .CH7
            RESET : IN STD_LOGIC := '0' --              reset.reset
        );
    END COMPONENT;

    -- EXTREMA FINDER
    COMPONENT ExtremaFinder IS
        GENERIC (
            ADC_BITS : INTEGER := 12; -- Number of ADC bits
            MAX_VALUE : INTEGER := 4095 -- Default maximum value
        );
        PORT (
            ADC_VALUE : IN STD_LOGIC_VECTOR(ADC_BITS - 1 DOWNTO 0);
            MAX_OUT : OUT STD_LOGIC_VECTOR(ADC_BITS - 1 DOWNTO 0);
            MIN_OUT : OUT STD_LOGIC_VECTOR(ADC_BITS - 1 DOWNTO 0)
        );
    END COMPONENT;

    -- NORMALIZE DATA
    COMPONENT NormalizationModule IS
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            adc_value : IN UNSIGNED(11 DOWNTO 0);
            max_value : IN UNSIGNED(11 DOWNTO 0);

            normalized_adc_value : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
        );
    END COMPONENT;

    -- CUMULATIVE SUM
    COMPONENT ADC_Sum IS
        GENERIC (
            ADC_BITS : INTEGER := 12 -- Number of ADC bits
        );
        PORT (
            clk : IN STD_LOGIC; -- Clock input
            reset : IN STD_LOGIC; -- Reset input
            adc : IN STD_LOGIC_VECTOR(ADC_BITS - 1 DOWNTO 0); -- Phase angle input
            adc_cum_sum : OUT UNSIGNED -- Cumulative sum output
        );
    END COMPONENT;

    -- SAWTOOTH
    COMPONENT Rampa IS
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            count_out : OUT INTEGER RANGE 0 TO 72000
        );
    END COMPONENT;

    -- SEXTANTS
    COMPONENT Sextantes IS
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            adc_cum_sum : IN UNSIGNED(23 DOWNTO 0);
            lut_value : OUT INTEGER RANGE 1 TO 6
        );
    END COMPONENT;

    -- RATIO 1 (pulse1 in matlab)
    COMPONENT Ratio1 IS
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            adc_cum_sum : IN UNSIGNED(23 DOWNTO 0);
            lut_value : OUT INTEGER RANGE 0 TO 18000
        );
    END COMPONENT;

    -- SWITCHES
    COMPONENT Switches IS
        PORT (
            ratio1 : IN INTEGER;
            sawtoothSignal : IN INTEGER;
            switch1 : OUT STD_LOGIC;
            switch2 : OUT STD_LOGIC
        );
    END COMPONENT;

    -- MASK ASSIGN
    COMPONENT MaskAssign IS
        PORT (
            switch1, switch2 : IN STD_LOGIC;--! Es nuestra señal que nos indicará que interruptor activar.
            sextant : IN INTEGER;--! Es el sextante que se activará.
            mask : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)--! Es la máscara que se activará.
        );
    END COMPONENT;

BEGIN

    uu0 : adcip PORT MAP(
        CLOCK => clk,
        ADC_SCLK => scl_aux,
        ADC_CS_N => consvst,
        ADC_DOUT => sdo,
        ADC_DIN => sdi,
        CH0 => adc_val,
        CH1 => OPEN,
        CH2 => OPEN,
        CH3 => OPEN,
        CH4 => OPEN,
        CH5 => OPEN,
        CH6 => OPEN,
        CH7 => OPEN,
        RESET => rst
    );
    scl <= scl_aux;

    -- find extrema
    uu1 : ExtremaFinder GENERIC MAP(
        ADC_BITS => 12,
        MAX_VALUE => 4095
        ) PORT MAP(
        ADC_VALUE => adc_val,
        MAX_OUT => adc_max_value,
        MIN_OUT => OPEN
    );
    max_value_adc <= unsigned(adc_max_value);

    -- normalize data
    uu2 : NormalizationModule PORT MAP(
        clk => scl_aux,
        rst => rst,
        adc_value => unsigned(adc_val),
        max_value => max_value_adc,
        normalized_adc_value => value_adc_norm
    );

    -- CUMULATIVE SUM
    uu3 : ADC_Sum GENERIC MAP(
        ADC_BITS => 24
        ) PORT MAP(
        clk => scl_aux,
        reset => rst,
        adc => value_adc_norm,
        adc_cum_sum => adc_cum_sum
    );

    -- create the sawtooth
    uu4 : Rampa PORT MAP(
        clk => scl_aux,
        rst => rst,
        count_out => sawtoothSignal
    );

    -- get the sextant value through the adc_cum_sum index
    uu5 : Sextantes PORT MAP(
        clk => scl_aux,
        rst => rst,
        adc_cum_sum => unsigned(adc_cum_sum),
        lut_value => sextant_value
    );

    -- get the ratio1 value through the adc_cum_sum index
    uu6 : Ratio1 PORT MAP(
        clk => scl_aux,
        rst => rst,
        adc_cum_sum => unsigned(adc_cum_sum),
        lut_value => ratio1_value
    );

    -- compare the ratio1 value with the sawtooth value
    uu7 : Switches PORT MAP(
        ratio1 => ratio1_value,
        sawtoothSignal => sawtoothSignal,
        switch1 => switch1,
        switch2 => switch2
    );

    -- assign the mask
    uu8 : MaskAssign PORT MAP(
        switch1 => switch1,
        switch2 => switch2,
        sextant => sextant_value,
        mask => sextants
    );

END main;