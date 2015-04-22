%simple_iterate.m
%This is a function which embeds a random message into an image and then
%recovers the message. The error rate is then calculated and returned in
%avg_error_rates. Necessary inputs are the image url
%without the file type (ex: C:\images\test.tiff is C:\images\test), the
%file type entered without a ?.? (ex tiff not .tiff), the block size to be
%used, the number of columns to protect, the amount of redundancy and the
%number of iterations to be used.
function avg_error=simple(image_addr, image_type, dim,cols_protected, redun, iterations)
tests = 10;
error_rates=zeros(1,tests); %an array to hold the error rate of each test
msg_sizes=zeros(1,tests); %an array to hold the size of the message embeded in test
%Turn off common Matlab warnings
warning('off', 'MATLAB:divideByZero')
warning('off', 'MATLAB:nearlySingularMatrix') 
warning('off', 'MATLAB:singularMatrix')
    for t=1:tests
        t %display the test number
        %embed a random message into the image
        msg=embed1(image_addr, image_type, dim, cols_protected, redun, iterations);
        msg_size=size(msg,2)%display the size of the embedded message
        %recover the message from the marked image
        recover_addr = [image_addr,'_marked'];
        rcvd_msg=recover_sing(recover_addr,image_type,dim,cols_protected,redun);
        %compute the error rate between the original and recovered message
        %and put it in the t-th slot of error_rates
        rcvd_msg_size=size(rcvd_msg,2);
        diff=abs(msg-rcvd_msg);
        error=sum(diff)/msg_size;
        error_rates(1,t)=error
    end
%compute the average error rate for the given image and variables
avg_error=sum(error_rates)/tests*100
end