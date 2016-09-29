%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find jet contrails in the image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;


for i = 1:5
    file = strcat('figure',int2str(i));
    outputtxtfile = strcat(file,'.txt');
    diary(outputtxtfile);
    
    tic;

    %set up input and output
    inputfilename = strcat(file,'.jpg');
    
    input_path = strcat('src/',inputfilename);
    outout_path = strcat('rst/',inputfilename);

    % read the original image and get the size of image
    I = imread(input_path);
    figure
    imshow(I,[]);
    title('Original Colour Image');

    %grayscale
    I=rgb2gray(I);
    figure
    imshow(I);
    title('Original Grayvalue Image')

    % trial and error canny thresholds
    image=edge(I,'canny',[0.055,0.065]);
    figure
    imshow(~image,[]);
    title('Original Canny Edgels');

    %===========================================================
    % The idea is to delete points that don't roughly lie
    % on a line, in neighbourhoods of size 2*s+1 about
    % each pixel. Of course, border pixels within s-1 of a border
    % will not get values (we set these to zero).
    % The equation of a line y=mx+b does not lend itself to
    % vertical lines as m is infinity here. So we consider
    % line at <= 45 degrees (|m| <= 1) and lines greater than 45% (|m|>1)
    % We need to consider |.| as m can be negative as well.
    % if |m| > 1 we use (y-b)/m=x as the equation of the line).

    % need to set image, s, threshold
    % set threshold to 0 at first and examine all r values

    new_image=zeros(size(image),'double'); % all white
    r_values=zeros(size(image),'double'); % all zero initially

    % set s, the border width
    for s = 6:8 
        WHITE=1;
        [cols,rows]=size(I);

        side_length=2*s+1;
        x_coords=zeros(side_length*side_length,1,'double');
        y_coords=zeros(side_length*side_length,1,'double');

        %%%%% Loop %%%%%
        for x=1+s:cols-s
        for y=1+s:rows-s
            if((mod(x,5)==0) && y==s+1) 
               fprintf('Line %d processed\n',x-1);
            end

        % number of edgels at (x,y) whose neighbourhood are insufficient for computing a line
        num_no_lines=0;

        if(image(x,y)==WHITE) % pixel (x,y) is an edgel
        % for each x,y that is edgel do the following
        % step 1: setup equation for line in the square centered at (x,y)
        no_pts=0;
        for i=x-s:x+s
        for j=y-s:y+s
            if(image(i,j)==WHITE)
                no_pts=no_pts+1;
                x_coords(no_pts)=i;
                y_coords(no_pts)=j;
            end % if
        end % j
        end % i

        % step 2: compute line
        r=0;
        if(no_pts>side_length) % at least 1 line of data coordinates in the square
             m=polyfit(x_coords(1:no_pts),y_coords(1:no_pts),1);  
             % step 3: depending on slope compute line
             % as y=mx+b or x=(y-b)/m. Check how well
             % predicted and observed x,y fit
             if(abs(m(1)) < 1) % <=45 degrees or >=-45 degrees
                % compute residual r as difference between measured 
                % and computed y coordinates.
                r=y_coords(1:no_pts)-polyval(m,x_coords(1:no_pts));
                r=sqrt(sum(r.*r)); % r was an array, no a single number
             else % >45 degrees or <-45 degrees
                % compute residual r as difference between measured 
                % and computed x coordinates.
                mp(1)=1.0/m(1); 
                mp(2)=-m(2)/m(1);
                r=x_coords(1:no_pts)-polyval(mp,y_coords(1:no_pts));
                r=sqrt(sum(r.*r));
             end % if
             r_values(x,y)=r; % save these as we need them to determine threshold
        else
             num_no_lines=num_no_lines+1;
        end % if(no_pts>2*side_length)
        end % if(image(x,y)==BLACK)
        end % y
        end % x


        % Determine good threshold as p percent of non-zero r_values
        non_zero_r=r_values(:);
        r_coords=find(non_zero_r~=0);
        % find non zero r values
        non_zero_r=non_zero_r(r_coords);
        non_zero_r=sort(non_zero_r(:));
        % determine the threshold as p percent of r values
        % For any p value in [0,100] compute the threshold 
        % to get p percent of points
        for p = [10,15,20]
            
            threshold=non_zero_r(cast(numel(non_zero_r)*(p/100),'int32'));

            figure
            hist(non_zero_r(:),51);
            title(['threshold=' num2str(threshold) ' p=' num2str(p)])


            % if good fit same the point in the new image, otherwise leave it black
            try
            for x=s+1:cols-s
            for y=s+1:rows-s
               if(r_values(x,y) < threshold && r_values(x,y)~=0) 
                 new_image(x,y)=WHITE;
               end % if
            end % y
            end % x
            catch
            fprintf('Subscript error occurs here: x=%d y=%d\n',x,y);
            end
            fprintf('threshold=%f\n',threshold);
            fprintf('number of edgel positions with no lines=%d\n',num_no_lines);
            fprintf('number of non-zero residual values=%d\n',numel(non_zero_r));
            fprintf('number of image pixels=%d\n',size(image,1)*size(image,2));
            figure
            imshow(~new_image,[])
            title('Thresholded Hough transform points');


            new_image = medfilt2(new_image,[2,2]);
            figure
            imshow(~new_image,[]);
            title('Hough transform points after medfilter.');


            [H,T,R] = hough(new_image);
            P  = houghpeaks(H,10,'threshold',ceil(0.7*max(H(:))));
            % Find lines and plot them
            lines = houghlines(new_image,T,R,P,'FillGap',400,'MinLength',50);
            I = imread(input_path);
            figure, imshow(I), hold on
            for k = 1:length(lines)
               fPoint = lines(k).point1;
               sPoint = lines(k).point2;
               xy = [fPoint; sPoint];
               plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

               % Plot beginnings and ends of lines
               plot(xy(1,1),xy(1,2),'.','LineWidth',2,'Color','yellow');
               plot(xy(2,1),xy(2,2),'.','LineWidth',2,'Color','red');

            end
            title('Final output');
            time = round(toc);

            fprintf('the program running time is %d.\n',time);

            diary off
        end
    end
end



