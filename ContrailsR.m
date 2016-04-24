function ContrailsR()

I = imread('pers2.jpg');
%I = rgb2gray(I);
contractImage(I);


end

function contractImage(imageInput)

imageSize = size(imageInput);
garyValue = garyscale(imageInput);

length = imageSize(1);
width = imageSize(2);
garyAverage = mean(mean(garyValue))*1.3;

%map = java.util.HashMap;
%color = 67;
%location = [1 2];
%map.put(color, location);

%answer = map.get(67);

for i = 1:length
    for j = 1:width
      
        if (garyValue(i,j)<garyAverage)
            imageInput(i,j,1)=0; 
            imageInput(i,j,2)=0; 
            imageInput(i,j,3)=0; 
        else
            imageInput(i,j,1)=255; 
            imageInput(i,j,2)=255; 
            imageInput(i,j,3)=255; 
        end
    end
end

figure
imshow(imageInput);
print output.jpg -djpeg
end

function [intensity] = garyscale(imageInput)
    red=squeeze(imageInput(:,:,1));
    green=squeeze(imageInput(:,:,2));
    blue=squeeze(imageInput(:,:,3)); 
    intensity = 0.2989.*red + 0.5870.*green + 0.1140.*blue;
end
