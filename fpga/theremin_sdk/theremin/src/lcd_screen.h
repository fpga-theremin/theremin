#ifndef LCD_SCREEN_H
#define LCD_SCREEN_H

#include <stdint.h>

#ifndef SCREEN_DX
#define SCREEN_DX 800
#endif

#ifndef SCREEN_DY
#define SCREEN_DY 480
#endif

typedef uint16_t pixel_t;

extern pixel_t * SCREEN;



#ifdef _WIN32
#define ALIGN_4_PREFIX  __declspec( align( 4 ) )
#define ALIGN_4_ATTRIBUTE
#else
#define ALIGN_4_PREFIX
#define ALIGN_4_ATTRIBUTE __attribute__((aligned(4)))
#endif

#ifdef _WIN32
#define ALIGN_1_PREFIX  __declspec( align( 1 ) )
#define ALIGN_1_ATTRIBUTE
#else
#define ALIGN_1_PREFIX
#define ALIGN_1_ATTRIBUTE __attribute__((aligned(1)))
#endif

// 16/12 bit colors
#define CL_BLACK       0x000
#define CL_WHITE       0xfff
#define CL_RED         0xf00
#define CL_GREEN       0x0f0
#define CL_BLUE        0x00f
#define CL_YELLOW      0xff0
#define CL_SILVER      0xeee
#define CL_GREY        0xccc
#define CL_TRANSPARENT 0xffff



#ifdef __cplusplus
extern "C" {
#endif

/** Initialize screen buffer, initially fill with black color */
void lcd_init();
/** Flush cache of changed framebuffer rows */
void lcd_flush();

// replace clip rect with new value
void lcd_set_clip_rect(int x0, int y0, int x1, int y1);
// combine existing clip rect with new value
void lcd_apply_clip_rect(int x0, int y0, int x1, int y1);
// get current clip rect value
void lcd_get_clip_rect(int* x0, int* y0, int* x1, int* y1);

/** Draw pixel with color at point (x, y) */
void lcd_put_pixel(int x, int y, uint16_t color);
/** Fill rectangle (x >= x0, x < x1) (y >= y0, y < y1)  with color at point (x, y) */
void lcd_fill_rect(int x0, int y0, int x1, int y1, uint16_t color);
/** Draw line with specified color */
void lcd_draw_line(int x0, int y0, int x1, int y1, uint16_t color);
void lcd_draw_rect(int x0, int y0, int x1, int y1, int width, uint16_t color, uint16_t innerColor);


/****************************************
  Bitmap support
****************************************/

typedef struct {
    // header
    uint8_t widthBytes;
    uint8_t heightPixels;
    // bitmap data, widthBytes * heightPixels bytes
    uint8_t data[0];
} BitmapData;

/**
Bitmap format sequence of bytes:
[0]: widthBytes
[1]: heightPixels
[2..2+widthBytes*heightPixels-1]: bitmap data, row by row, widthBytes bytes in row, pixel direction: [bit7, bit6, .. bit0] [bit7, bit6, .. bit0]
For bits with value 1 pixel will be drawn with color. For 0 bits, pixel is transparent.
*/
void lcd_draw_bitmap(int x0, int y0, const BitmapData * bitmap, uint16_t color);

/****************************************
  Font support
****************************************/

typedef struct {
    // header
    uint8_t fontHeight;
    uint8_t charWidth;
    uint8_t minChar;
    uint8_t maxChar;
    uint8_t baseline;
    uint8_t fontFlags;
    uint16_t fontWeight;
    // character glyph offset table: from minChar to maxChar -- total maxChar-minChar+1 items; offsets are in 4-byte words
    uint16_t glyphOffsets[0];
} BitmapFont;

typedef struct {
    // header: 4 bytes
    int8_t blackBoxXoffset;
    uint8_t blackBoxYoffset;
    uint8_t width;
    uint8_t advance;
    BitmapData bitmap;
} BitmapFontGlyph;


/**
    Get pointer to glyph from bitmap font.
    Returns NULL if glyph is not present in font.
*/
const BitmapFontGlyph * lcd_get_bitmap_font_glyph(const BitmapFont * font, char ch);

#define CHAR_COUNT_ZTERMINATED -32768

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
void lcd_draw_text(const BitmapFont * font, int x0, int y0, uint16_t color, const char * str, int charCount);

/**
    Calculates text width for string using specified font
*/
int lcd_measure_text_width(const BitmapFont * font, const char * str, int charCount);



#ifdef __cplusplus
}
#endif

#endif //LCD_SCREEN_H
