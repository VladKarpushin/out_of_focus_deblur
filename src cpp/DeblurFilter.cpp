#include "DeblurFilter.hpp"

using namespace cv;
using namespace std;

void DeblurFilter::Edgetaper(const Mat& inputImg, Mat& outputImg, double gamma, double beta, bool bInverseFlag)
{
	int Nx = inputImg.cols;
	int Ny = inputImg.rows;
	Mat w1(1, Nx, CV_32F, Scalar(0));
	Mat w2(Ny, 1, CV_32F, Scalar(0));

	float* p1 = w1.ptr<float>(0);
	float* p2 = w2.ptr<float>(0);
	float dx = float(2.0 * CV_PI / Nx);
	float x = float(-CV_PI);
	for (int i = 0; i < Nx; i++)
	{
		p1[i] = float(0.5 * (tanh((x + gamma / 2) / beta) - tanh((x - gamma / 2) / beta)));
		x += dx;
	}


	float dy = float(2.0 * CV_PI / Ny);
	float y = float(-CV_PI);
	for (int i = 0; i < Ny; i++)
	{
		p2[i] = float(0.5 * (tanh((y + gamma / 2) / beta) - tanh((y - gamma / 2) / beta)));
		y += dy;
	}

	Mat w = w2 * w1;
	if (bInverseFlag)
		w = 1 - w;
	multiply(inputImg, w, outputImg);
}

void DeblurFilter::CalcEllipseWindow(Mat& outputImg, Size filterSize, Size rectSize)
{
	Mat H(filterSize, CV_32F, Scalar(0));
	Point point(filterSize.width / 2, filterSize.height / 2);
	circle(H, point, rectSize.width, 255, -1, 8);

	Scalar summa = sum(H);
	outputImg = H / summa[0];
}

void DeblurFilter::fftshift(const Mat& inputImg, Mat& outputImg)
{
	outputImg = inputImg(Rect(0, 0, inputImg.cols & -2, inputImg.rows & -2)).clone();
	int cx = outputImg.cols / 2;
	int cy = outputImg.rows / 2;
	Mat q0(outputImg, Rect(0, 0, cx, cy));
	Mat q1(outputImg, Rect(cx, 0, cx, cy));
	Mat q2(outputImg, Rect(0, cy, cx, cy));
	Mat q3(outputImg, Rect(cx, cy, cx, cy));
	Mat tmp;
	q0.copyTo(tmp);
	q3.copyTo(q0);
	tmp.copyTo(q3);
	q1.copyTo(tmp);
	q2.copyTo(q1);
	tmp.copyTo(q2);
}

void DeblurFilter::filter2DFreq(const Mat& inputImg, Mat& outputImg, const Mat& H)
{
	Mat planes[2] = {Mat_<float>(inputImg.clone()), Mat::zeros(inputImg.size(), CV_32F)};
	Mat complexI;
	merge(planes, 2, complexI);
	dft(complexI, complexI, DFT_SCALE);

	Mat planesH[2] = {Mat_<float>(H.clone()), Mat::zeros(H.size(), CV_32F)};
	Mat complexH;
	merge(planesH, 2, complexH);
	Mat complexIH;
	mulSpectrums(complexI, complexH, complexIH, 0);

	idft(complexIH, complexIH);
	split(complexIH, planes);
	outputImg = planes[0];
}

void DeblurFilter::CalcWnrFilter(const Mat& input_h_PSF, Mat& output_G, double nsr)
{
	Mat h_PSF_shifted;
	fftshift(input_h_PSF, h_PSF_shifted);
	Mat planes[2] = {Mat_<float>(h_PSF_shifted.clone()), Mat::zeros(h_PSF_shifted.size(), CV_32F)};
	Mat complexI;
	merge(planes, 2, complexI);
	dft(complexI, complexI);
	split(complexI, planes);
	Mat denom;
	pow(abs(planes[0]), 2, denom);
	denom += nsr;
	divide(planes[0], denom, output_G);
}

int DeblurFilter::ProcessMainLowLevelOptimized(const Mat& inputImg, Mat& input_G, Mat& outputImg, double gamma,
                                               double beta)
{
	// it needs to process even image only
	Rect roi = Rect(0, 0, inputImg.cols & -2, inputImg.rows & -2);
	//Mat imgIn = inputImg(roi).clone();
	Mat imgIn = inputImg(roi);

	imgIn.convertTo(imgIn, CV_32F);
	Edgetaper(imgIn, imgIn, gamma, beta);

	filter2DFreq(imgIn, outputImg, input_G);
	outputImg.convertTo(outputImg, CV_8U);
	return 0;
}

// return value from Process: 0 - Success, !0 - Code of an error
int DeblurFilter::Process(const Mat& inputImg, Mat& outputImg, int R, int snr)
{
	int flag = 0;
	Mat h, H, G;

	if (inputImg.empty())
		return -1;

	if (R < 1)
		return 1;

	if (R > 100)
		return 2;

	if (snr < 0)
		return 3;

	if (snr > 10000)
		return 4;

	try
	{
		flag = ProcessMainHighLevel(inputImg, outputImg, h, H, G, R, snr);
	}
	catch (const Exception& e)
	{
		return e.code;
	}
	return flag;
}

void DeblurFilter::CalcG(Mat& outputImg, Size imgSize, int delta, int R, double nsr)
{
	Rect roi = Rect(0, 0, (imgSize.width + 2 * delta) & -2, (imgSize.height + 2 * delta) & -2);
	Mat h;
	CalcEllipseWindow(h, roi.size(), Size(R, R));
	CalcWnrFilter(h, outputImg, nsr);
}

int DeblurFilter::ProcessMainHighLevel(const Mat& inputImg, Mat& outputImg, Mat& output_h, Mat& output_H, Mat& output_G,
                                       int R, int snr, double gamma, double beta)
{
	int flag = 0;
	vector<Mat> channelsIn, channelsOut;
	split(inputImg, channelsIn);
	int nChannels = inputImg.channels();

	//G calculation (start)
	int deltaB = cvRound(0.06 * max(inputImg.cols, inputImg.rows));
	Mat G;
	CalcG(G, inputImg.size(), deltaB, R, 1.0 / double(snr));
	cout << "gamma = " << gamma << endl;
	cout << "beta = " << beta << endl;
	cout << "snr = " << snr << endl;
	// G calculation (stop)

	for (int i = 0; i < nChannels; i++)
	{
		double t0, t1;
		t0 = (double)getTickCount();
		Mat imgExtended;
		copyMakeBorder(channelsIn[i], imgExtended, deltaB, deltaB, deltaB, deltaB, BORDER_REPLICATE);
		flag = ProcessMainLowLevelOptimized(imgExtended, G, outputImg);
		Rect roiB(deltaB, deltaB, inputImg.cols, inputImg.rows);
		channelsOut.push_back(outputImg(roiB));
		cout << "Method-B. ";
		t1 = ((double)getTickCount() - t0) / getTickFrequency();
		cout << "Elapsed  CPU time (ms)= " << 1000 * t1 << endl;
		cout << endl;
	}
	merge(channelsOut, outputImg);
	// size adjustment(start)
	int dx = inputImg.size().width - outputImg.size().width;
	int dy = inputImg.size().height - outputImg.size().height;
	copyMakeBorder(outputImg, outputImg, 0, dy, 0, dx, BORDER_CONSTANT);
	// size adjustment(stop)
	return flag;
}
