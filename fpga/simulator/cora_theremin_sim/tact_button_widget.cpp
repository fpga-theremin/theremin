#include "tact_button_widget.h"

#include <QPainter>

TactButtonWidget::TactButtonWidget(QWidget *parent) : QWidget(parent), pressed(false)
{
    setMinimumWidth(30);
    setMaximumWidth(30);
    setMinimumHeight(60);
    setMaximumHeight(60);
}


void TactButtonWidget::paintEvent(QPaintEvent *event) {
    Q_UNUSED(event)
    QPainter painter(this);
    QBrush circleBrush(pressed ? 0x0000ff : 0x6060e0);
    QBrush markBrush(pressed ? 0x0000ff : 0x8080ff);
    QPen circlePen(circleBrush, 4);
    QPen markPen(markBrush, 4);
    painter.setRenderHint(QPainter::Antialiasing, true);
    int x0 = width() / 2;
    int y0 = height() / 2;
    int rx = width() * 45 / 100;
    int ry = height() * 45 / 100;
    if (rx > ry)
        rx = ry;
    else if (rx < ry)
        ry = rx;
    painter.setPen(circlePen);
    painter.setBrush(QBrush(pressed ? 0xe0c0c0 : 0xe0e0e0));
    painter.drawEllipse(x0-rx, y0-ry, rx*2, ry*2);
}

