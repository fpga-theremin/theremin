#include "theremin_sensor_simulator.h"
#include "simulator_impl.h"
#include <QPainter>

#define FRAME_OFFSET 16
#define SENSOR_HEIGHT (SCREEN_DY / 3)

#define MARK_SIZE 8

ThereminSensorSimulator::ThereminSensorSimulator(QWidget *parent) : QWidget(parent)
{
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
    int markX = width() * 2 / 3;
    int markY = height() * 1 / 3;
    painter.setPen(marker);
    painter.drawLine(markX - MARK_SIZE, markY, markX + MARK_SIZE, markY);
    painter.drawLine(markX, markY - MARK_SIZE, markX, markY + MARK_SIZE);
}

