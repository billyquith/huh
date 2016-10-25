
local ffi = require 'ffi'

oui = {

-- enum UIitemState
UI_COLD = 0,
UI_HOT = 1,
UI_ACTIVE = 2,
UI_FROZEN = 3,

-- enum UIboxFlags
UI_ROW = 0x002,
UI_COLUMN = 0x003,
UI_LAYOUT = 0x000,
UI_FLEX = 0x002,
UI_NOWRAP = 0x000,
UI_WRAP = 0x004,
UI_START = 0x008,
UI_MIDDLE = 0x000,
UI_END = 0x010,
UI_JUSTIFY = 0x018,

-- enum UIlayoutFlags
UI_LEFT = 0x020,
UI_TOP = 0x040,
UI_RIGHT = 0x080,
UI_DOWN = 0x100,
UI_HFILL = 0x0a0,
UI_VFILL = 0x140,
UI_HCENTER = 0x000,
UI_VCENTER = 0x000,
UI_CENTER = 0x000,
UI_FILL = 0x1e0,
UI_BREAK = 0x200,

-- enum UIevent
UI_BUTTON0_DOWN = 0x0400,
UI_BUTTON0_UP = 0x0800,
UI_BUTTON0_HOT_UP = 0x1000,
UI_BUTTON0_CAPTURE = 0x2000,
UI_BUTTON2_DOWN = 0x4000,
UI_SCROLL = 0x8000,
UI_KEY_DOWN = 0x10000,
UI_KEY_UP = 0x20000,
UI_CHAR = 0x40000,

UI_USERMASK = 0xff000000,
UI_ANY = 0xffffffff,    
}

ffi.cdef[[
typedef unsigned int UIuint;
typedef struct UIcontext UIcontext;
typedef enum UIitemState UIitemState;
typedef enum UIboxFlags UIboxFlags;
typedef enum UIlayoutFlags UIlayoutFlags;
typedef enum UIevent UIevent;
typedef void (*UIhandler)(int item, UIevent event);

typedef struct UIvec2 {
    union {
        int v[2];
        struct { int x, y; };
    };
} UIvec2;
typedef struct UIrect {
    union {
        int v[4];
        struct { int x, y, w, h; };
    };
} UIrect;

UIcontext *uiCreateContext(unsigned int item_capacity, unsigned int buffer_capacity);
void uiMakeCurrent(UIcontext *ctx);
void uiDestroyContext(UIcontext *ctx);
UIcontext *uiGetContext();
void uiSetCursor(int x, int y);
UIvec2 uiGetCursor();
UIvec2 uiGetCursorDelta();
UIvec2 uiGetCursorStart();
UIvec2 uiGetCursorStartDelta();
void uiSetButton(unsigned int button, unsigned int mod, int enabled);
int uiGetButton(unsigned int button);
int uiGetClicks();
void uiSetKey(unsigned int key, unsigned int mod, int enabled);
void uiSetChar(unsigned int value);
void uiSetScroll(int x, int y);
UIvec2 uiGetScroll();
void uiBeginLayout();
void uiEndLayout();
void uiUpdateHotItem();
void uiProcess(int timestamp);
void uiClearState();
int uiItem();
void uiSetFrozen(int item, int enable);
void uiSetHandle(int item, void *handle);
void *uiAllocHandle(int item, unsigned int size);
void uiSetHandler(UIhandler handler);
void uiSetEvents(int item, unsigned int flags);
void uiSetFlags(int item, unsigned int flags);
int uiInsert(int item, int child);
int uiAppend(int item, int sibling);
int uiInsertBack(int item, int child);
int uiInsertFront(int item, int child);
void uiSetSize(int item, int w, int h);
void uiSetLayout(int item, unsigned int flags);
void uiSetBox(int item, unsigned int flags);
void uiSetMargins(int item, short l, short t, short r, short b);
void uiFocus(int item);
int uiFirstChild(int item);
int uiNextSibling(int item);
int uiGetItemCount();
unsigned int uiGetAllocSize();
UIitemState uiGetState(int item);
void *uiGetHandle(int item);
int uiGetHotItem();
int uiGetFocusedItem();
int uiFindItem(int item, int x, int y, unsigned int flags, unsigned int mask);
UIhandler uiGetHandler();
unsigned int uiGetEvents(int item);
unsigned int uiGetFlags(int item);
unsigned int uiGetKey();
unsigned int uiGetModifier();
UIrect uiGetRect(int item);
int uiContains(int item, int x, int y);
int uiGetWidth(int item);
int uiGetHeight(int item);
unsigned int uiGetLayout(int item);
unsigned int uiGetBox(int item);
short uiGetMarginLeft(int item);
short uiGetMarginTop(int item);
short uiGetMarginRight(int item);
short uiGetMarginDown(int item);
int uiRecoverItem(int olditem);
void uiRemapItem(int olditem, int newitem);
int uiGetLastItemCount();
]]

return oui
