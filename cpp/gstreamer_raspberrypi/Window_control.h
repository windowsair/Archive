//
// Created by 30349 on 2021/11/7.
//

#ifndef GSTREAMER_WINDOW_CONTROL_H
#define GSTREAMER_WINDOW_CONTROL_H

#include "opencv2/opencv.hpp"
#include "opencv2/opencv.hpp"
#include "SafeQueue.hpp"

namespace wc {
    extern SafeQueue<cv::Mat> queue_ch1;
    extern SafeQueue<cv::Mat> queue_ch2;

    [[noreturn]] void onFrame_ch1();

    [[noreturn]] void onFrame_ch2();

    class Window_control {
    public:
        Window_control() {

        }
    };
}


#endif //GSTREAMER_WINDOW_CONTROL_H
