% 2018-07-23
% motion deblur
clc, clear all, close all;

strFolder = 'D:\home\programming\vc\new\6_My home projects\2_Deblur\input_motion_blur\';
strFileName = strcat(strFolder,'P1030470.JPG');

imgA = imread(strFileName);
[h w c] = size(imgA);
if c == 3
    imgA = rgb2gray(imgA);
end

figure,imshow(imgA);
h  = imdistline();
%pos = getPosition(h);
LEN = getDistance(h);
THETA = getAngleFromHorizontal(h);


%return;


%************
% debluring *
%************
NSR = 1/1000;      % NSR is the noise-to-signal power ratio of the additive noise

blurred_noisy = MyEdgetaperNew(imgA, 5.0, 0.2);

LEN = 159;
THETA = 14;
PSF = fspecial('motion', LEN, THETA);
wnr    = deconvwnr(blurred_noisy, PSF, NSR);


% tic
% wnrMy   = MyDeconvwnr(blurred_noisy, PSF, NSR);
% toc

figure,imshow(wnr);

% figure, 
% subplot(2,2,1);
% imshow(imgA, []);
% title('img');
% subplot(2,2,2);
% imshow(blurred_noisy, []);
% title('img after edgetaper');
% subplot(2,2,3);
% imshow(PSF, []);
% title('PSF');
% subplot(2,2,4);
% imshow(wnr, []);
% title('deblured by Wiener filter wnr');