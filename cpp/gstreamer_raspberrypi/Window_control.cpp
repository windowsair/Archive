//
// Created by 30349 on 2021/11/7.
//

#include "Window_control.h"
#include "opencv2/opencv.hpp"
#include "SafeQueue.hpp"

namespace wc {
    SafeQueue<cv::Mat> queue_ch1;
    SafeQueue<cv::Mat> queue_ch2;
    std::mutex cv_mtx;

    [[noreturn]] void onFrame_ch1() {
        cv::Mat frame;
        // blocking
        while (true) {
            while(queue_ch1.Consume(frame)) {
                printf("got 1\n");
                // Process the message
                cv_mtx.lock();
                cv::imshow("1", frame);
                cv::waitKey(1);
                cv_mtx.unlock();
            }
        }

    }

    [[noreturn]] void onFrame_ch2() {
        cv::Mat frame;
        // blocking
        while (true) {
            while(queue_ch2.Consume(frame)) {
                // Process the message
                printf("got 2\n");
                cv_mtx.lock();
                cv::imshow("2", frame);
                cv::waitKey(1);
                cv_mtx.unlock();
            }
        }

    }

}