#include "pedal_widget.h"
#include <QPainter>

PedalWidget::PedalWidget(int idx, QWidget *parent) : QWidget(parent), index(idx), pressed(false), value(0)
{
    setMinimumWidth(110);
    setMaximumWidth(110);
    setMinimumHeight(30);
    setMaximumHeight(30);
}

void PedalWidget::paintEvent(QPaintEvent *event) {
    Q_UNUSED(event)
    QPainter painter(this);
    QBrush boxBrush(pressed ? 0x0000ff : 0x6060e0);
    QBrush markBrush(pressed ? 0x00ff00 : 0x00c000);
    QPen boxPen(boxBrush, 4);
    QPen markPen(markBrush, 4);
    painter.setRenderHint(QPainter::Antialiasing, false);
    int x0 = 5;
    int y0 = 5;
    int x1 = 105;
    int y1 = 25;

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
