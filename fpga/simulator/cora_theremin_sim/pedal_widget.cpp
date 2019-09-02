#include "pedal_widget.h"
#include <QPainter>
#include <QMouseEvent>

#define PEDAL_GAUGE_WIDTH 150
#define PEDAL_GAUGE_HEIGHT 30
#define PEDAL_GAUGE_FRAME 5

PedalWidget::PedalWidget(int idx, QWidget *parent) : QWidget(parent), index(idx), pressed(false), value(0)
{
    setMinimumWidth(PEDAL_GAUGE_WIDTH);
    setMaximumWidth(PEDAL_GAUGE_WIDTH);
    setMinimumHeight(PEDAL_GAUGE_HEIGHT);
    setMaximumHeight(PEDAL_GAUGE_HEIGHT);
}

void PedalWidget::paintEvent(QPaintEvent *event) {
    Q_UNUSED(event)
    QPainter painter(this);
    QBrush boxBrush(pressed ? 0x0000ff : 0x6060e0);
    QBrush markBrush(pressed ? 0x00ff00 : 0x00c000);
    QPen boxPen(boxBrush, 4);
    QPen markPen(markBrush, 4);
    painter.setRenderHint(QPainter::Antialiasing, false);
    int x0 = PEDAL_GAUGE_FRAME;
    int y0 = PEDAL_GAUGE_FRAME;
    int x1 = PEDAL_GAUGE_WIDTH - PEDAL_GAUGE_FRAME;
    int y1 = PEDAL_GAUGE_HEIGHT - PEDAL_GAUGE_FRAME;

    painter.setPen(pressed ? QPen(0x202020) : QPen(0x607060));
    painter.drawRect(x0, y0, x1-x0, y1-y0);
    int pad = 2;
    x0 += pad;
    y0 += pad;
    x1 -= pad;
    y1 -= pad;
    if (value < 0)
        value = 0;
    else if (value > 1.0f)
        value = 1.0f;
    x1 = x0 + static_cast<int>((x1 - x0) * value);
    painter.setBrush(markBrush);
    painter.drawRect(x0, y0, x1-x0, y1-y0);
}

void PedalWidget::mousePressEvent(QMouseEvent *event) {
    if (event->button() == Qt::LeftButton) {
        int x0 = PEDAL_GAUGE_FRAME+2;
        int x1 = width() - PEDAL_GAUGE_FRAME - 2;
        float x = static_cast<float>(event->x() - x0) / (x1 - x0);
        if (x < 0)
            x = 0;
        else if (x > 1.0f)
            x = 1.0f;
        setValue(x);
        setPressed(true);
    }
}

void PedalWidget::mouseReleaseEvent(QMouseEvent *event) {
    if (event->button() == Qt::LeftButton) {
        setPressed(false);
    }
}

void PedalWidget::mouseMoveEvent(QMouseEvent *event) {
    if (event->buttons() & Qt::LeftButton) {
        int x0 = PEDAL_GAUGE_FRAME+2;
        int x1 = width() - PEDAL_GAUGE_FRAME - 2;
        float x = static_cast<float>(event->x() - x0) / (x1 - x0);
        if (x < 0)
            x = 0;
        else if (x > 1.0f)
            x = 1.0f;
        setValue(x);
    }
}

