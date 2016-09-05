function pastCode()

I = imread('figure3.jpg');
imageOutput = contractImage(I,1.2,1.4);
imageOutput = houghTrans(imageOutput);

figure
imshow(I);

figure
imshow(imageOutput);
print output1.jpg -djpeg

end

function[imageOutput] = contractImage(imageInput, lowPara, HighPara)

imageSize = size(imageInput);
garyValue = rgb2gray(imageInput);

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

function [ output_args ] = houghTrans( input )
%HOUGHTRANS Summary of this function goes here
%   Detailed explanation goes here
I = rgb2gray(input);
BW = edge(I,'canny');
[H,T,R] = hough(BW);
imshow(H,[],'XData',T,'YData',R,'InitialMagnification','fit');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
P  = houghpeaks(H,10,'threshold',ceil(0.7*max(H(:))));
x = T(P(:,2)); y = R(P(:,1));
plot(x,y,'s','color','white');
% Find lines and plot them
lines = houghlines(BW,T,R,P,'FillGap',5,'MinLength',7);
figure, imshow(I), hold on
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'.','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'.','LineWidth',2,'Color','red');

   % Determine the endpoints of the longest line segment 
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end

% highlight the longest line segment
plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','cyan');

end
