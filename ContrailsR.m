function ContrailsR()

I = imread('pers2.jpg');
%I = rgb2gray(I);
contractImage(I);


end

function contractImage(imageInput)

imageSize = size(imageInput);
[red, green, blue] = getColorLayer(imageInput);

length = imageSize(1);
width = imageSize(2);
%redMean = mean(mean(red))*1.3;
%blueMean = mean(mean(blue))*1.3;
%greenMean = mean(mean(green))*1.3;

map = java.util.HashMap;
location = [1,2];
color = [0, 255, 26];
map.put(location, color);

answer = map.get([1,2]);

for i = 1:length
    for j = 1:width
      
%        if (red(i,j)<redMean||blue(i,j)<blueMean||green(i,j)<greenMean)
%            imageInput(i,j,1)=0; 
%            imageInput(i,j,2)=0; 
%            imageInput(i,j,3)=0; 
%        else
%            imageInput(i,j,1)=255; 
%            imageInput(i,j,2)=255; 
%            imageInput(i,j,3)=255; 
%        end
    end
end

figure
imshow(imageInput);
print output.jpg -djpeg
end

function [red, green, blue] = getColorLayer(imageInput)
    red=squeeze(imageInput(:,:,1));
    green=squeeze(imageInput(:,:,2));
    blue=squeeze(imageInput(:,:,3));    
end
