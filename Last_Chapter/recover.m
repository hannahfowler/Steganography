%recover1.m
%This function recovers a message that has previously been hidden in an
%image and returns it in rcvd_msg. Necessary inputs are the image url
%without the file type (ex: C:\images\test.tiff is C:\images\test), the
%file type entered without a ?.? (ex tiff not .tiff), the block size to be
%used, the number of columns to protect, the amount of redundancy and the
%number of iterations to be used.
function rcvd_msg = recover(image_addr, image_type, dim, cols_protected,redun)
    %read in the file
    input_image = imread(image_addr, image_type);
    %make input_image into a real valued matrix so SVD can be computed
    recovery_image = double(input_image)+1;
    %make a copy of the image so that the original data isn?t lost
    junk = recovery_image;
    %get the dimensions of the image
    [m,n]=size(junk);
    %Calculate the number of bits per block
    bpb = ((dim-cols_protected-1)*(dim-cols_protected))/2;
    %computes the largest message that could have been embedded
    msg_size=floor((m*n)/(dim*dim)*bpb);
    %a place to keep a recovered message chunk of size bpb
    temp_rcvd_msg=zeros(1,bpb);
    %recover the message
    for j=1:(m/dim)
        for i=1:(n/dim)
            %get the block that will be worked on
            block=junk(dim*j-(dim-1):dim*j, dim*i-(dim-1):dim*i)-127;
            %compute the SVD of the block
            [U,S,V]=svd(block);
            %used to make U standard
            U_std = U;
            %If the first entry of a column in U is negative multiply
            %the column by -1
            for k=1:dim
                if U(1,k)<0
                    U_std(1:dim,k) = -1*U(1:dim,k);
                end %end if
            end %end k
            %next_spot keeps track of where to place the bit read from
            %the U matrix, reset each time through the j loop
            next_spot=1;
            %only read data from columns that are not protected,
            %excluding the last one
            for p=cols_protected+1:(n/dim)-1
                %the first row is always protected so this loop
                %starts at 2
                for q=2:(dim+1)-p
                    %if the entry being examined is < 0 then the bit
                    %is a 0 otherwise the bit is a 1
                    if U_std(q,p)<0
                        temp_rcvd_msg(1,next_spot)=0;
                    else
                        temp_rcvd_msg(1,next_spot)=1;
                    end %end if
                    %increment next_spot
                    next_spot = next_spot+1;
                end %end q
            end %end p
            if i==1 & j==1
                rcvd_msg = temp_rcvd_msg;
            else
                rcvd_msg = [rcvd_msg temp_rcvd_msg];
            end %end if
        end %end j
    end %end i
    %calculate the size of the embedded message
    msg_size=size(rcvd_msg,2)/redun;
    %The following takes into account the redundancy and finds the original
    %embedded message using a simple error correcting code. If the redundancy
    %was 5 then the message we have recovered so far is really the same message
    %concatenated with itself 5 times. If we look at the first bit of each of
    %these copies and have more 1s than 0s then we assume the bit is a 1. We do
    %this for each bit of the message.
    act_msg=zeros(1,msg_size); q=0; for w=1:msg_size
        for y=0:redun-1
            q=q+rcvd_msg(1,w+y*msg_size);
        end % y loop
        if q > redun/2
            act_msg(1,w)=1;
        else
            act_msg(1,w)=0;
        end %end if
        q=0;
    end %end w 
%return rcvd_msg
rcvd_msg=act_msg;
csvwrite('message.csv',rcvd_msg)
end 