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
    setMark(SCREEN_DX / 2, SENSOR_HEIGHT / 3);

    for (int i = 0; i <= 10; i++) {
        float k = i / 10.0f;
        uint32_t n = pitchConv.linearToPeriod(k);
        float lin = pitchConv.periodToLinear(n);
        qDebug("PITCH: dist %f to sensor = %08x    lin=%f", k, n, lin);
    }
    for (int i = 0; i <= 10; i++) {
        float k = i / 10.0f;
        uint32_t n = volumeConv.linearToPeriod(k);
        float lin = volumeConv.periodToLinear(n);
        qDebug("VOLUME: dist %f to sensor = %08x    lin=%f", k, n, lin);
    }

    for (int i = 0; i < 255; i++) {
        int32_t note = i * 256;
        int oct = i / 12;
        int octn = i % 12;
        float freq = noteToFrequency(note);
        int32_t n = frequencyToNote(freq);
        uint32_t inc = noteToPhaseIncrement(note);
        qDebug("Note\t%d\t  oct\t%d\tn\t%d\tfreq=\t%f\tphase+:\t%08x\t->note:\t%d", i, oct, octn, freq, inc, n / 256);
    }

    for (int i = 12*9*256; i < 12*10*256; i++) {
        double n1 = noteToFrequencyD(i);
        double n2 = noteToFrequencyFast(i);
        double diff = n2 - n1;
        uint32_t p1 = noteToPhaseIncrementD(i);
        uint32_t p2 = noteToPhaseIncrementFast(i);
        int32_t pdiff = p2 - p1;
        qDebug("%i: exact: %f \t table: %f \t diff: %f \t rel diff: %f    \t  phase exact:\t%08x  \tinterpolated: %08x \t diff: %x", i, n1, n2, diff, diff/n1
               , p1, p2, pdiff);
    }

    //generateNoteTables();
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
    float xx = (markX - FRAME_OFFSET) / static_cast<float>(SCREEN_DX - FRAME_OFFSET*2);
    float yy = (markY - FRAME_OFFSET) / static_cast<float>(SENSOR_HEIGHT - FRAME_OFFSET*2);
    pitchSensorValue = pitchConv.linearToPeriod(xx);
    volumeSensorValue = volumeConv.linearToPeriod(yy);
    //sensorSim_setPitchSensor(pitchSensorValue);
    sensorSim_setPitchSensorTarget(pitchSensorValue);
    //sensorSim_setVolumeSensor(volumeSensorValue);
    sensorSim_setVolumeSensorTarget(volumeSensorValue);
    float linPitch = pitchConv.periodToLinear(pitchSensorValue);
    float linVolume = volumeConv.periodToLinear(volumeSensorValue);
    qDebug("Pitch: %7.6f %08x  Volume: %7.6f %08x", linPitch, pitchSensorValue, linVolume, volumeSensorValue);
    update();
}

void ThereminSensorSimulator::mousePressEvent(QMouseEvent *event) {
    if (event->button() == Qt::LeftButton) {
        setMark(event->x(), event->y());
    }
}
void ThereminSensorSimulator::mouseReleaseEvent(QMouseEvent *event) {
    Q_UNUSED(event);
}
void ThereminSensorSimulator::mouseMoveEvent(QMouseEvent *event) {
    if (event->buttons() & Qt::LeftButton) {
        setMark(event->x(), event->y());
    }
}

