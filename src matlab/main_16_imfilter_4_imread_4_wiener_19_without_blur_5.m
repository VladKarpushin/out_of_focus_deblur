% 2018-03-07
% Wiener debluring
% 2018-03-20
% added any size processing

%close all force
close all hidden, clc, clear all;


%strFolder = 'D:\home\programming\vc\new\6_My home projects\2_Deblur\input\';
strFolder = 'D:\home\programming\vc\new\6_My home projects\2_Deblur\input4_edges\';

%strFolder = 'D:\work\other\6_My home projects\2_Deblur\input\';

%strFileName = strcat(strFolder,'text_R=4.png');
%strFileName = strcat(strFolder,'pointNewRect.png');
%strFileName = strcat(strFolder,'text_R=4_border.png');
%strFileName = strcat(strFolder,'DSC_0138_cut_rect.JPG');
strFileName = strcat(strFolder,'IMG_0015.png');
%strFileName = strcat(strFolder,'DSC_0139.JPG');

imgA = imread(strFileName);
[h w c] = size(imgA);
if c == 3
    imgA = rgb2gray(imgA);
end

%************
% debluring *
%************
%NSR = 2/10000;      % NSR is the noise-to-signal power ratio of the additive noise
NSR = 1/1000;      % NSR is the noise-to-signal power ratio of the additive noise
%tic
%blurred_noisy = edgetaper(imgA,fspecial('disk',28));      %The output image J could exhibit ringing introduced by the discrete Fourier transform used in the algorithm
%toc
%tic
blurred_noisy = MyEdgetaperNew(imgA, 5.9, 0.2);
%toc

[n m]   = size(imgA);
PSF     = MyCircleNew(n, m, 28);   % point-spread function with which I was convolved

% tic
% wnr3    = deconvwnr(blurred_noisy, PSF, NSR);
% toc

tic
wnrMy   = MyDeconvwnr(blurred_noisy, PSF, NSR);
toc
% tic
% wnrMy   = deconvreg(blurred_noisy, PSF);
% toc

figure, 
subplot(2,2,1);
imshow(imgA, []);
title('img');
subplot(2,2,2);
imshow(blurred_noisy, []);
title('img after edgetaper');
subplot(2,2,3);
imshow(PSF, []);
title('PSF');
subplot(2,2,4);
imshow(wnrMy, []);
title('deblured by Wiener filter wnrMy');