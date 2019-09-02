#ifndef THEREMIN_SENSOR_SIMULATOR_H
#define THEREMIN_SENSOR_SIMULATOR_H

#include <QWidget>

class ThereminSensorSimulator : public QWidget
{
    Q_OBJECT
    int markX;
    int markY;
protected:
    void paintEvent(QPaintEvent *event) override;
    void mousePressEvent(QMouseEvent *event) override;
    void mouseReleaseEvent(QMouseEvent *event) override;
    void mouseMoveEvent(QMouseEvent *event) override;
    void setMark(int x, int y);
public:
    explicit ThereminSensorSimulator(QWidget *parent = nullptr);

signals:

public slots:
};

#endif // THEREMIN_SENSOR_SIMULATOR_H
