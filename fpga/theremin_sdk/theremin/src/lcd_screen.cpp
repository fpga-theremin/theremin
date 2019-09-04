
//#define THEREMIN_SIMULATOR

#ifdef THEREMIN_SIMULATOR
#include "../../ip_repo/theremin_ip/drivers/theremin_ip/src/theremin_ip.h"
#else
#include "theremin_ip.h"
#endif

#include "lcd_screen.h"

#define CHECK_RECT_ARGS() \
    if (x0 >= SCREEN_DX) return; \
    if (y0 >= SCREEN_DY) return; \
    if (x1 < 0) return; \
    if (y1 < 0) return; \
    if (x0 < 0) x0 = 0; \
    if (x1 > SCREEN_DX) x1 = SCREEN_DX; \
    if (x0 >= x1) return; \
    if (y0 < 0) y0 = 0; \
    if (y1 > SCREEN_DY) y1 = SCREEN_DY; \
    if (y0 >= y1) return

#define CHECK_POINT_ARGS() \
    if (x >= SCREEN_DX || x < 0) return; \
    if (y >= SCREEN_DY || y < 0) return;

#ifdef THEREMIN_SIMULATOR
    #define SCREEN_ALIGN
#else
    #define SCREEN_ALIGN __attribute__ ((aligned(32)))
#endif

#define ROW_BYTES (SCREEN_DX*2)

static uint16_t framebuffer[SCREEN_DX*SCREEN_DY + 64] SCREEN_ALIGN ;
static uint8_t dirty_row_flag[SCREEN_DX];

void lcd_init() {
    for (int i = 0; i < SCREEN_DX; i++)
        dirty_row_flag[i] = 0;
    thereminLCD_setFramebufferAddress(framebuffer);
    lcd_fill_rect(0, 0, SCREEN_DX, SCREEN_DY, 0x0000);
    lcd_flush();
}

void lcd_flush() {
    uint16_t * prow = SCREEN;
    for (int i = 0; i < SCREEN_DY; i++) {
        if (dirty_row_flag[i]) {
            thereminIO_flushCache(prow, ROW_BYTES);
            dirty_row_flag[i] = 0;
        }
        prow += SCREEN_DX;
    }
}

/** Draw pixel with color at point (x, y) */
void lcd_put_pixel(int16_t x, int16_t y, uint16_t color) {
    CHECK_POINT_ARGS();
    uint16_t * row = SCREEN + SCREEN_DX * y + x;
    *row = color;
    dirty_row_flag[y] = 1;
}

/** Fill rectangle (x >= x0, x < x1) (y >= y0, y < y1)  with color at point (x, y) */
void lcd_fill_rect(int16_t x0, int16_t y0, int16_t x1, int16_t y1, uint16_t color) {
    CHECK_RECT_ARGS();
    uint16_t * row = SCREEN + SCREEN_DX * y0 + x0;
    int16_t dx = x1 - x0;
    int16_t startOddPixels = (x0 & 1);
    int16_t endOddPixels = (x1 & 1);
    uint32_t * row32 = reinterpret_cast<uint32_t *>(row + startOddPixels);
    int16_t dx32 = (dx - startOddPixels) >> 1;
    uint32_t color32 = color | (static_cast<uint32_t>(color) << 16);
    for (int16_t y = y0; y < y1; y++) {
        if (startOddPixels)
            row[0] = color;
        if (endOddPixels)
            row[dx-1] = color;
        for (int16_t i = 0; i < dx32; i++)
            row32[i] = color32;
        dirty_row_flag[y] = 1;
        row += SCREEN_DX;
        row32 += SCREEN_DX / 2;
    }
}

