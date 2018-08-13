% 2018-04-26
% PSD estimation by formula H = S/U

%close all force
close all hidden, clc, clear all;


strFolder = 'D:\work\other\2_Deblur\input5\';
%strFolder = 'D:\home\programming\vc\new\6_My home projects\2_Deblur\input2\';
% strFileNameU = strcat(strFolder,'DSC_0147_cut.JPG');
% strFileNameS = strcat(strFolder,'DSC_0148_cut.JPG');

strFileNameU = strcat(strFolder,'rect.png');
strFileNameS = strcat(strFolder,'rect.png');

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

imgU = double(imgU);
imgS = double(imgS);

imgU = imgU + 10*randn(size(imgU));

PSF = fspecial('disk',30);
imgS = imfilter(imgS ,PSF);

S = fft2(double(imgS));
U = fft2(double(imgU));

H_est = S./U;
%H_est = S./(U + 1/100);
h_est = ifft2(H_est);
h_est = fftshift(h_est);

disp(max(max(abs(real(H_est)))));
disp(max(max(abs(imag(H_est)))));

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
title('real(h est)');

subplot(2,2,4);
imshow(abs(h_est), []);
title('abs(h est)');
