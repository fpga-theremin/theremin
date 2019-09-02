#include "mainwindow.h"
#include <QApplication>

#include "simulator_impl.h"
#include "../../theremin_sdk/theremin/src/lcd_screen.h"

static pixel_t SCREEN_BUF[SCREEN_DX*SCREEN_DY];


int main(int argc, char *argv[])
{
    //thereminLCD_setFramebufferAddress(SCREEN_BUF);
    lcd_init();
    for (int y = 0; y < SCREEN_DY; y++) {
        for (int x = 0; x < SCREEN_DX; x++) {
            SCREEN[y*SCREEN_DX + x] = 0xcde;
        }
    }
    lcd_fill_rect(6, 5, 120, 50, 0x0f84);
    lcd_fill_rect(5, 55, 121, 100, 0x058e);
    lcd_flush();

    QApplication a(argc, argv);
    MainWindow w;
    w.show();

    return a.exec();
}
