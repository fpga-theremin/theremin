#ifndef UGUI_H_INCLUDED
#define UGUI_H_INCLUDED

#include "lcd_screen.h"
#include <malloc.h>
#include <string.h>

struct Point {
    int16_t x;
    int16_t y;
    Point() : x(0), y(0) {}
    Point(int xx, int yy) : x(static_cast<int16_t>(xx)), y(static_cast<int16_t>(yy)) {}
};

struct Rect {
    int16_t x0;
    int16_t y0;
    int16_t x1;
    int16_t y1;
    Rect() : x0(0), y0(0), x1(0), y1(0) {}
    Rect(int16_t left, int16_t top, int16_t right, int16_t bottom) : x0(left), y0(top), x1(right), y1(bottom) {}
    Rect(Point topLeft, Point bottomRight) : x0(topLeft.x), y0(topLeft.y), x1(bottomRight.x), y1(bottomRight.y) {}
    Point topLeft() const { return Point(x0, y0); }
    Point bottomRight() const { return Point(x1, y1); }
    bool empty() const { return (x0 >= x1 || y0 >= y1); }
    Rect & operator = (const Rect & r) {
        x0 = r.x0;
        x1 = r.x1;
        y0 = r.y0;
        y1 = r.y1;
        return *this;
    }
    Rect & operator = (int n) {
        x0 = x1 = y0 = y1 = static_cast<int16_t>(n);
        return *this;
    }
};


// entries PAL_ENTRY_MAX..PALETTE_SIZE-1 are reserved
#define PALETTE_SIZE 32

enum PaletteEntry {
    PAL_BACKGROUND_COLOR_NORMAL,
    PAL_TEXT_COLOR_NORMAL,
    PAL_BORDER_COLOR_NORMAL,
    PAL_ICON_COLOR_NORMAL,
    PAL_BACKGROUND_COLOR_FOCUSED,
    PAL_TEXT_COLOR_FOCUSED,
    PAL_BORDER_COLOR_FOCUSED,
    PAL_ICON_COLOR_FOCUSED,
    PAL_BACKGROUND_COLOR_PRESSED,
    PAL_TEXT_COLOR_PRESSED,
    PAL_BORDER_COLOR_PRESSED,
    PAL_ICON_COLOR_PRESSED,
    PAL_BACKGROUND_COLOR_DISABLED,
    PAL_TEXT_COLOR_DISABLED,
    PAL_BORDER_COLOR_DISABLED,
    PAL_ICON_COLOR_DISABLED,
    // number of entries
    PAL_ENTRY_MAX = PAL_ICON_COLOR_DISABLED
};

enum WidgetState {
    WS_NORMAL,
    WS_FOCUSED,
    WS_PRESSED,
    WS_DISABLED,
    WS_INVISIBLE,
};

struct Style {
    pixel_t palette[PALETTE_SIZE];
    const BitmapFont * font;
    Rect borderWidths;
    Rect margins;
    Rect padding;
    // Create simple style with back
    Style(pixel_t _backColor, pixel_t _textColor, const BitmapFont * _fnt, int marg = 0, int pad = 0, int borderWidth = 0, pixel_t borderColor = CL_TRANSPARENT);
    // Shrinks rectangle by margins widths
    void applyMargins(Rect& rc) const;
    // Shrinks rectangle by padding widths
    void applyPadding(Rect& rc) const;
    // Shrinks rectangle by border widths
    void applyBorders(Rect& rc) const;
    // Calculate client rect from widget rect (applies margins, borders and padding to rc)
    Rect calcClientRect(Rect rc) const;
    // Calculate full size from client size (applies margins, borders and padding)
    Point calcFullSize(Point clientSize) const;

    pixel_t getTextColor(WidgetState state) const;
    // draw background based on state
    void drawBackground(Rect rc, WidgetState state) const;

    // measure text
    Point measureText(const char * s, int len) const;
    // draw text inside specified rectangle
    void drawText(Rect rc, WidgetState state, const char * s, int len) const;
};

// simple string container
class UString {
    char * buf;
    uint16_t len;
    uint16_t size;
public:
    UString() : buf(nullptr), len(0), size(0) {}
    UString(const char * s);
    UString(const UString & s);
    ~UString() {}
    void clear();
    void reserve(int sz);
    UString & operator = (const char * s);
    UString & operator = (const UString & s);
    UString & append(const char * s);
    UString & append(const UString & s);

    bool empty() const {
        return len <= 0;
    }
    int length() const { return len; }
    int capacity() const { return size; }
    char operator[] (int index) const {
        if (index < 0 || index >= len)
            return 0;
        return buf[index];
    }
    const char * c_str() const {
        if (!buf)
            return "";
        return buf;
    }
 };

template <class T>
class UCollection {
    uint16_t size;
    uint16_t count;
    T ** list;
public:
    UCollection() : size(0), count(0), list(nullptr) {}
    ~UCollection() {
        clear();
    }
    void reserve(int requestedSize) {
        uint32_t newSize = static_cast<uint32_t>(requestedSize);
        if (newSize < size)
            return;
        if (size > 0 && (newSize < size*2u))
            newSize = size * 2;
        if (newSize < 4)
            newSize = 4;
        list = static_cast<T**>(realloc(list, sizeof(T*) * newSize));
        for (uint32_t i = size; i < newSize; i++)
            list[i] = nullptr;
        size = static_cast<uint16_t>(newSize);
    }
    void clear() {
        if (list) {
            for (uint16_t i = 0; i < count; i++) {
                if (list[i])
                    delete list[i];
            }
            free(list);
            list = nullptr;
            count = size = 0;
        }
    }
    T * remove(int index) {
        if (index < 0 || index >= count)
            return nullptr;
        T * res = list[index];
        for (int i = index; i + 1 < count; i++)
            list[i] = list[i + 1];
        list[count] = nullptr;
        count--;
        return res;
    }
    T * insert(T * item, int index = -1) {
        reserve(count + 1);
        if (index < 0 || index >= count)
            index = count;
        for (int i = count; i > index; i--)
            list[i] = list[i - 1];
        list[index] = item;
        count++;
        return item;
    }
    T * add(T * item) {
        return insert(item, -1);
    }
    int capacity() const {
        return size;
    }
    int length() const {
        return count;
    }
    T* operator[](int index) const {
        if (index < 0 || index >= static_cast<int>(count))
            return nullptr;
        return list[index];
    }
};

enum WidgetFlags {
    WF_VISIBLE = 1,
    WF_ENABLED = 2,
    WF_PRESSED = 4,
    WF_FOCUSED = 8,
    WF_CHECKED = 16,
    WF_DIRTY = 32,
};


class UWidget {
protected:
    Rect _pos;
    uint16_t _id;
    uint16_t _flags;
    UWidget * _parent;
    const Style * _style;
public:
    UWidget();
    UWidget(uint16_t id);
    UWidget(Rect pos, const Style * style = nullptr, uint16_t id = 0);
    virtual ~UWidget();
    // id property
    uint16_t getId() const { return _id; }
    UWidget& setId(uint16_t id) { _id = id; return *this; }
    // flags property
    uint16_t flags() const { return _flags; }
    bool isVisible() const { return (_flags & WF_VISIBLE) && !_pos.empty(); }
    bool isDirty() const { return _flags & WF_DIRTY; }
    bool isPressed() const { return _flags & WF_PRESSED; }
    bool isFocused() const { return _flags & WF_FOCUSED; }
    bool isChecked() const { return _flags & WF_CHECKED; }
    bool isEnabled() const { return _flags & WF_ENABLED; }
    void invalidate() {
        // set dirty flag
        _flags |= WF_DIRTY;
    }
    // text
    virtual const UString & text();
    virtual UWidget & setText(const char * s) { return *this; }
    // style property
    virtual const Style * getStyle() const;
    virtual UWidget& setStyle(const Style* style) { _style = style; invalidate(); return *this; }
    // state
    virtual WidgetState getState() const;
    //================================================
    // draw widget
    virtual void draw() { drawBackground(); }
    virtual void drawBackground() { getStyle()->drawBackground(_pos, getState()); }
    virtual Point measureContent() { return Point(); }
    virtual Point measure();
    //================================================
    // parent/child methods
    // returns child count, 0 == no children
    virtual int childCount() const { return 0; }
    // returns child by index, or nullptr if index out of range
    virtual UWidget* child(int index) const { return nullptr; }
    // insert child at specified position (to end of list if index is outside of items range)
    virtual UWidget* insertChild(UWidget * w, int index = -1) { return nullptr; }
    // removes child at specified position, returns removed item (doesn't remove item and returns nullptr if index is outside of items range)
    virtual UWidget* removeChild(int index = -1) { return nullptr; }
    // returns parent widget, or nullptr if no parent
    virtual UWidget* parent() const { return _parent; }
    // set parent
    virtual UWidget& setParent(UWidget * parent) { _parent = parent; return *this; }
};

/// widget with children: parent for other widgets
class UCompoundWidget : public UWidget {
protected:
    UCollection<UWidget> _children;
public:
    UCompoundWidget() : UWidget() {}
    UCompoundWidget(uint16_t id) : UWidget(id) {}
    UCompoundWidget(Rect pos, const Style * style = nullptr, uint16_t id = 0) : UWidget(pos, style, id) {}
    ~UCompoundWidget() override {}
    //================================================
    // parent/child methods
    // returns child count, 0 == no children
    int childCount() const override { return _children.length(); }
    // returns child by index, or nullptr if index out of range
    UWidget* child(int index) const override { return _children[index]; }
    // insert child at specified position (to end of list if index is outside of items range)
    UWidget* insertChild(UWidget * w, int index = -1) override;
    // removes child at specified position, returns removed item (doesn't remove item and returns nullptr if index is outside of items range)
    UWidget* removeChild(int index = -1) override;

    //==========================================
    // draw item and its children
    void draw() override;
};

class ULabel : public UWidget {
protected:
    UString _text;
public:
    ULabel(const char * s, Rect rc, const Style * style = nullptr, uint16_t id = 0);
    ULabel(const UString & s, Rect rc, const Style * style = nullptr, uint16_t id = 0);
    ~ULabel() override {}
    // text
    const UString & text() override;
    UWidget & setText(const char * s) override;
    //==========================================
    // draw item and its children
    void draw() override;
    Point measureContent() override;
};

#endif // UGUI_H_INCLUDED
