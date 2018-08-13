% 2018-03-07
% Wiener debluring
% 2018-03-20
% added any size processing

%close all force
close all hidden, clc, clear all;


strFolder = 'D:\home\programming\vc\new\6_My home projects\2_Deblur\input2\';
% strFileNameU = strcat(strFolder,'DSC_0147_cut.JPG');
% strFileNameS = strcat(strFolder,'DSC_0148_cut.JPG');

strFileNameU = strcat(strFolder,'DSC_0147.JPG');
strFileNameS = strcat(strFolder,'DSC_0152.JPG');

imgU = imread(strFileNameU);
[h w c] = size(imgU);
if c == 3
    imgU = rgb2gray(imgU);
end

imgS = imread(strFileNameS);
[h w c] = size(imgS);
if c == 3
    imgS = rgb2gray(imgS);
end


S = fft2(double(imgS));
U = fft2(double(imgU));
H_est = S./U;
h_est = ifft2(H_est);
%h_est = fftshift(h_est);

disp(max(max(abs(real(h_est)))));
disp(max(max(abs(imag(h_est)))));


figure, 
subplot(2,2,1);
imshow(imgU, []);
title('imgU');
subplot(2,2,2);
imshow(imgS, []);
title('imgS');

subplot(2,2,3);
imshow(abs(real(h_est)), []);
title('real(h ets)');

subplot(2,2,4);
imshow(abs(h_est), []);
title('abs(h est)');
