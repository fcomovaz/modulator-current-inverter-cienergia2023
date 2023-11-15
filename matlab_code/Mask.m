function aux =  Mask(adc_sum)

    % the angle is 200x

    % initial values
    pulse1 = 0;
    pulse2 = 0;
    Sextant = 0;

    % angle division
    theta_AA = deg2rad((adc_sum)/200);
    theta_AB = deg2rad((adc_sum - 120*200)/200);
    theta_AC = deg2rad((adc_sum + 120*200)/200);
    % % this doesn't match the other angles
    % theta_AC = adc_sum - 4*pi/3;

    % for 330 360 sextant 1
    if adc_sum >= 330*200 && adc_sum <= 360*200
        Sextant = 1;    
        pulse1  = -cos(theta_AB) / cos(theta_AA);
        pulse2  = -cos(theta_AC) / cos(theta_AA);
        
    end

    % for 0 30 sextant 1
    if adc_sum < 30*200 && adc_sum >= 0
        Sextant = 1;
        pulse1  = -cos(theta_AB) / cos(theta_AA);
        pulse2  = -cos(theta_AC) / cos(theta_AA);
    end

    % for 30 90 sextant 2
    if adc_sum >= 30*200 && adc_sum < 90*200
        Sextant = 2;
        pulse1  = -cos(theta_AA) / cos(theta_AC);
        pulse2  = -cos(theta_AB) / cos(theta_AC);
    end

    % for 90 150 sextant 3
    if adc_sum >= 90*200 && adc_sum < 150*200
        Sextant = 3;
        pulse1  = -cos(theta_AC) / cos(theta_AB);
        pulse2  = -cos(theta_AA) / cos(theta_AB);
    end

    % for 150 210 sextant 4
    if adc_sum >= 150*200 && adc_sum < 210*200
        Sextant = 4;
        pulse1  = -cos(theta_AB) / cos(theta_AA);
        pulse2  = -cos(theta_AC) / cos(theta_AA);
    end

    % for 210 270 sextant 5
    if adc_sum >= 210*200 && adc_sum < 270*200
        Sextant = 5;
        pulse1  = -cos(theta_AA) / cos(theta_AC);
        pulse2  = -cos(theta_AB) / cos(theta_AC);
    end

    % for 270 330 sextant 6
    if adc_sum >= 270*200 && adc_sum < 330*200
        Sextant = 6;
        pulse1  = -cos(theta_AC) / cos(theta_AB);
        pulse2  = -cos(theta_AA) / cos(theta_AB);
    end

    aux = [Sextant, pulse1, pulse2];
    
end