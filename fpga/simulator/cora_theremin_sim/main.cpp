#include "mainwindow.h"
#include <QApplication>

#include "simulator_impl.h"

static pixel_t SCREEN_BUF[SCREEN_DX*SCREEN_DY];


int main(int argc, char *argv[])
{
    thereminLCD_setFramebufferAddress(SCREEN_BUF);
    for (int y = 0; y < SCREEN_DY; y++) {
        for (int x = 0; x < SCREEN_DX; x++) {
            SCREEN[y*SCREEN_DX + x] = 0xe84;
        }
    }
    QApplication a(argc, argv);
    MainWindow w;
    w.show();

    return a.exec();
}
