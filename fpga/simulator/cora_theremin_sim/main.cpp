#include "mainwindow.h"
#include <QApplication>

#include "simulator_impl.h"
#include "../../theremin_sdk/theremin/src/lcd_screen.h"
#include "../../theremin_sdk/theremin/src/bitmap_fonts.h"
#include "../../theremin_sdk/synthesizer/src/synthesizer.h"

int main(int argc, char *argv[])
{
    thereminIO_init();

    //thereminLCD_setFramebufferAddress(SCREEN_BUF);
    lcd_init();
    lcd_fill_rect(6, 5, 120, 50, 0x0f84);
    lcd_fill_rect(5, 55, 121, 100, 0x058e);


    for (int x = 50; x < SCREEN_DX; x+=5) {
        lcd_draw_line(5, 5, x, SCREEN_DY-1, 0x305020);
    }

    lcd_draw_text(LARGE_FONT, 100, 50, 0xff0, "Hello world! LARGE", -32768);
    lcd_draw_text(MEDIUM_FONT, 10, 10, 0x0f0, "Hello world! MEDIUM", -32768);
    lcd_draw_text(SMALL_FONT, 10, 200, 0x8f4, "Hello world! SMALL 1234567890", -32768);
    lcd_draw_text(XSMALL_FONT, 10, 250, 0x8f8, "Hello world! XSMALL 1234567890", -32768);
    lcd_draw_text(XLARGE_FONT, 300, 350, 0x0f8, "Hello world! XLARGE", -32768);

    lcd_draw_text(LARGE_FONT, 100, 80, 0xfff, "WWWwww", -32768);

    lcd_draw_rect(400, 50, 500, 100, 5, CL_RED, CL_YELLOW);
    lcd_draw_rect(450, 70, 550, 120, 7, CL_BLUE, CL_TRANSPARENT);

    lcd_flush();

    thereminAudio_setIrqHandler(&synth_audio_irq);
    thereminAudio_enableIrq();

    QApplication a(argc, argv);
    MainWindow w;
    w.show();

    return a.exec();
}
