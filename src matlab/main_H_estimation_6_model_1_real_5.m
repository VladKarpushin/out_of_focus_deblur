% 2018-04-26
% PSD estimation by formula H = S/U

%close all force
close all hidden, clc, clear all;


%strFolder = 'D:\work\other\2_Deblur\input5\';
%strFolder = 'D:\home\programming\vc\new\6_My home projects\2_Deblur\input2\';
strFolder = 'D:\home\programming\vc\new\6_My home projects\2_Deblur\input7_raw_pana\';

strFileNameU = strcat(strFolder,'P1030440.rw2');
strFileNameS = strcat(strFolder,'P1030441.png');

% strFileNameU = strcat(strFolder,'DSC_0147_cut.JPG');
% strFileNameS = strcat(strFolder,'DSC_0148_cut.JPG');

% strFileNameU = strcat(strFolder,'U.tif');
% strFileNameS = strcat(strFolder,'S.tif');

% strFileNameU = strcat(strFolder,'rect.png');
% strFileNameS = strcat(strFolder,'rect.png');




% row=2248;  col=4000;
% %row=4000;  col=2248;
% fin=fopen(strFileNameU,'r');
% I1=fread(fin, [col row 3]);
% I1=fread(fin, [col row],'uint8=>double'); %// Red channel
% %I2=fread(fin, [col row],'uint8=>double'); %// Green channel
% %I3=fread(fin, [col row],'uint8=>double'); %// Blue channel
% I1 = I1.'; I2 = I2.'; I3 = I3.'; %// Transpose each channel separately
% Ifinal = cat(3, I1, I2, I3); %// Create 3D matrix
% imshow(Ifinal);
% fclose(fin);



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

% imgU = imgU + 10*randn(size(imgU));
% PSF = fspecial('disk',30);
% imgS = imfilter(imgS ,PSF);

imgU = MyEdgetaperNew(imgU, 5.5, 0.2);
imgS = MyEdgetaperNew(imgS, 5.5, 0.2);

S = fft2(double(imgS));
U = fft2(double(imgU));

H_est = S./U;
h_est = ifft2(H_est);
%h_est(1,1) = 0;
h_est = fftshift(h_est);

disp(max(max(abs(real(H_est)))));
disp(max(max(abs(imag(H_est)))));

disp(max(max(abs(real(h_est)))));
disp(max(max(abs(imag(h_est)))));

N = 30;
hh = (real(h_est));
figure, imshow(hh(h/2-N:h/2+N, w/2-N:w/2+N),[]);

hh = abs(hh);
figure, imshow(hh(h/2-N:h/2+N, w/2-N:w/2+N),[]);



% INITPSF = fspecial('disk',30);
% [J P] = deconvblind(imgS,INITPSF,30);
% figure
% imshow(J)
% title('Restored Image')
% figure
% imshow(P,[],'InitialMagnification','fit')
% title('Restored PSF')



%return;

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
