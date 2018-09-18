#include <opencv2/opencv.hpp>

class DeblurFilter
{
public:
	// input point of the filter
	// return value from Process: 0 - Success, !0 - Code of an error
	int Process(const cv::Mat& inputImg, cv::Mat& outputImg, int R, int snr);

private:
	// input point of the filter
	int ProcessMainHighLevel(const cv::Mat& inputImg, cv::Mat& outputImg, cv::Mat& output_h, cv::Mat& output_H, cv::Mat& output_G, int R, int snr, double gamma = 5.9, double beta = 0.2);

	int ProcessMainLowLevelOptimized(const cv::Mat& inputImg, cv::Mat& input_G, cv::Mat& outputImg, double gamma = 5.9, double beta = 0.2);

	void Edgetaper(const cv::Mat& inputImg, cv::Mat& outputImg, double gamma, double beta, bool bInverseFlag = false);

	void CalcEllipseWindow(cv::Mat& outputImg, cv::Size filterSize, cv::Size rectSize);

	void CalcG(cv::Mat& outputImg, cv::Size imgSize, int delta, int R, double nsr);

	void fftshift(const cv::Mat& inputImg, cv::Mat& outputImg);
	
	void filter2DFreq(const cv::Mat& inputImg, cv::Mat& outputImg, const cv::Mat& H);
	
	void CalcWnrFilter(const cv::Mat& input_h_PSF, cv::Mat& output_G, double nsr);
};