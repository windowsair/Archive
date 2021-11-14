//
// Created by 30349 on 2021/11/7.
//

#ifndef GSTREAMER_TEST_H
#define GSTREAMER_TEST_H

#include <QMainWindow>


QT_BEGIN_NAMESPACE
namespace Ui { class test; }
QT_END_NAMESPACE

class test : public QMainWindow {
    Q_OBJECT

public:
    explicit test(QWidget *parent = nullptr);

    ~test() override;

private:
    Ui::test *ui;
};


#endif //GSTREAMER_TEST_H
