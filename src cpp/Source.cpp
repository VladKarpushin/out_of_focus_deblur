// 2018-03-11
// Debluring
// added Edgetaper
// 2018-03-12
// added Deconvwnr
// 2018-03-13
// added DeblurFilter class
// 2018-03-14
// added H and h output
// added time elapsed output
// 2018-03-15
// realised G output
// 2018-03-17
// realised any image size processing
// 2018-04-16
// corrected class


#include <opencv2/opencv.hpp>
#include <iostream>
#include <string>
#include "DeblurFilter.hpp"


using namespace cv;
using namespace std;

void help()
{
	cout << "2018-04-16" << endl;
	cout << "DeBlur_v8" << endl;
	cout << "Added edge processing. Speed optimized" << endl;
	//cout << "DeBlur.exe <file name> <R> <snr> <gamma>" << endl;
	cout << "DeBlur.exe <file name> <R> <snr>" << endl;
}

int main(int argc, char *argv[])
{
	help();

	int sigma1 = 28;
	// gamma		- this parameter effects on window size. gamma = 1 corresponds big edges, gamma = 6 corresponds small edges
	// beta			- this parameter effects on speed of decline of edges. beta = 0.1 corresponds quick decline, beta = 0.5 corresponds slow decline
	//double gamma = 5.9;
	//double gamma = 8;
	int snr = 100;
	//string str_Inpath = "D:\\work\\other\\2_Deblur\\input3\\";
	string str_Inpath = "D:\\work\\other\\2_Deblur\\input6\\";
	string str_Outpath = "D:\\work\\other\\2_Deblur\\output\\";
	//string str_Inpath = "D:\\home\\programming\\vc\\new\\6_My home projects\\2_Deblur\\input2\\";
	//string str_Outpath = "D:\\home\\programming\\vc\\new\\6_My home projects\\2_Deblur\\output\\";
	string strInFileName = "2.tif";
	//string strInFileName = "IMG_0015.png";
	//string strInFileName = "IMG_0015_2.png";

	if (argc == 3)
	{
		str_Inpath = "";
		str_Outpath = "";
		strInFileName = argv[1];
		sigma1 = atoi(argv[2]);

		cout << str_Inpath << endl;
		cout << str_Outpath << endl;
		cout << strInFileName << endl;
		cout << sigma1 << endl;
	}

	if (argc == 4)
	{
		str_Inpath = "";
		str_Outpath = "";
		strInFileName = argv[1];
		sigma1 = atoi(argv[2]);
		snr = atoi(argv[3]);

		cout << str_Inpath << endl;
		cout << str_Outpath << endl;
		cout << strInFileName << endl;
		cout << sigma1 << endl;
		cout << snr << endl;
	}

	Mat imgIn;
	imgIn = imread(str_Inpath + strInFileName, IMREAD_UNCHANGED);
	if (imgIn.empty()) //check whether the image is loaded or not
	{
		cout << "ERROR : Image cannot be loaded..!!" << endl;
		//system("pause"); //wait for a key press
		return -1;
	}

	//cvtColor(imgIn, imgIn, COLOR_BGR2GRAY);

	Mat imgOut;
	DeblurFilter filter;
	double t0, t1;
	t0 = (double)getTickCount();
	//filter.ProcessMain(imgIn, imgOut, h, H, G, FilterType, sigma1, sigma2, nsr, Gamma, beta);
	//filter.Process(imgIn, imgOut, sigma1, nsr, gamma);
	//Rect roi(1,0, imgIn.cols-1, imgIn.rows);
	//imgIn = imgIn(roi).clone();
	filter.Process(imgIn, imgOut, sigma1, snr);
	t1 = ((double)getTickCount() - t0) / getTickFrequency();
	cout << "Total elapsed  CPU time (ms)= " << 1000 * t1 << endl;
	cout << endl;

	imgOut.convertTo(imgOut, CV_8U);
	normalize(imgOut, imgOut, 0, 255, NORM_MINMAX);
	//normalize(h, h, 0, 255, NORM_MINMAX);
	//normalize(H, H, 0, 255, NORM_MINMAX);
	//normalize(G, G, 0, 255, NORM_MINMAX);
	////filter.fftshift(H,H);
	////filter.fftshift(G, G);
	//h.convertTo(h, CV_8U);
	//H.convertTo(H, CV_8U);
	//G.convertTo(G, CV_8U);

	string strOutFileName = strInFileName;
	char  buf[100];
	//sprintf_s(buf, "_R = %d_snr = %d_Gamma = %2.2f", sigma1, cvRound(1 / nsr), gamma);
	//sprintf_s(buf, "_R = %d_snr = %d_Gamma = %2.2f", sigma1, snr, gamma);
	sprintf_s(buf, "_R = %d_snr = %d", sigma1, snr);
	//sprintf_s(buf, "_R = %d", sigma1);
	strOutFileName.insert(strOutFileName.size() - 4, buf);

	//double kSize = max(imgOut.cols, imgOut.rows) / (double)1500.0;
	//Size newSize;
	//newSize.width = (int)floor((double)imgOut.cols / kSize);
	//newSize.height = (int)floor((double)imgOut.rows / kSize);
	//resize(imgOut, imgOut, newSize, 0.0, 0.0, INTER_LINEAR);
	imwrite(str_Outpath + strOutFileName, imgOut);
	//imwrite(str_Outpath + "\\h\\" + strOutFileName, h);
	//imwrite(str_Outpath + "\\HH\\" + strOutFileName, H);
	//imwrite(str_Outpath + "\\G\\" + strOutFileName, G);
	return 0;
}