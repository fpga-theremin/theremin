#ifndef ENCODER_WIDGET_H
#define ENCODER_WIDGET_H

#include <QWidget>
#include <QTime>

#define ENCODER_TICKS 24
class EncoderWidget : public QWidget
{
    Q_OBJECT
    int index;
    int angle;
    int angleNormal;
    int anglePressed;
    int startX;
    bool pressed;
    QTime stateTimer;
protected:
    void paintEvent(QPaintEvent *event) override;
    void mousePressEvent(QMouseEvent *event) override;
    void mouseReleaseEvent(QMouseEvent *event) override;
    void mouseMoveEvent(QMouseEvent *event) override;
    void wheelEvent(QWheelEvent *event) override;
public:
    explicit EncoderWidget(int index, QWidget *parent = nullptr);
    void setAngle(int a) {
        a = (a + 2*ENCODER_TICKS) % ENCODER_TICKS;
        if (a == angle)
            return;
        angle = a;
        stateTimer.start();
        update();
    }
    void setPressed(bool f) {
        if (f == pressed)
            return;
        pressed = f;
        stateTimer.start();
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
