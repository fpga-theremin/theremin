#ifndef LCD_SCREEN_H
#define LCD_SCREEN_H

#include <stdint.h>

#ifndef SCREEN_DX
#define SCREEN_DX 800
#endif

#ifndef SCREEN_DY
#define SCREEN_DY 480
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef struct lcd_rect_tag {
    int16_t x0;
    int16_t y0;
    int16_t x1;
    int16_t y1;
} lcd_rect;


/** Initialize screen buffer, initially fill with black color */
void lcd_init();
/** Flush cache of changed framebuffer rows */
void lcd_flush();

/** Draw pixel with color at point (x, y) */
void lcd_put_pixel(int16_t x, int16_t y, uint16_t color);
/** Fill rectangle (x >= x0, x < x1) (y >= y0, y < y1)  with color at point (x, y) */
void lcd_fill_rect(int16_t x0, int16_t y0, int16_t x1, int16_t y1, uint16_t color);


#ifdef __cplusplus
}
#endif

#endif //LCD_SCREEN_H
