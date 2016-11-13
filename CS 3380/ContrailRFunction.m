function ContrailRFunction( figNum, blockSize, p, fillGap, minLength )
%CONTRAILRF Summary of this function goes here
%   Detailed explanation goes here

    close all;
    
    if ~exist('blockSize','var')
        % third parameter does not exist, so default it to something
        blockSize = 7;
    end
    if ~exist('p','var')
        % third parameter does not exist, so default it to something
        p = 15;
    end
    if ~exist('fillGap','var')
        % third parameter does not exist, so default it to something
        fillGap = 400;
    end
    if ~exist('minLength','var')
        % third parameter does not exist, so default it to something
        minLength = 50;
    end
    
    fprintf('The figure is Figure %d\n',figNum);
    fprintf('the block size is %d\n',blockSize*2+1);
    fprintf('the percentage of kept blocks is %d\n',p);
    fprintf('the FillGap parameter for the Hough line detection is %d\n',fillGap);
    fprintf('the MinLength parameter for the Hough line detection is %d\n',minLength);
    
    start_time=tic;
    
    tagetFile = ['figure' int2str(figNum)];
    thre = [' blockSize=' num2str(blockSize) ' p=' num2str(p) ' FillGap=' num2str(fillGap) ' MinLength=' num2str(minLength)];
    
    outputtxtfile = ['rst/' tagetFile '/' tagetFile thre '.txt'];
    diary(outputtxtfile);
 
    %set up input filename and path
    inputPath = ['src/' tagetFile '.jpg'];    
    outputPath = ['rst/' tagetFile '/'];
 
    % read the original image and get the size of image
    I = imread(inputPath);
    figure
    imshow(I,[]);
    figName = ['Figure' num2str(figNum) ' Original Colour Image ' thre];
    title(figName);
    outPath = [outputPath figName '.jpg'];
    print(outPath,'-djpeg');
    
 
    %grayscale
    if(numel(size(I)==3))
        I=rgb2gray(I);
    end
    figure
    imshow(I);
   	figName = ['Figure' num2str(figNum) ' Grayvalue Image ' thre];
    title(figName);
    outPath = [outputPath figName '.jpg'];
    print(outPath,'-djpeg');
 
    % trial and error canny thresholds
    image=edge(I,'canny',[0.055,0.065]);
    figure
    imshow(~image,[]);
   	figName = ['Figure' num2str(figNum) ' Canny Detection ' thre];
    title(figName);
    outPath = [outputPath figName '.jpg'];
    print(outPath,'-djpeg');
 
    %===========================================================
    % The idea is to delete points that don't roughly lie
    % on a line, in neighbourhoods of size 2*blockSize+1 about
    % each pixel. Of course, border pixels within blockSize-1 of a border
    % will not get values (we set these to zero).
    % The equation of a line y=mx+b does not lend itself to
    % vertical lines as m is infinity here. So we consider
    % line at <= 45 degrees (|m| <= 1) and lines greater than 45% (|m|>1)
    % We need to consider |.| as m can be negative as well.
    % if |m| > 1 we use (y-b)/m=x as the equation of the line).
 
    % need to set image, blockSize, threshold
    % set threshold to 0 at first and examine all r values
 
    
    r_values=zeros(size(image),'double'); % all zero initially
 
    % set blockSize, the border width        
    WHITE=1;
    imageSize=size(I);
    cols = imageSize(1);
    rows = imageSize(2);
 
    side_length=2*blockSize+1;
    x_coords=zeros(side_length*side_length,1,'double');
    y_coords=zeros(side_length*side_length,1,'double');
 
    %%%%% Loop %%%%%
    for x=1+blockSize:cols-(1+blockSize)
    for y=1+blockSize:rows-(1+blockSize)
        %if((mod(x,5)==0) && y==blockSize+1)
            %fprintf('Line %d processed\n',x-1);
        %end % if
 
        % number of edgels at (x,y) whose neighbourhood are insufficient for computing a line
        num_no_lines=0;
 
        %fprintf('x=%d y=%d cols=%d rows=%d blockSize=%d s1=%d s2=%d tagetFile=%blockSize\n',x,y,cols,rows,blockSize,size(I,1),size(I,2),input_path);
        if(image(x,y)==WHITE) % pixel (x,y) is an edgel
            % for each x,y that is edgel do the following
            % step 1: setup equation for line in the square centered at (x,y)
            no_pts=0;
            for i=x-blockSize:x+blockSize
            for j=y-blockSize:y+blockSize
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
        end % if(image(x,y)==WHITE)
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
        
	new_image=zeros(size(image),'double'); % all white
	threshold=non_zero_r(cast(numel(non_zero_r)*(p/100),'int32'));
 
	figure
	hist(non_zero_r(:),51);
    figName = ['Figure' num2str(figNum) ' Histgram of All Blocks ' thre];
    title(figName);
    outPath = [outputPath figName '.jpg'];
    print(outPath,'-djpeg');
 
 
	% if good fit same the point in the new image, otherwise leave it black
    try
        for x=blockSize+1:cols-blockSize
        for y=blockSize+1:rows-blockSize
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
    figName = ['Figure' num2str(figNum) ' Block Processed ' thre];
    title(figName);
    outPath = [outputPath figName '.jpg'];
    print(outPath,'-djpeg');
 
    new_image = medfilt2(new_image,[2,2]);
    figure
    imshow(~new_image,[]);
    figName = ['Figure' num2str(figNum) ' Block Processed Image after Medfilter ' thre];
    title(figName);
    outPath = [outputPath figName '.jpg'];
    print(outPath,'-djpeg');
 
 
    [H,T,R] = hough(new_image);
    P  = houghpeaks(H,10,'threshold',ceil(0.7*max(H(:))));
    % Find lines and plot them
    lines = houghlines(new_image,T,R,P,'FillGap',fillGap,'MinLength',minLength);
    I = imread(inputPath);
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
   	figName = ['Figure' num2str(figNum) ' Final Output Figure ' thre];
    title(figName);
    outPath = [outputPath figName '.jpg'];
    print(outPath,'-djpeg');
    
    end_time = toc(start_time);
    fprintf('the program running time is %7.2f\n',end_time);
    
    diary off

end


