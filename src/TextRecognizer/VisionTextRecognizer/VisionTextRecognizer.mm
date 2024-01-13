#include <functional>
#include <string>

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import <Vision/Vision.h>

#include <opencv2/opencv.hpp>

#include <obs.h>

#include "plugin-support.h"

CGImageRef convertBinarytoCgImage(const cv::Mat &imageBGRA)
{
	CVPixelBufferRef pixelBuffer;
	CVReturn retPixelBuffer = CVPixelBufferCreateWithBytes(
		kCFAllocatorDefault, imageBGRA.cols, imageBGRA.rows,
		kCVPixelFormatType_OneComponent8, imageBGRA.data,
		imageBGRA.cols, NULL, NULL, NULL, &pixelBuffer);
	if (retPixelBuffer != kCVReturnSuccess) {
		blog(LOG_ERROR, "CVPixelBuffer creation failed! %d",
		     retPixelBuffer);
		if (pixelBuffer != NULL) {
			CFRelease(pixelBuffer);
		}
		return NULL;
	}

	CGImageRef image;
	OSStatus retImage =
		VTCreateCGImageFromCVPixelBuffer(pixelBuffer, NULL, &image);
	if (retImage != noErr) {
		blog(LOG_ERROR, "CGImage creation failed!");
		if (image != NULL) {
			CFRelease(image);
		}
		return NULL;
	}
	CFRelease(pixelBuffer);

	return image;
}

class VisionTextRecognizer {
public:
	std::string recognizeByVision(CGImageRef image);

private:
	std::string resultText;
};

std::string VisionTextRecognizer::recognizeByVision(CGImageRef image)
{
	VNImageRequestHandler *requestHandler = [[VNImageRequestHandler alloc]
		initWithCGImage:image
			options:@{}];
	VNRecognizeTextRequest *request = [[VNRecognizeTextRequest alloc]
		initWithCompletionHandler:^(VNRequest *req, NSError *err) {
			if (err) {
				NSLog(@"%@", err);
				return;
			}
			for (VNRecognizedTextObservation *observation in req
				     .results) {
				NSArray<VNRecognizedText *> *candidates =
					[observation topCandidates:1];
				VNRecognizedText *recognizedText =
					[candidates firstObject];
				NSString *nsString = recognizedText.string;
				resultText += [nsString UTF8String];
			}
		}];
	request.usesCPUOnly = true;
	request.recognitionLanguages = @[@"ja-JP"];
	NSError *_Nullable error;
	[requestHandler performRequests:@[request] error:&error];
	return resultText;
}

void recognizeText(const cv::Mat &imageBinary,
		   std::function<void(std::string)> callback)
{
	cv::Size destSize(imageBinary.cols * 4, imageBinary.rows * 4);
	cv::Mat resizedBinary;
	cv::resize(imageBinary, resizedBinary, destSize);

	cv::Mat paddedImageBinary;
	cv::copyMakeBorder(resizedBinary, paddedImageBinary,
			   resizedBinary.rows / 4, resizedBinary.rows / 4,
			   resizedBinary.cols / 4, resizedBinary.cols / 4,
			   cv::BORDER_CONSTANT, cv::Scalar(255));

	CGImageRef image = convertBinarytoCgImage(paddedImageBinary);
	if (image == NULL) {
		obs_log(LOG_INFO, "Couldn't convert cv::Mat to CGImage!");
		callback("");
		return;
	}

	__block VisionTextRecognizer recognizer;

	dispatch_async(
		dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
		^{
			std::string result =
				recognizer.recognizeByVision(image);
			CFRelease(image);
			callback(result);
		});
}
