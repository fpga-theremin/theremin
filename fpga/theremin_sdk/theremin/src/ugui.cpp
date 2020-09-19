#include "ugui.h"
#include "bitmap_fonts.h"

const Style DEFAULT_WIDGET_STYLE(CL_BLACK, CL_WHITE, MEDIUM_FONT);


UString::UString(const char * s) : buf(nullptr), len(0){
    if (s) {
        size = len = static_cast<uint16_t>(strlen(s));
        if (len > 0) {
            buf = static_cast<char*>(malloc(len + 1));
            memcpy(buf, s, len + 1);
        }
    }
}
UString::UString(const UString & s) : buf(nullptr), len(0){
    if (!s.empty()) {
        size = len = s.len;
        buf = static_cast<char*>(malloc(len + 1));
        memcpy(buf, s.buf, len + 1);
    }
}
UString & UString::operator = (const char * s) {
    clear();
    if (s) {
        size = len = static_cast<uint16_t>(strlen(s));
        if (len > 0) {
            buf = static_cast<char*>(malloc(len + 1));
            memcpy(buf, s, len + 1);
        }
    }
    return *this;
}

UString & UString::operator = (const UString & s) {
    clear();
    if (!s.empty()) {
        size = len = s.len;
        buf = static_cast<char*>(malloc(len + 1));
        memcpy(buf, s.buf, len + 1);
    }
    return *this;
}

void UString::clear() {
    if (buf) {
        free(buf);
        len = 0;
        size = 0;
    }
}

void UString::reserve(int requestedSize) {
    uint32_t newSize = static_cast<uint32_t>(requestedSize);
    if (newSize < size)
        return;
    if (size && (newSize < size*2u))
        newSize = size * 2;
    if (newSize < 4)
        newSize = 4;
    buf = static_cast<char*>(realloc(buf, sizeof(char) * (newSize + 1)));
    for (uint32_t i = size; i <= newSize; i++)
        buf[i] = 0;
    size = static_cast<uint16_t>(newSize);
}

UString & UString::append(const char * s) {
    if (s && *s) {
        uint16_t appendLen = static_cast<uint16_t>(strlen(s));
        reserve(len + appendLen);
        memcpy(buf + len, s, appendLen + 1);
        len += appendLen;
    }
    return *this;
}

UString & UString::append(const UString & s) {
    if (!s.empty()) {
        uint16_t appendLen = s.length();
        reserve(len + appendLen);
        memcpy(buf + len, s.c_str(), appendLen + 1);
        len += appendLen;
    }
    return *this;
}


//==================================
// Style
//==================================
Style::Style(pixel_t _backColor, pixel_t _textColor, const BitmapFont * _fnt, int marg, int pad, int borderWidth, pixel_t borderColor)
    : font(_fnt)
{
    for (int state = 0; state < 4; state++) {
        palette[PAL_BACKGROUND_COLOR_NORMAL + state*4] = _backColor;
        palette[PAL_TEXT_COLOR_NORMAL + state*4] = _textColor;
        palette[PAL_ICON_COLOR_NORMAL + state*4] = _textColor;
        palette[PAL_BORDER_COLOR_NORMAL + state*4] = borderColor;
    }
    for (int i = PAL_ENTRY_MAX; i < PALETTE_SIZE; i++)
        palette[i] = CL_TRANSPARENT;
    margins = marg;
    padding = pad;
    borderWidths = borderWidth;
}

void Style::applyMargins(Rect& rc) const {
    rc.x0 += margins.x0;
    rc.y0 += margins.y0;
    rc.x1 -= margins.x1;
    rc.y1 -= margins.y1;
}

void Style::applyPadding(Rect& rc) const {
    rc.x0 += padding.x0;
    rc.y0 += padding.y0;
    rc.x1 -= padding.x1;
    rc.y1 -= padding.y1;
}

void Style::applyBorders(Rect& rc) const {
    rc.x0 += borderWidths.x0;
    rc.y0 += borderWidths.y0;
    rc.x1 -= borderWidths.x1;
    rc.y1 -= borderWidths.y1;
}

Rect Style::calcClientRect(Rect rc) const {
    applyMargins(rc);
    applyBorders(rc);
    applyPadding(rc);
    return rc;
}

// Calculate full size from client size (applies margins, borders and padding)
Point Style::calcFullSize(Point clientSize) const {
    Point pt = clientSize;
    pt.x += margins.x0 + margins.x1 + padding.x0 + padding.x1 + borderWidths.x0 + borderWidths.x1;
    pt.y += margins.y0 + margins.y1 + padding.y0 + padding.y1 + borderWidths.y0 + borderWidths.y1;
    return pt;
}

pixel_t Style::getTextColor(WidgetState state) const {
    if (state == WS_INVISIBLE)
        return CL_TRANSPARENT;
    return palette[PAL_TEXT_COLOR_NORMAL + state];
}

Point Style::measureText(const char * s, int len) const {
    int w = lcd_measure_text_width(font, s, len);
    int h = font->fontHeight;
    return Point(w, h);
}

// draw text inside specified rectangle
void Style::drawText(Rect rc, WidgetState state, const char * s, int len) const {
    lcd_draw_text(font, rc.x0, rc.y0, getTextColor(state), s, len);
}

// draw background based on state
void Style::drawBackground(Rect rc, WidgetState state) const {
    if (state == WS_INVISIBLE || rc.empty())
        return;
    pixel_t borderColor = palette[PAL_BORDER_COLOR_NORMAL + state];
    pixel_t bgColor = palette[PAL_BACKGROUND_COLOR_NORMAL + state];
    bool transparentBg = (bgColor == CL_TRANSPARENT);
    bool transparentBorder = (borderColor == CL_TRANSPARENT);
    if (transparentBorder && transparentBg)
        return;
    Rect rc2 = rc;
    applyMargins(rc2);
    if (borderWidths.x0 > 0) {
        if (borderColor != CL_TRANSPARENT)
            lcd_fill_rect(rc2.x0, rc2.y0, rc2.x0 + borderWidths.x0, rc2.y1, borderColor);
        rc2.x0 += borderWidths.x0;
    }
    if (borderWidths.x1 > 0) {
        if (borderColor != CL_TRANSPARENT)
            lcd_fill_rect(rc2.x1 - borderWidths.x1, rc2.y0, rc2.x1, rc2.y1, borderColor);
        rc2.x1 -= borderWidths.x1;
    }
    if (borderWidths.y0 > 0) {
        if (borderColor != CL_TRANSPARENT)
            lcd_fill_rect(rc2.x0, rc2.y0, rc2.x1, rc2.y0 + borderWidths.y0, borderColor);
        rc2.y0 += borderWidths.y0;
    }
    if (borderWidths.y1 > 0) {
        if (borderColor != CL_TRANSPARENT)
            lcd_fill_rect(rc2.x0, rc2.y1 - borderWidths.y1, rc2.x1, rc2.y1, borderColor);
        rc2.y1 -= borderWidths.y1;
    }
    if (rc2.empty() || transparentBg)
        return;
    lcd_fill_rect(rc2.x0, rc2.y0, rc2.x1, rc2.y1, bgColor);
}


UWidget::UWidget()
    : _id(0), _flags(WF_VISIBLE|WF_ENABLED), _parent(nullptr), _style(&DEFAULT_WIDGET_STYLE)
{

}

UWidget::UWidget(uint16_t id)
    : _id(id), _flags(WF_VISIBLE|WF_ENABLED), _parent(nullptr), _style(&DEFAULT_WIDGET_STYLE)
{

}

UWidget::UWidget(Rect pos, const Style * style, uint16_t id)
    : _pos(pos), _id(id), _flags(WF_VISIBLE|WF_ENABLED), _parent(nullptr)
    , _style(style ? style : &DEFAULT_WIDGET_STYLE)
{

}

UWidget::~UWidget() {

}

Point UWidget::measure() {
    Point sz = measureContent();
    return getStyle()->calcFullSize(sz);
}

const Style * UWidget::getStyle() const
{
    if (_style)
        return _style;
    return &DEFAULT_WIDGET_STYLE;
}

WidgetState UWidget::getState() const
{
    if (!(_flags & WF_VISIBLE))
        return WS_INVISIBLE;
    if (!(_flags & WF_ENABLED))
        return WS_DISABLED;
    if (_flags & WF_PRESSED)
        return WS_PRESSED;
    if (_flags & WF_FOCUSED)
        return WS_FOCUSED;
    return WS_NORMAL;
}

static UString empty_UString;
const UString & UWidget::text() {
    return empty_UString;
}

// insert child at specified position (to end of list if index is outside of items range)
UWidget* UCompoundWidget::insertChild(UWidget * w, int index) {
    _children.insert(w, index);
    w->setParent(this);
    return w;
}
// removes child at specified position, returns removed item (doesn't remove item and returns nullptr if index is outside of items range)
UWidget* UCompoundWidget::removeChild(int index) {
    UWidget * child = _children.remove(index);
    if (child) {
        child->setParent(nullptr);
    }
    return child;
}

// draw item and its children
void UCompoundWidget::draw() {
    WidgetState s = getState();
    if (s == WS_INVISIBLE)
        return;
    getStyle()->drawBackground(_pos, s);
    for (int i = 0; i < childCount(); i++) {
        child(i)->draw();
    }
}





ULabel::ULabel(const char * s, Rect rc, const Style * style, uint16_t id) : UWidget(rc, style, id), _text(s) {

}
ULabel::ULabel(const UString & s, Rect rc, const Style * style, uint16_t id) : UWidget(rc, style, id), _text(s) {

}


// text
const UString & ULabel::text() {
    return _text;
}

UWidget & ULabel::setText(const char * s) {
    _text = s;
    invalidate();
    return *this;
}

void ULabel::draw() {
    if (!isVisible())
        return;
    UWidget::draw();
    WidgetState state = getState();
    const Style * s = getStyle();
    Rect clientRect = s->calcClientRect(_pos);
    const UString & str = text();
    s->drawText(clientRect, getState(), str.c_str(), str.length());
}

Point ULabel::measureContent()
{
    Point sz = getStyle()->measureText(_text.c_str(), _text.length());
    return sz;
}
