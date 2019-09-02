#ifndef ENCODER_WIDGET_H
#define ENCODER_WIDGET_H

#include <QWidget>

#define ENCODER_TICKS 24
class EncoderWidget : public QWidget
{
    Q_OBJECT
    int index;
    int angle;
    bool pressed;
protected:
    void paintEvent(QPaintEvent *event) override;
    void mousePressEvent(QMouseEvent *event) override;
    void mouseReleaseEvent(QMouseEvent *event) override;
    void mouseMoveEvent(QMouseEvent *event) override;
    void wheelEvent(QWheelEvent *event) override;
public:
    explicit EncoderWidget(int index, QWidget *parent = nullptr);
    void setAngle(int a) {
        angle = a % ENCODER_TICKS;
        update();
    }
    void setPressed(bool f) {
        pressed = f;
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
