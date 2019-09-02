#ifndef REG_VALUE_WIDGET_H
#define REG_VALUE_WIDGET_H

#include <QLabel>

class RegValueWidget : public QLabel
{
    QString regName;
    int regAddr;
public:
    RegValueWidget(QString regName, int regAddr, QWidget * parent);
    void updateValue();
};

#endif // REG_VALUE_WIDGET_H
