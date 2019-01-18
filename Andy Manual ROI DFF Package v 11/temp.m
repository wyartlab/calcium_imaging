function [output] = temp(input, time, condition)

output = cell2mat(input)';
output(:,2) = time;
output(:,3) = condition;