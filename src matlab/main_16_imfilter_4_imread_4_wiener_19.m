% 2018-03-07
% Wiener debluring
% 2018-03-20
% added any size processing

%close all force
close all hidden, clc, clear all;

%********************
% image generation  *
%********************

N=250;             % even 2/4/6
Signal_type = 0;

switch Signal_type
    case 0      % white noise
        disp('Signal type: white noise')
        imgA = randn(N,N);
    case 1      % delta function
        disp('Signal type: delta function')
        imgA = zeros(N,N);
        imgA(N/2,N/2) = 1;
end

%strFolder = 'D:\home\programming\vc\new\6_My home projects\2_Deblur\input\';
strFolder = 'D:\work\other\6_My home projects\2_Deblur\input\';

%strFileName = strcat(strFolder,'text_R=4.png');
%strFileName = strcat(strFolder,'pointNewRect.png');
%strFileName = strcat(strFolder,'text_R=4_border.png');
%strFileName = strcat(strFolder,'DSC_0138_cut_rect.JPG');
strFileName = strcat(strFolder,'DSC_0140.JPG');



imgA = imread(strFileName);
N = length(imgA);
[h w c] = size(imgA);
if c == 3
    imgA = rgb2gray(imgA);
end

%imgA = imgA(1:250,1:250);



imgA_fft = fft2(imgA);

imgA_PSD = imgA_fft.*conj(imgA_fft);
imgA_PSD(1,1) = 0;
imgA_PSD = fftshift(imgA_PSD);

figure, 
subplot(2,2,1);
imshow(imgA, []);
title('img');
subplot(2,2,2);
imshow(imgA_PSD, []);
title('PSD');


%***********
% bluring  *
%***********

nFilter = 3;        % filter ID
sigma1 = 0.6;
sigma2 = 0.6;

nfft = N;
x = -pi:2*pi/nfft:pi-pi/nfft;

switch nFilter
    case 0      % Gauss process
        disp('Filter type: H = exp(-x^2)')
        H1 = exp(-1/2*(x/sigma1).^2)';
        H2 = exp(-1/2*(x/sigma2).^2)';
        H = H1*H2';
        subplot(2,2,3);
        imshow(H,[]);
        title('filter H');
        imgC = filter2DFreq(imgA, H);
    case 1      % Markov process
        disp('Filter type: H = exp(-abs(x))')
        H1 = exp(-1/2*abs(x/sigma1))';      
        H2 = exp(-1/2*abs(x/sigma2))';
        H = H1*H2';
        subplot(2,2,3);
        imshow(H,[]);
        title('filter H');
        imgC = filter2DFreq(imgA, H);
    case 2      % rectangle
        disp('Filter type: H = rectangle')
        w = 11;  %odd 3/5/7
        h = 11;  %odd 
        H1 = zeros(N,1);
        H2 = zeros(N,1);
        H1(N/2-w/2+1:N/2+w/2) = 1;
        H2(N/2-h/2+1:N/2+h/2) = 1;
        H = H1*H2';
        subplot(2,2,3);
        imshow(H,[]);
        title('filter H');
        imgC = filter2DFreq(imgA, H);
    case 3
        disp('Filter type: H = ellipse')
        R = 11;  % odd or even, any
        [n m] = size(imgA);
        H = MyCircleNew(n, m, R);   % point-spread function with which I was convolved
        %H = MyCircleNew(N, R);
        subplot(2,2,3);
        imshow(H,[]);
        title('filter H');
        imgC = filter2DFreq(imgA, H);
    case 4
        disp('Filter type: h = circle')
        R = 4;  % odd or even, any
        %h = MyCircle(N, R);
        h = fspecial('disk', R);
        imgC = imfilter(imgA, h);
        subplot(2,2,3);
        imshow(h,[]);
        title('filter h');
    case 5
        disp('Filter type: h = special mask')
        b = 5;  % odd or even, any
        h = zeros(3,3);
        h(1,2) = -b;
        h(2,1) = -b;
        h(2,3) = -b;
        h(3,2) = -b;
        h(2,2) = 1+4*b;        
        imgC = imfilter(imgA, h);
        subplot(2,2,3);
        imshow(h,[]);
        title('filter h');
end

subplot(2,2,4);
imshow(imgC,[]);
title('Filtered image');
%imwrite(imgC,strcat(strFolder,'text_R=2.png'));

%return;

%************
% debluring *
%************
%blurred_noisy = imgA;
NSR = 6/10000;      % NSR is the noise-to-signal power ratio of the additive noise
%blurred_noisy = edgetaper(blurred_noisy,fspecial('gaussian',60,10));      %The output image J could exhibit ringing introduced by the discrete Fourier transform used in the algorithm
blurred_noisy = MyEdgetaperNew(imgA,5.5, 0.2);
%blurred_noisy = padarray(blurred_noisy,[50 50]);

%PSF = MyCircle(N, 40);   % point-spread function with which I was convolved
[n m] = size(imgA);
PSF = MyCircleNew(n, m, 130);   % point-spread function with which I was convolved
wnr3    =   deconvwnr(blurred_noisy, PSF, NSR);
wnrMy   =   MyDeconvwnr(blurred_noisy, PSF, NSR);

figure, 
subplot(2,2,1);
imshow(blurred_noisy, []);
title('img');
subplot(2,2,2);
imshow(wnr3, []);
title('deblured by Wiener filter');
subplot(2,2,3);
imshow(PSF, []);
title('PSF');
subplot(2,2,4);
imshow(wnrMy, []);
title('deblured by Wiener filter wnrMy');