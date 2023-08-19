#pragma once

#include <string>

#include <opencv2/opencv.hpp>

#include "TextRecognizer/TextRecognizer.h"

class MyToolNameRecognizer {
public:
	MyToolNameRecognizer(cv::Rect _rect, double _thresh)
		: rect(_rect), thresh(_thresh)
	{
	}

	std::string operator()(const cv::Mat &myPokemonImageGray) const
	{
		const auto nameImageGray = myPokemonImageGray(rect);
		cv::Mat nameImageBinary;
		cv::threshold(nameImageGray, nameImageBinary, thresh, 255,
			      cv::THRESH_BINARY_INV);
		return recognizeText(nameImageBinary);
	}

private:
	cv::Rect rect;
	double thresh;
};
