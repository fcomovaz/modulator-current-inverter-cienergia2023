% max value allowed
samples = 72000;

% create a vector of samples
x = linspace(0, 2*pi, samples);
y = int32(round(samples*abs(cos(x))));

% save in a text file the y values
fileID = fopen('cos.txt','w');
fprintf(fileID,'%d\n',y);
fclose(fileID);

