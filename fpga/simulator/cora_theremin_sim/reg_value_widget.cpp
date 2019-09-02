#include "reg_value_widget.h"
#include <QString>
#include "simulator_impl.h"

RegValueWidget::RegValueWidget(QString name, int addr, QWidget * parent) : QLabel(parent), regName(name), regAddr(addr)
{
    setFont(QFont(QString("Courier New")));
    updateValue();
}

void RegValueWidget::updateValue() {
    QString s;
    s.sprintf("[%02x]%s:%08x", regAddr / 4, regName.toStdString().c_str(), thereminIO_readReg(regAddr));
    if (text() != s)
        setText(s);
}
