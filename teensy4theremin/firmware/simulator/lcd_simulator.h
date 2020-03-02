#ifndef LCD_SIMULATOR_H
#define LCD_SIMULATOR_H

#include <QWidget>
#include <QImage>
#include <QTimer>


class LCDSimulator : public QWidget
{
    Q_OBJECT


    QImage screenImage;

    QTimer periodicTimer;

protected:
    void paintEvent(QPaintEvent *event) override;
    void updateImage();


public:
    explicit LCDSimulator(QWidget *parent = nullptr);

signals:

public slots:
    void onPeriodicTimer();
};

#endif // LCD_SIMULATOR_H
