function res = decode()
 %message = load('message.csv');
 new = [0 1 0 0 1 1 0 1 0 1 1 1 1 0 0 1 0 0 1 0 0 0 0 0 0 1 1 0 1 1 1 0 0 1 1 0 0 0 0 1 0 1 1 0 1 1 0 1 0 1 1 0 0 1 0 1 0 0 1 0 0 0 0 0 0 1 1 0 1 0 0 1 0 1 1 1 0 0 1 1 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 1 0 1 1 0 1 1 1 0 0 1 1 0 1 1 1 0 0 1 1 0 0 0 0 1 0 1 1 0 0 0 1 0 0 1 1 0 0 1 0 1 0 1 1 0 1 1 0 0];
%  msg_reshaped = reshape(message, [mod(length(message)/8),8]);
%  message = mat2str(message);
%  decoded = char(bin2dec(reshape(message,[mod(length(message)/8),8]).').')
for i = 1:8:length(new)-7
    binary = new(i:i+7); 
    binary_array = mat2str(binary);
    if binary == [0 0 0 0 0 0 0 0]
        break 
    end
    binary_string = binary_array(2:16); %rids of brackets
    binary_letter = '';
    code = '';
    for i = 1:length(binary_string)
        if (binary_string(i)== '1' | binary_string(i)== '0')
            binary_letter = strcat(binary_letter, binary_string(i));
            mess = char(bin2dec(binary_letter));
            code = strcat(code,mess);
    end 
    end 
disp(code)
end