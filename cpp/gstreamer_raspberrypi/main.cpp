#include "QtWidgetsApplication1.h"
#include <QtWidgets/QApplication>


#include <gst/gst.h>
#include <string>
#include <thread>
#include <mutex>
#include <opencv2/opencv.hpp>
#include "calc.h"
#include "Window_control.h"


std::mutex mtx;

static gboolean printStructureField(GQuark field, const GValue *value, gpointer prefix) {
    gchar *str = gst_value_serialize(value);
    g_print("%s  %15s: %s\n", (gchar *) prefix, g_quark_to_string(field), str);
    g_free(str);
    return TRUE;
}

static gboolean printBuffer(GstBuffer *buffer, gpointer userData) {
    gsize bufSize = gst_buffer_get_size(buffer);
    g_print("%s  %15s: %d\n", (gchar *) userData, "size", bufSize);
    return TRUE;
}

static gboolean printBufferList(GstBuffer **buffer, guint idx, gpointer userData) {
    return printBuffer(buffer[idx], userData);
}


static GstFlowReturn onNewVideoSample(GstElement *sink, void *ctx) {
    static int i = 0;
    printf("%d\n", i++);
    GstSample *sample;
    const gchar *prefix = "    ";

    static int frameCtr = 0;

    // Retrieve the buffer
    g_signal_emit_by_name(sink, "pull-sample", &sample);
    if (++frameCtr % 25 != 0) {
        //skip most of the samples, take one per second from most of cameras (generally 25fps)
//        if (sample) {
//            gst_sample_unref(sample);
//            return GST_FLOW_OK;
//        }
    }

    if (sample) {
        //g_print("=================\n");
        gint width = 0;
        gint height = 0;

        GstCaps *sampleCaps = gst_sample_get_caps(sample);
        if (sampleCaps) {
            if (gst_caps_is_any(sampleCaps)) {
                g_print("%sANY\n", prefix);
            }
            if (gst_caps_is_empty(sampleCaps)) {
                g_print("%sEMPTY\n", prefix);
            }

            for (unsigned int i = 0; i < gst_caps_get_size(sampleCaps); i++) {
                GstStructure *structure = gst_caps_get_structure(sampleCaps, i);

                //g_print ("%s%s\n", prefix, gst_structure_get_name(structure));
                //gst_structure_foreach(structure, printStructureField, (gpointer) prefix);

                //if (gst_structure_has_field(structure, "width")) {
                //    GType type = gst_structure_get_field_type(structure, "width");
                //    g_print("Width type %s\n" , g_type_name(type));
                //}

                gst_structure_get_int(structure, "width", &width);
                gst_structure_get_int(structure, "height", &height);
            }
        }

        const GstStructure *sampleInfo = gst_sample_get_info(sample);
        if (sampleInfo) {
            g_print("%s%s\n", prefix, gst_structure_get_name(sampleInfo));
            gst_structure_foreach(sampleInfo, printStructureField, (gpointer) prefix);
        }

        GstBufferList *sampleBuffers = gst_sample_get_buffer_list(sample);
        if (sampleBuffers) {
            g_print("%sBuffers %d\n", prefix, gst_buffer_list_length(sampleBuffers));
            gst_buffer_list_foreach(sampleBuffers, printBufferList, (gpointer) prefix);
        }

        GstBuffer *sampleBuffer = gst_sample_get_buffer(sample);
        if (sampleBuffer) {
            //g_print ("%sOnly Buffer\n", prefix);
            //printBuffer(sampleBuffer,(gpointer) prefix);

            //g_print("%sDim %dx%d\n", prefix, width, height);
            //g_print ("%sCalc size %d\n", prefix, width*height*3);//BGR

            GstMapInfo map;
            gst_buffer_map(sampleBuffer, &map, GST_MAP_READ);
            // Convert gstreamer data to OpenCV Mat
            cv::Mat frame(cv::Size(width, height), CV_8UC3, (char *) map.data);
//            mtx.lock();
//            //cv::imshow("OpenCV Frame", frame);
//            cv::waitKey(1);
//            mtx.unlock();
            wc::queue_ch1.Produce(frame);

            gst_buffer_unmap(sampleBuffer, &map);
            //
        }

        gst_sample_unref(sample);
        return GST_FLOW_OK;
    }

    return GST_FLOW_ERROR;
}


static GstFlowReturn onNewVideoSample1(GstElement *sink, void *ctx) {
    static int i = 0;
    printf("%d\n", i++);
    GstSample *sample;
    const gchar *prefix = "    ";

    static int frameCtr = 0;

    // Retrieve the buffer
    g_signal_emit_by_name(sink, "pull-sample", &sample);
    if (++frameCtr % 25 != 0) {
        //skip most of the samples, take one per second from most of cameras (generally 25fps)
//        if (sample) {
//            gst_sample_unref(sample);
//            return GST_FLOW_OK;
//        }
    }

    if (sample) {
        //g_print("=================\n");
        gint width = 0;
        gint height = 0;

        GstCaps *sampleCaps = gst_sample_get_caps(sample);
        if (sampleCaps) {
            if (gst_caps_is_any(sampleCaps)) {
                g_print("%sANY\n", prefix);
            }
            if (gst_caps_is_empty(sampleCaps)) {
                g_print("%sEMPTY\n", prefix);
            }

            for (unsigned int i = 0; i < gst_caps_get_size(sampleCaps); i++) {
                GstStructure *structure = gst_caps_get_structure(sampleCaps, i);

                //g_print ("%s%s\n", prefix, gst_structure_get_name(structure));
                //gst_structure_foreach(structure, printStructureField, (gpointer) prefix);

                //if (gst_structure_has_field(structure, "width")) {
                //    GType type = gst_structure_get_field_type(structure, "width");
                //    g_print("Width type %s\n" , g_type_name(type));
                //}

                gst_structure_get_int(structure, "width", &width);
                gst_structure_get_int(structure, "height", &height);
            }
        }

        const GstStructure *sampleInfo = gst_sample_get_info(sample);
        if (sampleInfo) {
            g_print("%s%s\n", prefix, gst_structure_get_name(sampleInfo));
            gst_structure_foreach(sampleInfo, printStructureField, (gpointer) prefix);
        }

        GstBufferList *sampleBuffers = gst_sample_get_buffer_list(sample);
        if (sampleBuffers) {
            g_print("%sBuffers %d\n", prefix, gst_buffer_list_length(sampleBuffers));
            gst_buffer_list_foreach(sampleBuffers, printBufferList, (gpointer) prefix);
        }

        GstBuffer *sampleBuffer = gst_sample_get_buffer(sample);
        if (sampleBuffer) {
            //g_print ("%sOnly Buffer\n", prefix);
            //printBuffer(sampleBuffer,(gpointer) prefix);

            //g_print("%sDim %dx%d\n", prefix, width, height);
            //g_print ("%sCalc size %d\n", prefix, width*height*3);//BGR

            GstMapInfo map;
            gst_buffer_map(sampleBuffer, &map, GST_MAP_READ);
            // Convert gstreamer data to OpenCV Mat
            cv::Mat frame(cv::Size(width, height), CV_8UC3, (char *) map.data);
//            mtx.lock();
//            //cv::imshow("OpenCV Frame2", frame);
//            cv::waitKey(1);
//            mtx.unlock();
            wc::queue_ch2.Produce(frame);
            gst_buffer_unmap(sampleBuffer, &map);

        }

        gst_sample_unref(sample);
        return GST_FLOW_OK;
    }

    return GST_FLOW_ERROR;
}

//#define USE_PLAYBIN

void work_thread(int parameter) {
    char p_num[] = {'0', '\0'};
    printf("%d start\n", parameter);
    p_num[0] = '0' + parameter;
    char *argv[] = {(char *) p_num, nullptr};
    char **p_argv = (char **) argv;
    int tmp_count = 1;
    gst_init(&tmp_count, &p_argv);

    auto pipeline_des = "rtspsrc location="
                        "rtsp://admin:s123456789@192.168.1.1:5555/h264/ch1/sub/av_stream"
                        "  latency=100 name=m_rtspsrc ! rtph264depay ! h264parse ! v4l2h264dec capture-io-mode=4"
                        " ! video/x-raw ! v4l2convert output-io-mode=5 capture-io-mode=4  ! video/x-raw,  format=BGR,  width=320, height=240"
                        " ! videorate ! video/x-raw,framerate=15/1 ! appsink name=mysink sync=false";


    auto pipeline_des1 = "rtspsrc location="
                         "rtsp://admin:s123456789@192.168.1.2:5555/h264/ch1/sub/av_stream"
                         "  latency=100 name=m_rtspsrc ! rtph264depay ! h264parse ! v4l2h264dec capture-io-mode=4"
                         " ! video/x-raw ! v4l2convert output-io-mode=5 capture-io-mode=4  ! video/x-raw,  format=BGR,  width=320, height=240"
                         " ! videorate ! video/x-raw,framerate=15/1 ! appsink name=mysink1 sync=false";

    GstElement *pipeline = nullptr;
    GstElement *appSink = nullptr;

    //GstElement *pipeline = gst_parse_launch("uridecodebin uri=rtsp://userName:password@ipForYouRtspCamera:554/videoMain ! videoconvert ! appsink name=mysink", NULL);
    if (parameter == 0) {
        pipeline = gst_parse_launch(pipeline_des, nullptr);
    } else {
        pipeline = gst_parse_launch(pipeline_des1, nullptr);
    }

    // Get own elements
    if (parameter == 0) {
        appSink = gst_bin_get_by_name(GST_BIN(pipeline), "mysink");
    } else {
        appSink = gst_bin_get_by_name(GST_BIN(pipeline), "mysink1");
    }

    if (!pipeline || !appSink) {
        g_printerr("Not all elements could be created.\n");
        return;
    }


    // Configure appsink
    GstCaps *appVideoCaps = gst_caps_new_simple("video/x-raw",
                                                "format", G_TYPE_STRING, "BGR",//"BGR",
                                                nullptr);
    g_object_set(appSink, "emit-signals", TRUE, "caps", appVideoCaps, nullptr);
    void *newSampleCtx = nullptr;
    if (parameter == 0) {
        g_signal_connect(appSink, "new-sample", G_CALLBACK(onNewVideoSample), newSampleCtx);
    } else {
        g_signal_connect(appSink, "new-sample", G_CALLBACK(onNewVideoSample1), newSampleCtx);
    }

//    gst_caps_unref(appVideoCaps);

    // Start playing
    gst_element_set_state(pipeline, GST_STATE_PLAYING);

    // Wait until error or EOS
    GstBus *bus = gst_element_get_bus(pipeline);
    GstMessage *msg = gst_bus_timed_pop_filtered(bus, GST_CLOCK_TIME_NONE, GstMessageType::GST_MESSAGE_EOS);

    // Free resources
    if (msg != nullptr)
        gst_message_unref(msg);
    gst_object_unref(bus);
    gst_element_set_state(pipeline, GST_STATE_NULL);
    gst_object_unref(pipeline);
    return;
}


int qt_thead() {
    char *argv[] = {nullptr};
    char **p_argv = (char **) argv;
    int tmp_count = 1;

    QApplication a(tmp_count, argv);
    QtWidgetsApplication1 w;
    w.show();
    return a.exec();
}


int main(int argc, char *argv[]) {
    std::thread work1(work_thread, 0);
    std::thread work2(work_thread, 1);
    std::thread qt_work(qt_thead);
    std::thread frame_work1(wc::onFrame_ch1);
    std::thread frame_work2(wc::onFrame_ch2);
    qt_work.join();
    frame_work1.join();
    frame_work2.join();
    work1.join();
    work2.join();
    return 0;
}