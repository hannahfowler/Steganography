%embed1.m
%This is a function that embeds a random message into an image and returns
%the message that was embedded. Necessary inputs are the image url
%without the file type (ex: C:\images\test.tiff is C:\images\test), the
%file type entered without a ?.? (ex tiff not .tiff), the block size to be
%used, the number of columns to protect, the amount of redundancy and the
%number of iterations to be used.
function msg = embed(image_addr, image_type, dim, cols_protected, redun,iterations)
    %read the input image
    input_image = imread(image_addr, image_type);

    %make input_image into a real valued matrix so SVD can be computed
    working_image = double(input_image)+1;

    %make a copy of the image so that the original data isn?t lost
    junk = working_image;

    %get the dimensions of the image
    [m,n]=size(junk);

    %Calculate the number of blocks and bits per block
    bpb = ((dim-cols_protected-1)*(dim-cols_protected))/2;
    num_blocks=m*n/(dim^2);

    %computes the largest message that can be embedded
    msg_size=ceil(bpb*num_blocks/redun);
    %disp(msg_size)

    %Generate a random message of size msg_size to embed\
    %msg = round(rand(1,msg_size))
    msg = 'hello'
    msg = dec2bin(msg, 8)'
    msg = msg(:)' - '0'
    
    %msg=[0 1 0 0 1 0 0 0 0 1 1 0 0 1 0 1 0 1 1 0 1 1 0 0 0 1 1 0 1 1 0 0 0 1 1 0 1 1 1 1 0 1 0 0 1 1 0 1 0 1 1 1 1 0 0 1 0 1 1 0 1 1 1 0 0 1 1 0 0 0 0 1 0 1 1 0 1 1 0 1 0 1 1 0 0 1 0 1 0 1 1 0 1 0 0 1 0 1 1 1 0 0 1 1 0 1 0 0 0 0 0 1 0 1 1 0 1 1 1 0 0 1 1 0 1 1 1 0 0 1 1 0 0 0 0 1 0 1 1 0 0 0 1 0 0 1 1 0 0 1 0 1 0 1 1 0 1 1 0 0 0 1 0 0 1 1 0 1 0 1 1 1 1 0 0 1 0 1 1 0 0 1 1 0 0 1 1 1 0 0 1 0 0 1 1 0 1 0 0 1 0 1 1 0 0 1 0 1 0 1 1 0 1 1 1 0 0 1 1 0 0 1 0 0 0 1 1 1 0 0 1 1 0 1 1 0 0 0 0 1 0 1 1 1 0 0 1 0 0 1 1 0 0 1 0 1 0 1 0 0 1 0 0 0 0 1 1 0 0 0 0 1 0 1 1 0 1 1 1 0 0 1 1 0 1 1 1 0 0 1 1 0 0 0 0 1 0 1 1 0 1 0 0 0 0 1 1 0 0 0 0 1 0 1 1 0 1 1 1 0 0 1 1 0 0 1 0 0 0 1 0 0 0 1 0 0 0 1 1 0 0 0 0 1 0 1 1 1 0 1 1 0 0 1 1 0 1 0 0 1 0 1 1 0 0 1 0 0 ];
    msg = padarray(msg, [0, msg_size]);
    
    %Concatenate msg to itself redun times to to form redun_msg
    for t=1:redun
        if t==1
            redun_msg=msg;
        else
            redun_msg=[redun_msg,msg];
        end
    end %end t

    for a=1:iterations
        %Display the iteration
        %Make a copy of redun_msg
        temp_msg=redun_msg;
        for j=1:(m/dim)
            for i=1:(n/dim)
                %get the block that will be worked on
                block=junk(dim*j-(dim-1):dim*j, dim*i-(dim-1):dim*i)-127;

                %compute the SVD of the block
                [U,S,V]=svd(block);

                %used to make U standard and create V_prime
                U_std = U;
                V_prime = V;

                %make U std and modify V into V_prime
                for k=1:dim

                    %If the first entry of a column in U is negative multiply
                    %the column by -1
                    if U(1,k)<0
                        U_std(1:dim,k) = -1*U(1:dim,k);
                        V_prime(1:dim,k) = -1*V(1:dim,k);
                    end %end if
                end %end k

                %used to create s_prime
                S_prime = S;

                %evenly space the Singular Values between the largest and smallest.
                avg_dist = (S(2,2)+S(dim,dim))/(dim-2);
                for k = 3:dim-1
                    S_prime(k,k)=S(2,2)-(k-2)*avg_dist;
                end %end k

                %get a part of message to be embedded
                msg_chunk = temp_msg(1:bpb);
                %remove the first bpb bits of the message so that the next pass
                %allows us to get the next bpb bits
                temp_msg = temp_msg(1,bpb+1:end);
                %U_mk will be where the embedding occurs
                U_mk=U_std;
                %index is the bit of msg_chunk to embed
                index = 1;
                %embed the msg_chunk using U_std to make U_mk
                %k varies from cols_protected+1 to dim since message bits can only
                %be embedded in those columns
                for k=cols_protected+1:dim
                    %the last column of the block will have no bits embedded in
                    %it, but it still needs to be made orthogonal to the rest
                    %of the columns
                    if k < dim
                        %m+1-k comes from the fact that we can only embed data
                        %in rows 2 through dim-(k-1)
                        for l=2:dim+1-k
                            if msg_chunk(index) == 0
                                %replace the entry with -1 times the absolute
                                %value of the entry
                                U_mk(l,k)= -1*abs(U_std(l,k));
                            else
                                %replace the entry with its absolute value
                                U_mk(l,k)=abs(U_std(l,k));
                            end %end if
                            %advance the index by 1 bit
                            index = index + 1;
                        end %end l
                    end %end if
                    %we need to make column orthogonal to other columns solve a system
                    %of column # -1 equations in col # - 1 unknowns.
                    coeffs = zeros(k-1); %will become coefficeint matrix
                    sols = zeros(k-1,1); %will become solutions matrix
                    %fills the coefficeint matrix
                    for x=1:k-1
                        for y=1:k-1
                            coeffs(x,y)=U_mk(y+dim+1-k,x);
                        end %end y
                        %fill solutions matrix
                        sols(x,1)=-dot(U_mk(1:dim+1-k,k),U_mk(1:dim+1-k,x));
                    end %end x
                    %compute the new entries that make the column orthoganal to
                    %the ones that came before it.
                    new_entries = coeffs\sols;
                    sz=size(new_entries,1); %the number of new entries
                    %put the new entries in U_mk
                    for p=dim+1-sz:dim
                        U_mk(p,k) = new_entries(p-(dim-sz),1);
                    end %end p
                    %normalize U_mk
                    norm_factor = sqrt(dot(U_mk(1:dim,k),U_mk(1:dim,k)));
                    for q=1:dim
                        U_mk(q,k) = U_mk(q,k)/norm_factor;
                    end %end q
                end %end k
                %A_tilde will be the new matrix to put back in place of block
                A_tilde = round(U_mk*S_prime*V_prime);
                %make sure that the values of A_tilde are between 0 and 127 if
                %not then make any negative entries 0 and and any entries that
                %are greater than 255 equal to 255
                for r=1:dim
                    for s=1:dim
                        if A_tilde(r,s) < -127
                            A_tilde(r,s) = -127;
                        end %end if
                        if A_tilde(r,s) > 128
                            A_tilde(r,s) = 128;
                        end %end if
                    end %end r
                end %end s
                %replace the block in junk with A_tilde+127 so theat the values
                %of a tilde are between 0 and 255
                junk(dim*j-(dim-1):dim*j, dim*i-(dim-1):dim*i)=A_tilde(1:dim,1:dim)+127;
            end %end j
        end %end i
    end %end a

working_image2=uint8(junk-1);
%append _marked. to the input file name
output_addr = [image_addr,'_marked.'];
%append the file type to the output address
output_addr = [output_addr,image_type];
%write out input_file_marked.image_type
imwrite(working_image2,output_addr,image_type);
end 