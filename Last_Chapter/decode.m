function res = decode()
 message = load('message.csv');
%  msg_reshaped = reshape(message, [mod(length(message)/8),8]);
%  message = mat2str(message);
%  decoded = char(bin2dec(reshape(message,[mod(length(message)/8),8]).').')
for i = 0:7:length(message)
    binary = message(1+i:8+i);
    binary_array = mat2str(binary);
    binary_string = binary_array(2:16);
    for i = 1:length(binary_string)
        if binary_string(i) == 0 or 1
            binary_letter = binary_letter + binary(i) 
        end 
    end 
    
end 
end