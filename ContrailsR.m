function ContrailsR()

I = imread('pers2.jpg');
imageOutput = contractImage(I,1.3,2);

figure
imshow(I);

figure
imshow(imageOutput);
print output.jpg -djpeg

end

function[imageOutput] = contractImage(imageInput, lowPara, HighPara)

imageSize = size(imageInput);
garyValue = garyscale(imageInput);

length = imageSize(1);
width = imageSize(2);
garyLow = mean(mean(garyValue))*lowPara;
garyHigh = mean(mean(garyValue))*HighPara;

for i = 1:length
    for j = 1:width
        if (garyValue(i,j)<garyLow||garyValue(i,j)>garyHigh)
            imageOutput(i,j,1)=0; 
            imageOutput(i,j,2)=0; 
            imageOutput(i,j,3)=0; 
        else
            imageOutput(i,j,1)=255; 
            imageOutput(i,j,2)=255; 
            imageOutput(i,j,3)=255; 
        end
    end
end

end

function [intensity] = garyscale(imageInput)
    red=squeeze(imageInput(:,:,1));
    green=squeeze(imageInput(:,:,2));
    blue=squeeze(imageInput(:,:,3)); 
    intensity = 0.2989.*red + 0.5870.*green + 0.1140.*blue;
end
