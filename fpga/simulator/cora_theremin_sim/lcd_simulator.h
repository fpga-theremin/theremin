#ifndef LCD_SIMULATOR_H
#define LCD_SIMULATOR_H

#include <QWidget>
#include <QImage>


class LCDSimulator : public QWidget
{
    Q_OBJECT


    QImage screenImage;

protected:
    void paintEvent(QPaintEvent *event) override;
    void updateImage();

public:
    explicit LCDSimulator(QWidget *parent = nullptr);

signals:

public slots:
};

#endif // LCD_SIMULATOR_H
