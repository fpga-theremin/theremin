#include "lcd_simulator.h"
#include "simulator_impl.h"
#include "../../theremin_sdk/theremin/src/lcd_screen.h"

#include <QPainter>
#include <QDebug>
#include <QImage>
#include <stdlib.h>

LCDSimulator::LCDSimulator(QWidget *parent) : QWidget(parent)
{
    setMinimumWidth(SCREEN_DX);
    setMaximumWidth(SCREEN_DX);
    setMinimumHeight(SCREEN_DY);
    setMaximumHeight(SCREEN_DY);
    updateImage();
}

static uint16_t buf[SCREEN_DX*SCREEN_DY];

void LCDSimulator::updateImage() {
    if (SCREEN)
        memcpy(buf, SCREEN, SCREEN_DX*SCREEN_DY*2);
    else
        memset(buf, 0, SCREEN_DX*SCREEN_DY*2);
    // todo: convert special values
    screenImage = QImage(reinterpret_cast<const unsigned char *>(buf),
                             static_cast<int>(SCREEN_DX),
                             static_cast<int>(SCREEN_DY),
                             QImage::Format_RGB444);
}


void LCDSimulator::paintEvent(QPaintEvent *event) {
    Q_UNUSED(event)
    QPainter painter(this);
    painter.setRenderHint(QPainter::Antialiasing, false);
    int dx = (width() - screenImage.width()) / 2;
    int dy = (height() - screenImage.height()) / 2;
    painter.drawImage(QRect(dx, dy, screenImage.width(), screenImage.height()), screenImage);
    QBrush brush(0xc0c0c0);
    if (dx > 0) {
        painter.fillRect(0, 0, dx, height(), brush);
        painter.fillRect(width()-dx, 0, dx, height(), brush);
    }
    if (dy > 0) {
        painter.fillRect(0, 0, width(), dy, brush);
        painter.fillRect(0, height()-dy, width(), dy, brush);
    }
}

