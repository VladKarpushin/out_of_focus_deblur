Out-of-focus Deblur Filter
==========================

Goal
----

In this tutorial you will learn:

-   what a degradation image model is
-   what the PSF of an out-of-focus image is
-   how to restore a blurred image
-   what is a Wiener filter

Theory
------

### What is a degradation image model?

Here is a mathematical model of the image degradation in frequency domain representation:

[S = H*U + N]

where
S is a spectrum of blurred (degraded) image,
U is a spectrum of original true (undegraded) image,
H is a frequency response of point spread function (PSF),
N is a spectrum of additive noise.

The circular PSF is a good approximation of out-of-focus distortion. Such a PSF is specified by only one parameter - radius R. Circular PSF is used in this work.

![Circular point spread function](/www/images/psf.png)

### How to restore a blurred image?

The objective of restoration (deblurring) is to obtain an estimate of the original image. The restoration formula in frequency domain is:

[U' = H_w*S]

where
U' is the spectrum of estimation of original image U, and 
H_w is the restoration filter, for example, the Wiener filter.

### What is the Wiener filter?

The Wiener filter is a way to restore a blurred image. Let's suppose that the PSF is a real and symmetric signal, a power spectrum of the original true image and noise are not known,
then a simplified Wiener formula is:

[H_w = rac{H}{|H|^2+rac{1}{SNR}} ]

where
SNR is signal-to-noise ratio.

So, in order to recover an out-of-focus image by Wiener filter, it needs to know the SNR and R of the circular PSF.

Result
------

Below you can see the real out-of-focus image:
![Out-of-focus image](/www/images/original.jpg)


Below result was completed by R = 53 and SNR = 5200 parameters:
![The restored (deblurred) image](/www/images/recovered.jpg)

The Wiener filter was used, and values of R and SNR were selected manually to give the best possible visual result.
We can see that the result is not perfect, but it gives us a hint to the image's content. With some difficulty, the text is readable.

@note The parameter R is the most important. So you should adjust R first, then SNR.
@note Sometimes you can observe the ringing effect in a restored image. This effect can be reduced with several methods. For example, you can taper input image edges.

You can also find a quick video demonstration of this on
[YouTube](https://youtu.be/0bEcE4B0XP4).

References
------
- [Image Deblurring in Matlab] - Image Deblurring in Matlab
- [SmartDeblur] - SmartDeblur site

<!-- invisible references list -->
[Digital Image Processing]: http://web.ipac.caltech.edu/staff/fmasci/home/astro_refs/Digital_Image_Processing_2ndEd.pdf
[Image Deblurring in Matlab]: https://www.mathworks.com/help/images/image-deblurring.html
[SmartDeblur]: http://yuzhikov.com/articles/BlurredImagesRestoration1.htm
