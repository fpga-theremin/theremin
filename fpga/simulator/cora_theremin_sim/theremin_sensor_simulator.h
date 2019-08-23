#ifndef THEREMIN_SENSOR_SIMULATOR_H
#define THEREMIN_SENSOR_SIMULATOR_H

#include <QWidget>

class ThereminSensorSimulator : public QWidget
{
    Q_OBJECT
protected:
    void paintEvent(QPaintEvent *event) override;
public:
    explicit ThereminSensorSimulator(QWidget *parent = nullptr);

signals:

public slots:
};

#endif // THEREMIN_SENSOR_SIMULATOR_H
