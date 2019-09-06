
//#define THEREMIN_SIMULATOR

#ifdef THEREMIN_SIMULATOR
#include "../../ip_repo/theremin_ip/drivers/theremin_ip/src/theremin_ip.h"
#else
#include "theremin_ip.h"
#include <sleep.h>
#endif

#include <string.h>
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

pixel_t * SCREEN = nullptr;

static pixel_t lcd_front_buffer[SCREEN_DX*SCREEN_DY + 64] SCREEN_ALIGN ;
static pixel_t lcd_back_buffer[SCREEN_DX*SCREEN_DY + 64] SCREEN_ALIGN ;

static uint8_t dirty_row_flag[SCREEN_DX];

static void lcd_flush_front_buffer() {
    uint16_t * prow = lcd_front_buffer;
    for (int i = 0; i < SCREEN_DY; i++) {
		thereminIO_flushCache(prow, ROW_BYTES);
		dirty_row_flag[i] = 0;
        prow += SCREEN_DX;
    }
}

void lcd_init() {
	memset(dirty_row_flag, 0, SCREEN_DX);
	memset(lcd_front_buffer, 0, SCREEN_DX*SCREEN_DY*sizeof(pixel_t));
	memset(lcd_back_buffer, 0, SCREEN_DX*SCREEN_DY*sizeof(pixel_t));
	lcd_flush_front_buffer();
    thereminLCD_setFramebufferAddress(lcd_front_buffer);
    SCREEN = lcd_back_buffer;
}

// WARNING: update this constant if hardware VBP/VSW/VFP is changed!!!
//#define VBLANK_ROWS 11
#define VBLANK_ROWS 54
// Duration of single row refresh in microseconds
// WARNING: update if PXCLK or timings are changed!!!
#define ROW_MICROS 27

static int lcd_current_row() {
    uint32_t n = thereminLCD_getCurrentRowIndex();
    if (n > SCREEN_DY + 5) {
    	return static_cast<int>(n - (SCREEN_DY + VBLANK_ROWS));
    }
	return static_cast<int>(n);
}

void lcd_flush() {
    uint16_t * srcrow = lcd_back_buffer;
    uint16_t * dstrow = lcd_front_buffer;
    int minRow = -1;
    int maxRow = -1;
    for (int i = 0; i < SCREEN_DY; i++) {
        if (dirty_row_flag[i]) {
        	if (minRow == -1)
        		minRow = i;
        	maxRow = i;
        }
    }
    if (minRow < 0)
    	return; // nothing to flush
    int currentRow = lcd_current_row();
#ifdef THEREMIN_SIMULATOR
    bool needSyncWait = false;
#else
    bool needSyncWait = (currentRow >= minRow - 3 && currentRow <= maxRow + 2);
#endif
    for (int i = 0; i < SCREEN_DY; i++) {
        if (dirty_row_flag[i]) {
#ifndef THEREMIN_SIMULATOR
        	if (needSyncWait) {
        		for (;;) {
        			currentRow = lcd_current_row();
        			if (currentRow >= i + 2)
        				break;
        			int diff = (i+2) - currentRow + 1;
        			if (diff > 0)
        				usleep(diff * ROW_MICROS);
        		}
        	}
#endif
        	memcpy(dstrow, srcrow, sizeof(pixel_t)*SCREEN_DX);
            thereminIO_flushCache(dstrow, ROW_BYTES);
            dirty_row_flag[i] = 0;
        }
        srcrow += SCREEN_DX;
        dstrow += SCREEN_DX;
    }
}

/** Draw pixel with color at point (x, y) */
void lcd_put_pixel(int x, int y, uint16_t color) {
    CHECK_POINT_ARGS();
    uint16_t * row = SCREEN + SCREEN_DX * y + x;
    *row = color;
    dirty_row_flag[y] = 1;
}

/** Fill rectangle (x >= x0, x < x1) (y >= y0, y < y1)  with color at point (x, y) */
void lcd_fill_rect(int x0, int y0, int x1, int y1, uint16_t color) {
    CHECK_RECT_ARGS();
    uint16_t * row = SCREEN + SCREEN_DX * y0 + x0;
    int dx = x1 - x0;
    int startOddPixels = (x0 & 1);
    int endOddPixels = (x1 & 1);
    uint32_t * row32 = reinterpret_cast<uint32_t *>(row + startOddPixels);
    int dx32 = (dx - startOddPixels) >> 1;
    uint32_t color32 = color | (static_cast<uint32_t>(color) << 16);
    for (int y = y0; y < y1; y++) {
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

void lcd_draw_rect(int x0, int y0, int x1, int y1, int width, uint16_t color, uint16_t innerColor) {
    if (width <= 1)
        return;
    // top
    lcd_fill_rect(x0, y0, x1, y0 + width, color);
    // bottom
    lcd_fill_rect(x0, y1-width, x1, y1, color);
    // left
    lcd_fill_rect(x0, y0+width, x0+width, y1 - width, color);
    // right
    lcd_fill_rect(x1-width, y0+width, x1, y1 - width, color);
    if (innerColor != CL_TRANSPARENT)
        lcd_fill_rect(x0+width, y0+width, x1 - width, y1 - width, innerColor);
}


inline int my_abs(int n) { return n < 0 ? -n : n; }

void lcd_draw_line(int x0, int y0, int x1, int y1, uint16_t color) {
    int dx = x1 - x0;
    int ix = (dx > 0) - (dx < 0);
    int dx2 = my_abs(dx) * 2;
    int dy = y1 - y0;
    int iy = (dy > 0) - (dy < 0);
    int dy2 = my_abs(dy) * 2;
    lcd_put_pixel(x0, y0, color);
    if (dx2 >= dy2) {
        int error = dy2 - (dx2 / 2);
        while (x0 != x1) {
            if (error >= 0 && (error || (ix > 0))) {
                error -= dx2;
                y0 += iy;
            }
            error += dy2;
            x0 += ix;
            lcd_put_pixel(x0, y0, color);
        }
    }
    else {
        int error = dx2 - (dy2 / 2);
        while (y0 != y1) {
            if (error >= 0 && (error || (iy > 0))) {
                error -= dy2;
                x0 += ix;
            }
            error += dx2;
            y0 += iy;
            lcd_put_pixel(x0, y0, color);
        }
    }

}

/**
Get pointer to glyph from bitmap font.
Returns NULL if glyph is not present in font.
*/
const BitmapFontGlyph * lcd_get_bitmap_font_glyph(const BitmapFont * font, char ch) {
    if ((uint8_t)ch < (uint8_t)font->minChar || (uint8_t)ch > (uint8_t)font->maxChar)
        return nullptr;
    uint32_t offset = font->glyphOffsets[(uint8_t)ch - (uint8_t)font->minChar];
    if (!offset)
        return nullptr;
    return (const BitmapFontGlyph *) ( ((const uint8_t*)font) + offset*4 );
}

/**
Bitmap format sequence of bytes:
[0]: widthBytes
[1]: heightPixels
[2..2+widthBytes*heightPixels-1]: bitmap data, row by row, widthBytes bytes in row, pixel direction: [bit7, bit6, .. bit0] [bit7, bit6, .. bit0]
For bits with value 1 pixel will be drawn with color. For 0 bits, pixel is transparent.
*/
void lcd_draw_bitmap(int x0, int y0, const BitmapData * bitmap, uint16_t color) {
    int dx = bitmap->widthBytes;
    int pxdx = dx * 8;
    int dy = bitmap->heightPixels;
    if (!dx || !dy || x0 + pxdx > SCREEN_DX || y0 + dy > SCREEN_DY || x0 < 0 || y0 < 0)
        return;
    pixel_t * line = SCREEN + y0 * SCREEN_DX + x0;
    const uint8_t * ptr = bitmap->data;
    for (int y = 0; y < dy; y++) {
        pixel_t * dst = line;
        for (int x = 0; x < dx; x++) {
            uint8_t mask = *ptr++;
            if (mask) {
                if (mask & 0x80) dst[0] = color;
                if (mask & 0x40) dst[1] = color;
                if (mask & 0x20) dst[2] = color;
                if (mask & 0x10) dst[3] = color;
                if (mask & 0x08) dst[4] = color;
                if (mask & 0x04) dst[5] = color;
                if (mask & 0x02) dst[6] = color;
                if (mask & 0x01) dst[7] = color;
            }
            dst += 8;
        }
        line += SCREEN_DX;
        dirty_row_flag[y0 + y] = 1;
    }

}

static int my_strlen(const char * s) {
    int res = 0;
    while(*s) {
        res++;
        s++;
    }
    return res;
}

/**
    Bitmap font format:
    [0] fontHeight -- font height in pixels
    [1] charWidth  -- character width in pixels (actual character width may have different values for proportional fonts)
    [2] minChar -- minimal 8-bit character code present in font
    [3] maxChar -- maximal 8-bit character code present in font
    [4] baseline  -- offset from top to baseline
    [5] reserved
    [6] reserved
    [7] reserved
    [8..9] -- offset to minChar character data (data[8]+data[9]*256) from beginning of font data
    [10..11] -- offset to minChar+1 character data (data[10]+data[11]*256) from beginning of font data
    ...      -- (maxChar-minChar+1) total records here
    [....] -- offset to maxChar character data
*/
void lcd_draw_text(const BitmapFont * font, int x0, int y0, uint16_t color, const char * str, int charCount) {
    if (charCount == CHAR_COUNT_ZTERMINATED) {
        charCount = my_strlen(str);
    }
    uint8_t fontHeight = font->fontHeight;
    uint8_t charWidth = font->charWidth;
    uint8_t baseline = font->baseline;
    int x = x0;
    for (int i = 0; i < charCount; i++) {
        char ch = str[i];
        const BitmapFontGlyph * glyph = lcd_get_bitmap_font_glyph(font, ch);
        if (glyph) {
            lcd_draw_bitmap(x + glyph->blackBoxXoffset, y0 + glyph->blackBoxYoffset /*+ baseline*/, &(glyph->bitmap), color);
            x += glyph->advance;
        }
        else {
            // character glyph not found - default advance
            x += charWidth;
        }
    }
}

/**
    Calculates text width for string using specified font
*/
int lcd_measure_text_width(const BitmapFont * font, const char * str, int charCount) {
    if (charCount == CHAR_COUNT_ZTERMINATED)
        charCount = my_strlen(str);
    uint8_t charWidth = font->charWidth;
    int x = 0;
    for (int i = 0; i < charCount; i++) {
        char ch = str[i];
        const BitmapFontGlyph * glyph = lcd_get_bitmap_font_glyph(font, ch);
        if (glyph) {
            if (i + 1 < charCount)
                x += glyph->advance;
            else
                x += glyph->width;
        }
        else {
            // character glyph not found - default advance
            x += charWidth;
        }
    }
    return x;
}


