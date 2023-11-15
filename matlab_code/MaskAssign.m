function sextants = MaskAssign(switch1, switch2, sextant)
    % Funcion para asignar los disparosen cada uno de los sextantes
    
        sextants = [0, 0, 0, 0, 0, 0];
    
        % 1st sextant
        if switch1 == 1 && sextant == 1
            sextants = [1, 0, 0, 0, 1, 0];
        end
    
        if switch2 == 1 && sextant == 1
            sextants = [1, 0, 0, 0, 0, 1];
        end
        
        % 2nd sextant
        if switch1 == 1 && sextant == 2
            sextants = [1, 0, 0, 0, 0, 1];
        end
    
        if switch2 == 1 && sextant == 2
            sextants = [0, 1, 0, 0, 0, 1];
        end
    
        % 3rd sextant
        if switch1 == 1 && sextant == 3
            sextants = [0, 1, 0, 0, 0, 1];
        end
    
        if switch2 == 1 && sextant == 3
            sextants = [0, 1, 0, 1, 0, 0];
        end
    
        % 4th sextant
        if switch1 == 1 && sextant == 4
            sextants = [0, 1, 0, 1, 0, 0];
        end
    
        if switch2 == 1 && sextant == 4
            sextants = [0, 0, 1, 1, 0, 0];
        end
    
        % 5th sextant
        if switch1 == 1 && sextant == 5
            sextants = [0, 0, 1, 1, 0, 0];
        end
    
        if switch2 == 1 && sextant == 5
            sextants = [0, 0, 1, 0, 1, 0];
        end
    
        % 6th sextant
        if switch1 == 1 && sextant == 6
            sextants = [0, 0, 1, 0, 1, 0];
        end
    
        if switch2 == 1 && sextant == 6
            sextants = [1, 0, 0, 0, 1, 0];
        end
        
    end