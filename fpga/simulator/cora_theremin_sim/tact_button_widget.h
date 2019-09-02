#ifndef TACT_BUTTON_WIDGET_H
#define TACT_BUTTON_WIDGET_H

#include <QWidget>

class TactButtonWidget : public QWidget
{
    Q_OBJECT

    bool pressed;
protected:
    void paintEvent(QPaintEvent *event) override;
    void mousePressEvent(QMouseEvent *event) override;
    void mouseReleaseEvent(QMouseEvent *event) override;
    void mouseMoveEvent(QMouseEvent *event) override;
public:
    explicit TactButtonWidget(QWidget *parent = nullptr);

    void setPressed(bool f) {
        pressed = f;
        update();
    }

    bool getPressed() {
        return pressed;
    }

signals:

public slots:
};

#endif // TACT_BUTTON_WIDGET_H
