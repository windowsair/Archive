//
// Created by 30349 on 2021/11/7.
//

#ifndef GSTREAMER_CALC_H
#define GSTREAMER_CALC_H

#include <cmath>
#include <stdint.h>

#define PI 3.14159265358979323846

class calc {
private:
    struct data_type {
        float last_left_diff;
        float last_left;
        float current_left;
        float last_right_diff;
        float last_right;
        float current_right;
        int64_t last_time_T;
        int64_t last_time;
        int64_t current_time;
    };
    enum DIR_ENUM_TYPE {
        DIR_NONE = 0,
        DIR_LEFT,
        DIR_RIGHT
    };
    struct start_type {
        DIR_ENUM_TYPE direction;
        int64_t time;
    };
    struct max_type {
        float sum;
        int cnt;
    };
    struct current_data_type {
        float left;
        float right;
        int64_t time;
    };

    int64_t min_t;
    int64_t max_t;
    data_type data;
    start_type start;
    max_type max_left;
    max_type max_right;
    int cnt; // 周期数
    DIR_ENUM_TYPE flag;

public:
    /**
     *
     * @param T 周期
     * @param L 长度
     * @return
     */
    float get_g(float T, float L) {
        // g = (2 * PI) ** 2 / T ** 2 * L
        float g = (2 * PI) * (2 * PI);
        g /= T;
        g *= g;
        g *= L;
        return g;
    }

    /**
     *
     * @param T 周期
     * @param g 重力加速度
     * @return
     */
    float get_l(float T, float g = 9.8) {
        // l = (T/2/pi)**2*g
        float l = T / 2.0f / PI;
        l *= l;
        l *= g;
        return l;
    }

    float get_theta(float x, float y) {
        float theta = 180.0f * std::atan(x / y) / PI;
        return theta;
    }

    calc() : min_t(11), max_t(100), cnt(0), flag(DIR_NONE) {
        start.direction = DIR_NONE;
        start.time = 0;
        max_left.cnt = 0;
        max_left.sum = 0;
        max_right.cnt = 0;
        max_right.sum = 0;
        data.last_left_diff = 0;
        data.last_left = 0;
        data.current_left = 0;
        data.last_right_diff = 0;
        data.last_right = 0;
        data.current_right = 0;
        data.last_time_T = 0;
        data.last_time = 0;
        data.current_time = 0;
    }

    void clear() {
        start.direction = DIR_NONE;
        start.time = 0;
        max_left.cnt = 0;
        max_left.sum = 0;
        max_right.cnt = 0;
        max_right.sum = 0;
        data.last_left_diff = data.last_left = data.current_left = 0;
        data.last_right_diff = data.last_right = data.current_right = 0;
        cnt = 0;
        flag = DIR_NONE;
    }

    std::pair<float, float> calculate(current_data_type current_data) {
        data.last_left = data.current_left;
        data.last_right = data.current_right;
        data.last_time = data.current_time;

        data.current_left = current_data.left;
        data.current_right = current_data.right;
        data.current_time = current_data.time;

        float current_left_diff = data.current_left - data.last_left;
        float current_right_diff = data.current_right - data.last_right;
        if (data.last_left_diff < 0 && current_left_diff > 0) {
            // 刚经过左侧极点
            flag = DIR_LEFT;
            max_left.sum += data.last_left;
            max_left.cnt++;
        } else if (data.last_right_diff > 0 && current_right_diff < 0) {
            // 刚经过右侧极点
            flag = DIR_RIGHT;
            max_right.sum += data.last_right;
            max_right.cnt++;
        } else {
            flag = DIR_NONE;
        }

        data.last_left_diff = current_left_diff;
        data.last_right_diff = current_right_diff;
        if (start.direction == DIR_NONE) {
            start.direction = flag;
            start.time = data.last_time;
        }

        // 若干个完整周期
        if (flag != DIR_NONE && flag == start.direction) {
            // 时间差小于理论最小周期，说明出现震荡，直接忽略即可
            if (data.current_time - data.last_time_T < min_t) { ; // pass
            }
                //# 时间差大于理论最大周期，说明出现漏检（这里有bug：我默认只会漏检1次）
            else if (data.current_time - data.last_time_T > max_t) {
                data.last_time_T = data.last_time;
                cnt += 2;
            }
                // 正常的一个周期
            else {
                data.last_time_T = data.last_time;
                cnt++;
            }
        }

        float T = NAN, A = NAN;
        if (cnt >= 5) {
            T = (data.last_time - start.time) / (float) cnt;
            A = (max_right.sum / max_right.cnt - max_left.sum / max_left.cnt) / 2.0f;
        }

        return {T, A};

    }
};

#endif //GSTREAMER_CALC_H
