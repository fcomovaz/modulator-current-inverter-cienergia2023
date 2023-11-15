LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

--! Este programa produce la activación de los interruptores (máscara).

ENTITY MaskAssign IS
  PORT (
    switch1, switch2 : IN STD_LOGIC;--! Es nuestra señal que nos indicará que interruptor activar.
    sextant : IN INTEGER;--! Es el sextante que se activará.
    mask : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)--! Es la máscara que se activará.
  );
END ENTITY;

ARCHITECTURE conditions OF MaskAssign IS

BEGIN
  check_sextant_to_assign : PROCESS (switch1, switch2, sextant)
  BEGIN
    CASE (sextant) IS
        -- primer sextante
      WHEN 1 =>
        IF switch1 = '1' THEN
          mask <= "100010";
        END IF;
        IF switch2 = '1' THEN
          mask <= "100001";
        END IF;

        -- segundo sextante
      WHEN 2 =>
        IF switch1 = '1' THEN
          mask <= "100001";
        END IF;
        IF switch2 = '1' THEN
          mask <= "010001";
        END IF;

        -- tercer sextante
      WHEN 3 =>
        IF switch1 = '1' THEN
          mask <= "010001";
        END IF;
        IF switch2 = '1' THEN
          mask <= "010100";
        END IF;

        -- cuarto sextante
      WHEN 4 =>
        IF switch1 = '1' THEN
          mask <= "010100";
        END IF;
        IF switch2 = '1' THEN
          mask <= "001100";
        END IF;

        -- quinto sextante
      WHEN 5 =>
        IF switch1 = '1' THEN
          mask <= "001100";
        END IF;
        IF switch2 = '1' THEN
          mask <= "001010";
        END IF;

        -- sexto sextante
      WHEN 6 =>
        IF switch1 = '1' THEN
          mask <= "001010";
        END IF;
        IF switch2 = '1' THEN
          mask <= "100010";
        END IF;

        --   para cualquier otro caso
        -- se desactivan todos los interruptores
      WHEN OTHERS =>
        mask <= "000000";
    END CASE;
  END PROCESS check_sextant_to_assign;

END ARCHITECTURE;