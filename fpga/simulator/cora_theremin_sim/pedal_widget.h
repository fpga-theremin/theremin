#ifndef PEDAL_WIDGET_H
#define PEDAL_WIDGET_H

#include <QWidget>
#include "simulator_impl.h"

class PedalWidget : public QWidget
{
    Q_OBJECT

    int index;
    bool pressed;
    float value;
protected:
    void paintEvent(QPaintEvent *event) override;
    void mousePressEvent(QMouseEvent *event) override;
    void mouseReleaseEvent(QMouseEvent *event) override;
    void mouseMoveEvent(QMouseEvent *event) override;
public:
    explicit PedalWidget(int index, QWidget *parent = nullptr);

    void setPressed(bool f) {
        pressed = f;
        update();
    }
    bool getPressed() {
        return pressed;
    }
    float getValue() { return value; }
    void setValue(float v) {
        if (v < 0)
            v = 0;
        else if (v > 1.0f)
            v = 1.0f;
        value = v;
        pedalSim_setPedalValue(index, value);
        update();
    }
signals:

public slots:
};

#endif // PEDAL_WIDGET_H
