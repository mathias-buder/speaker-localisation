function [ M, fa ] = ReadOcziCSV( CsvFile )
    
    R = 19;
    C = 4;
    M = csvread(CsvFile, R, C);

end