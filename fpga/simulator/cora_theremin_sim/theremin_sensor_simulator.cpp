#include "theremin_sensor_simulator.h"
#include "simulator_impl.h"
#include <QPainter>
#include <QMouseEvent>

#define FRAME_OFFSET 16
#define SENSOR_HEIGHT (SCREEN_DY / 3)

#define MARK_SIZE 8

ThereminSensorSimulator::ThereminSensorSimulator(QWidget *parent) : QWidget(parent)
{
    markX = SCREEN_DX / 2;
    markY = SENSOR_HEIGHT / 3;
    setMinimumWidth(SCREEN_DX);
    setMaximumWidth(SCREEN_DX);
    setMinimumHeight(SENSOR_HEIGHT);
    setMaximumHeight(SENSOR_HEIGHT);
}


void ThereminSensorSimulator::paintEvent(QPaintEvent *event) {
    Q_UNUSED(event)
    QPainter painter(this);
    QBrush background(0xd0d8e0);
    QPen frame(0xc0c0c0);
    QPen marker(0xf00000);
    painter.setRenderHint(QPainter::Antialiasing, false);
    painter.fillRect(0, 0, width(), height(), background);
    painter.setBrush(QBrush(Qt::NoBrush));
    painter.setPen(frame);
    painter.drawRect(FRAME_OFFSET, FRAME_OFFSET, width() - FRAME_OFFSET * 2, height() - FRAME_OFFSET * 2 );
    painter.setPen(marker);
    painter.drawLine(markX - MARK_SIZE, markY, markX + MARK_SIZE, markY);
    painter.drawLine(markX, markY - MARK_SIZE, markX, markY + MARK_SIZE);
}

void ThereminSensorSimulator::setMark(int x, int y) {
    if (x < 0)
        x = 0;
    if (x >= width())
        x = width() - 1;
    if (y < 0)
        y = 0;
    if (y >= height())
        y = height() - 1;
    markX = x;
    markY = y;
    update();
}

void ThereminSensorSimulator::mousePressEvent(QMouseEvent *event) {
    if (event->button() == Qt::LeftButton) {
        setMark(event->x(), event->y());
    }
}
void ThereminSensorSimulator::mouseReleaseEvent(QMouseEvent *event) {

}
void ThereminSensorSimulator::mouseMoveEvent(QMouseEvent *event) {
    if (event->buttons() & Qt::LeftButton) {
        setMark(event->x(), event->y());
    }
}

