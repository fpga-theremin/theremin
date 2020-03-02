#include "lcd_simulator.h"
#include "simulator_impl.h"
//#include "../../theremin_sdk/theremin/src/lcd_screen.h"

#define SCREEN_DX 320
#define SCREEN_DY 240
#define SCREEN_SCALE 2


#include <QPainter>
#include <QDebug>
#include <QImage>
#include <stdlib.h>

uint16_t SCREEN[SCREEN_DX*SCREEN_DY];
bool SCREEN_UPDATED = false;

static uint32_t buf[SCREEN_DX*SCREEN_DY];

inline uint16_t make_RGB565(uint32_t r, uint32_t g, uint32_t b) {
    return ((r & 0xf8) << 8) | ((g & 0xfc) << 3) | ((b & 0xf8) >> 3);
}

inline uint32_t RGB565_to_RGB888(uint16_t pixel565) {
    uint32_t r = (pixel565 >> (5 + 6)) & 0x1F;
    uint32_t g = (pixel565 >> (5)) & 0x3F;
    uint32_t b = (pixel565 >> (0)) & 0x1F;
    // extend to 8 bits
    r = (r << 3) | (r >> 2);
    g = (g << 2) | (r >> 4);
    b = (b << 3) | (b >> 2);
    return (r << 16) | (g << 8) | (b);
}

LCDSimulator::LCDSimulator(QWidget *parent) : QWidget(parent)
{
    // clear screen buffers
    //memset(buf, 0, SCREEN_DX * SCREEN_DY * sizeof(uint16_t));
    //memset(SCREEN, 0, SCREEN_DX * SCREEN_DY * sizeof(uint32_t));
    //SCREEN[0] = 0xfff0;
    //SCREEN[1] = 0x0ff0;
    //SCREEN[SCREEN_DX + 1] = make_RGB565(255,0,0);
    //SCREEN[SCREEN_DX*2 + 2] = make_RGB565(0, 255, 0);
    //SCREEN[SCREEN_DX * 3 + 3] = make_RGB565(0, 0, 255);
    setMinimumWidth(SCREEN_DX * SCREEN_SCALE);
    setMaximumWidth(SCREEN_DX * SCREEN_SCALE);
    setMinimumHeight(SCREEN_DY * SCREEN_SCALE);
    setMaximumHeight(SCREEN_DY * SCREEN_SCALE);
    connect(&periodicTimer, SIGNAL(timeout()), this, SLOT(onPeriodicTimer()));
    periodicTimer.setInterval(500);
    periodicTimer.start();
    updateImage();
}

void LCDSimulator::onPeriodicTimer() {
    if (SCREEN_UPDATED) {
        updateImage();
        SCREEN_UPDATED = false;
    }
}


static void convertColors() {
    for (int y = 0; y < SCREEN_DY; y++) {
        uint16_t * srcline = SCREEN + SCREEN_DX * y;
        uint32_t * dstline = buf + SCREEN_DX * y;
        for (int x = 0; x < SCREEN_DX; x++) {
            dstline[x] = RGB565_to_RGB888(srcline[x]);
        }
    }
}

void LCDSimulator::updateImage() {
//    if (SCREEN)
//        memcpy(buf, SCREEN, SCREEN_DX*SCREEN_DY*2);
//    else
//        memset(buf, 0, SCREEN_DX*SCREEN_DY*2);
    convertColors();
    // todo: convert special values
    screenImage = QImage(reinterpret_cast<const unsigned char *>(buf),
                             static_cast<int>(SCREEN_DX),
                             static_cast<int>(SCREEN_DY),
                             QImage::Format_RGB32);
}


void LCDSimulator::paintEvent(QPaintEvent *event) {
    Q_UNUSED(event)
    QPainter painter(this);
    painter.setRenderHint(QPainter::Antialiasing, false);
    int dx = (width() - screenImage.width() * SCREEN_SCALE) / 2;
    int dy = (height() - screenImage.height() * SCREEN_SCALE) / 2;
    painter.drawImage(QRect(dx, dy, screenImage.width() * SCREEN_SCALE, screenImage.height() * SCREEN_SCALE), screenImage);
    QBrush brush(0xc0c0c0);
    if (dx > 0) {
        painter.fillRect(0, 0, dx, height(), brush);
        painter.fillRect(width()-dx, 0, dx, height(), brush);
    }
    if (dy > 0) {
        painter.fillRect(0, 0, width(), dy, brush);
        painter.fillRect(0, height()-dy, width(), dy, brush);
    }
}

