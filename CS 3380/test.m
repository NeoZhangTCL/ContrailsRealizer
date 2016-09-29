    i=3;
    file = strcat('figure',int2str(i));
    outputtxtfile = strcat(file,'.txt');
    diary(outputtxtfile);
    
    %set up input and output
    inputfilename = strcat(file,'.jpg');
    input_path = strcat('src/',inputfilename);
    outout_path = strcat('rst/',inputfilename);

    % read the original image and get the size of image
    I = imread(input_path);
    figure(h)
    imshow(I,[]);
    title('Original Colour Image');
    