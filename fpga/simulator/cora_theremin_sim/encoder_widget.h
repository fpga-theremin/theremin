#ifndef ENCODER_WIDGET_H
#define ENCODER_WIDGET_H

#include <QWidget>
#include <QTime>
#include "simulator_impl.h"

#define ENCODER_TICKS 24
class EncoderWidget : public QWidget
{
    Q_OBJECT
    int index;
    int angle;
    int normalStartX;
    int pressedStartX;
    int normalStartAngle;
    int pressedStartAngle;
    int lastAngle;
    bool pressed;
protected:
    void paintEvent(QPaintEvent *event) override;
    void mousePressEvent(QMouseEvent *event) override;
    void mouseReleaseEvent(QMouseEvent *event) override;
    void mouseMoveEvent(QMouseEvent *event) override;
    void wheelEvent(QWheelEvent *event) override;
public:
    explicit EncoderWidget(int index, QWidget *parent = nullptr);
    void rotate(int delta) {
        if (delta == 0) {
            return;
        }
        angle = (angle + delta + 2*ENCODER_TICKS) % ENCODER_TICKS;
        encodersSim_setEncoderState(index, pressed, delta);
        update();
    }
    void setPressed(bool f) {
        if (f == pressed)
            return;
        pressed = f;
        encodersSim_setEncoderState(index, pressed, 0);
        update();
    }
    int getAngle() {
        return angle % ENCODER_TICKS;
    }
    bool getPressed() {
        return pressed;
    }
signals:

public slots:
};

#endif // ENCODER_WIDGET_H
