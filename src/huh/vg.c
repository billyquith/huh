/*
 * Huh vector graphics support.
 *  - NanoVG for vector drawing routines.
 *  - NanoSVG for rasterisation of SVG resources.
 *  - Blendish for GUI widgets.
 */

#include <allegro5/allegro.h>
#include <allegro5/allegro_opengl.h>

#include "nanovg/nanovg.h"
#define NANOVG_GL2_IMPLEMENTATION
#include "nanovg/nanovg_gl.h"

#define NANOSVG_IMPLEMENTATION
#include "nanosvg.h"
#define NANOSVGRAST_IMPLEMENTATION
#include "nanosvgrast.h"

#define BLENDISH_IMPLEMENTATION
#include "blendish/blendish.h"
#define OUI_IMPLEMENTATION
#include "blendish/oui.h"

#include "huh.h"
#include "vg.h"

static void drawUI(NVGcontext *vg, int item, int corners);

static struct VgInfo g_info;
static NVGcontext *g_vg = NULL;
static UIcontext *g_uictx = NULL;   /* oui */


int vg_init(struct VgInfo info)
{
    g_info = info;
    
	g_vg = nvgCreateGL2(NVG_STENCIL_STROKES | NVG_DEBUG);
    if (!g_vg)
    {
        log_printf("Nanovg context failed to create.\n");
        return 1;
    }    
 
    /* Assume Blendish required by default. Get resources. */
    const char *rpath = huh_resPath("DejaVuSans.ttf");
    int fnt = nvgCreateFont(g_vg, "system", rpath);
    bndSetFont(fnt);
    if (fnt < 0)
        log_printf("Failed to load Blendish system font.\n");
    
    rpath = huh_resPath("blender_icons16.png");
    bndSetIconImage(nvgCreateImage(g_vg, rpath, 0));
    
    g_uictx = uiCreateContext(4096, 256*1024);
    uiMakeCurrent(g_uictx);
//    uiSetHandler(ui_handler);

    return 0;
}

int vg_close()
{
    if (g_vg)
        nvgDeleteGL2(g_vg);
    g_vg = NULL;
    
    return 0;
}

NVGcontext* vg_context()
{
    return g_vg;
}

void vg_frameBegin()
{
    nvgBeginFrame(g_vg, g_info.wwid, g_info.whei, g_info.wpixRatio);
    
//    bndBackground(g_vg, 0, 0, g_info.wwid, g_info.whei);
    uiBeginLayout();
}

void vg_frameEnd()
{
    uiEndLayout();
    if (uiGetItemCount() > 0)
        drawUI(g_vg, 0, BND_CORNER_NONE);
    
    nvgEndFrame(g_vg);
    
    uiProcess(al_get_time() * 1000.0);
}

/*--------------------------------------------------------------------------------*
 * Blendish & Oui. */

enum huiType {
    ST_BACKGROUND,
    ST_ITEM,
    ST_LABEL,
    ST_BUTTON,
    ST_RADIO,
    ST_SLIDER,
    ST_COLUMN,
    ST_ROW,
    ST_CHECK,
    ST_PANEL,
    ST_TEXT,
    ST_IGNORE,
    
    ST_DEMOSTUFF,
    ST_RECT,
    
    ST_HBOX,
    ST_VBOX,
};

typedef void(*huiDrawer)(NVGcontext *vg, int item, int corners);

typedef struct {
    enum huiType subtype;
    UIhandler handler;
    huiDrawer drawer;
} UIData;

typedef struct {
    UIData head;
    const char *label;
    NVGcolor color;
} UIRectData;

typedef struct {
    UIData head;
    int iconid;
    const char *label;
} UIButtonData;

typedef struct {
    UIData head;
    const char *label;
    int *option;
} UICheckData;

typedef struct {
    UIData head;
    int iconid;
    const char *label;
    int *value;
} UIRadioData;

typedef struct {
    UIData head;
    const char *label;
    float *progress;
} UISliderData;

typedef struct {
    UIData head;
    char *text;
    int maxsize;
} UITextData;


void huiSetDrawer(int item, huiDrawer d)
{
    UIData *data = (UIData *)uiGetHandle(item);
    if (data)
    {
        data->drawer = d;
    }
}

static void drawUIItems(NVGcontext *vg, int item, int corners)
{
    int kid = uiFirstChild(item);
    while (kid > 0) {
        drawUI(vg, kid, corners);
        kid = uiNextSibling(kid);
    }
}

int huiItem()
{
    int item = uiItem();
    UIData *data = (UIData*) uiAllocHandle(item, sizeof(UIData));
    data->subtype = ST_ITEM;
    data->handler = NULL;
    data->drawer = drawUIItems;
    uiSetBox(item, UI_ROW);
    return item;
}

static void drawUIItemsHbox(NVGcontext *vg, int item, int corners)
{
    int kid = uiFirstChild(item);
    if (kid < 0) return;
    int nextkid = uiNextSibling(kid);
    if (nextkid < 0) {
        drawUI(vg, kid, BND_CORNER_NONE);
    } else {
        drawUI(vg, kid, BND_CORNER_RIGHT);
        kid = nextkid;
        while (uiNextSibling(kid) > 0) {
            drawUI(vg, kid, BND_CORNER_ALL);
            kid = uiNextSibling(kid);
        }
        drawUI(vg, kid, BND_CORNER_LEFT);
    }
}

int huiHBox()
{
    int item = uiItem();
    UIData *data = (UIData*) uiAllocHandle(item, sizeof(UIData));
    data->subtype = ST_HBOX;
    data->handler = NULL;
    data->drawer = drawUIItemsHbox;
    uiSetBox(item, UI_ROW);
    return item;
}

static void drawUIItemsVbox(NVGcontext *vg, int item, int corners)
{
    int kid = uiFirstChild(item);
    if (kid < 0) return;
    int nextkid = uiNextSibling(kid);
    if (nextkid < 0) {
        drawUI(vg, kid, BND_CORNER_NONE);
    } else {
        drawUI(vg, kid, BND_CORNER_DOWN);
        kid = nextkid;
        while (uiNextSibling(kid) > 0) {
            drawUI(vg, kid, BND_CORNER_ALL);
            kid = uiNextSibling(kid);
        }
        drawUI(vg, kid, BND_CORNER_TOP);
    }
}

int huiVbox() {
    int item = uiItem();
    UIData *data = (UIData *) uiAllocHandle(item, sizeof(UIData));
    data->subtype = ST_VBOX;
    data->handler = NULL;
    data->drawer = drawUIItemsVbox;
    uiSetBox(item, UI_COLUMN);
    return item;
}

static void drawPanel(NVGcontext *vg, int item, int corners)
{
    UIrect rect = uiGetRect(item);
    bndBevel(vg, rect.x,rect.y,rect.w,rect.h);
    drawUIItems(vg, item, corners);
}

int huiPanel()
{
    int item = uiItem();
    UIData *data = (UIData*) uiAllocHandle(item, sizeof(UIData));
    data->subtype = ST_PANEL;
    data->handler = NULL;
    data->drawer = drawPanel;
    return item;
}

static void drawLabel(NVGcontext *vg, int item, int corners)
{
    UIrect rect = uiGetRect(item);
    const UIButtonData *data = (UIButtonData*) uiGetHandle(item);
    bndLabel(vg,rect.x,rect.y,rect.w,rect.h,
             data->iconid,data->label);
}

int huiLabel(int iconid, const char *label)
{
    int item = uiItem();
    uiSetSize(item, 0, BND_WIDGET_HEIGHT);
    UIButtonData *data = (UIButtonData*) uiAllocHandle(item, sizeof(UIButtonData));
    data->head.subtype = ST_LABEL;
    data->head.handler = NULL;
    data->head.drawer = drawLabel;
    data->iconid = iconid;
    data->label = label;
    return item;
}

static void drawButton(NVGcontext *vg, int item, int corners)
{
    UIrect rect = uiGetRect(item);
    const UIButtonData *data = (UIButtonData*) uiGetHandle(item);
    bndToolButton(vg,rect.x,rect.y,rect.w,rect.h,
                  corners,(BNDwidgetState)uiGetState(item),
                  data->iconid,data->label);
}

int huiButton(int iconid, const char *label, UIhandler handler)
{
    int item = uiItem();
    uiSetSize(item, 0, BND_WIDGET_HEIGHT);
    uiSetEvents(item, UI_BUTTON0_HOT_UP);
    
    UIButtonData *data = (UIButtonData *)uiAllocHandle(item, sizeof(UIButtonData));
    data->head.subtype = ST_BUTTON;
    data->head.handler = handler;
    data->head.drawer = drawButton;
    data->iconid = iconid;
    data->label = label;
    return item;
}

static void drawUI(NVGcontext *vg, int item, int corners)
{
    if (uiGetState(item) == UI_FROZEN) {
        nvgGlobalAlpha(vg, BND_DISABLED_ALPHA);
    }
 
    const UIData *head = (const UIData*) uiGetHandle(item);
    if (head)
    {
        if (head->drawer)
        {
            head->drawer(vg, item, corners);
        }
    }
    
//    if (head)
//    {
//        switch(head->subtype) {
//            default: {
//                testrect(vg,rect);
//                drawUIItems(vg,item,corners);
//            } break;
//                
//            case ST_CHECK: {
//                const UICheckData *data = (UICheckData*)head;
//                BNDwidgetState state = (BNDwidgetState)uiGetState(item);
//                if (*data->option)
//                    state = BND_ACTIVE;
//                bndOptionButton(vg,rect.x,rect.y,rect.w,rect.h, state,
//                                data->label);
//            } break;
//            case ST_RADIO:{
//                const UIRadioData *data = (UIRadioData*)head;
//                BNDwidgetState state = (BNDwidgetState)uiGetState(item);
//                if (*data->value == item)
//                    state = BND_ACTIVE;
//                bndRadioButton(vg,rect.x,rect.y,rect.w,rect.h,
//                               corners,state,
//                               data->iconid,data->label);
//            } break;
//            case ST_SLIDER:{
//                const UISliderData *data = (UISliderData*)head;
//                BNDwidgetState state = (BNDwidgetState)uiGetState(item);
//                static char value[32];
//                sprintf(value,"%.0f%%",(*data->progress)*100.0f);
//                bndSlider(vg,rect.x,rect.y,rect.w,rect.h,
//                          corners,state,
//                          *data->progress,data->label,value);
//            } break;
//            case ST_TEXT: {
//                const UITextData *data = (UITextData*)head;
//                BNDwidgetState state = (BNDwidgetState)uiGetState(item);
//                int idx = strlen(data->text);
//                bndTextField(vg,rect.x,rect.y,rect.w,rect.h,
//                             corners,state, -1, data->text, idx, idx);
//            } break;
//            case ST_DEMOSTUFF: {
//                draw_demostuff(vg, rect.x, rect.y, rect.w, rect.h);
//            } break;
//            case ST_RECT: {
//                const UIRectData *data = (UIRectData*)head;
//                if (rect.w && rect.h) {
//                    BNDwidgetState state = (BNDwidgetState)uiGetState(item);
//                    nvgSave(vg);
//                    nvgStrokeColor(vg, nvgRGBAf(data->color.r,data->color.g,data->color.b,0.9f));
//                    if (state != BND_DEFAULT) {
//                        nvgFillColor(vg, nvgRGBAf(data->color.r,data->color.g,data->color.b,0.5f));
//                    } else {
//                        nvgFillColor(vg, nvgRGBAf(data->color.r,data->color.g,data->color.b,0.1f));
//                    }
//                    nvgStrokeWidth(vg,2);
//                    nvgBeginPath(vg);
//#if 0
//                    nvgRect(vg,rect.x,rect.y,rect.w,rect.h);
//#else
//                    nvgRoundedRect(vg,rect.x,rect.y,rect.w,rect.h,3);
//#endif
//                    nvgFill(vg);
//                    nvgStroke(vg);
//                    
//                    if (state != BND_DEFAULT) {
//                        nvgFillColor(vg, nvgRGBAf(0.0f,0.0f,0.0f,1.0f));
//                        nvgFontSize(vg, 15.0f);
//                        nvgBeginPath(vg);
//                        nvgTextAlign(vg, NVG_ALIGN_TOP|NVG_ALIGN_CENTER);
//                        nvgTextBox(vg, rect.x, rect.y+rect.h*0.3f, rect.w, data->label, NULL);
//                    }
//                    
//                    nvgRestore(vg);
//                }
//                nvgSave(vg);
//                nvgIntersectScissor(vg, rect.x, rect.y, rect.w, rect.h);
//                
//                drawUIItems(vg,item,corners);
//                
//                nvgRestore(vg);
//            } break;
//        }
//    } else {
//        testrect(vg,rect);
//        drawUIItems(vg,item,corners);
//    }
//    
//    if (uiGetState(item) == UI_FROZEN) {
//        nvgGlobalAlpha(vg, 1.0);
//    }
}


static void rootUihandler(int parent, UIevent event)
{
    switch(event)
    {
        case UI_SCROLL: {
            UIvec2 pos = uiGetScroll();
            printf("scroll! %d %d\n", pos.x, pos.y);
        } break;
        case UI_BUTTON0_DOWN:
            printf("%d clicks\n", uiGetClicks());
            break;
        default:
            break;
    }
}

int huiFullscreen()
{
    int root = huiPanel();
    
    // full screen root element
    uiSetSize(0, g_info.wwid, g_info.whei);
    ((UIData*)uiGetHandle(root))->handler = rootUihandler;
    uiSetEvents(root, UI_SCROLL|UI_BUTTON0_DOWN);
    uiSetBox(root, UI_COLUMN);
    
    return root;
}


//static int panel() {
//    int item = uiItem();
//    UIData *data = (UIData *)uiAllocHandle(item, sizeof(UIData));
//    data->subtype = 0; //ST_PANEL;
//    data->handler = NULL;
//    return item;
//}
//
//void radiohandler(int item, UIevent event) {
//    UIRadioData *data = (UIRadioData *)uiGetHandle(item);
//    *data->value = item;
//}
//
//int radio(int iconid, const char *label, int *value) {
//    int item = uiItem();
//    uiSetSize(item, label?0:BND_TOOL_WIDTH, BND_WIDGET_HEIGHT);
//    UIRadioData *data = (UIRadioData *)uiAllocHandle(item, sizeof(UIRadioData));
//    data->head.subtype = ST_RADIO;
//    data->head.handler = radiohandler;
//    data->iconid = iconid;
//    data->label = label;
//    data->value = value;
//    uiSetEvents(item, UI_BUTTON0_DOWN);
//    return item;
//}
//
//static int add_menu_option(int parent, const char *name, int *choice) {
//    int opt = radio(-1, name, choice);
//    uiInsert(parent, opt);
//    uiSetLayout(opt, UI_HFILL|UI_TOP);
//    uiSetMargins(opt, 1, 1, 1, 1);
//    return opt;
//}
//
//static void ui_draw()
//{
//    int root = panel();
//    
//    // position root element
//    uiSetSize(0, g_info.wwid, g_info.whei);
//    ((UIData*)uiGetHandle(root))->handler = roothandler;
//    uiSetEvents(root, UI_SCROLL|UI_BUTTON0_DOWN);
//    uiSetBox(root, UI_COLUMN);
//    
//    static int choice = -1;
//    
//    int menu = uiItem();
//    uiSetLayout(menu, UI_HFILL|UI_TOP);
//    uiSetBox(menu, UI_ROW);
//    uiInsert(root, menu);
//    
//    int opt_blendish_demo = add_menu_option(menu, "Blendish Demo", &choice);
//    int opt_oui_demo = add_menu_option(menu, "OUI Demo", &choice);
//    int opt_layouts = add_menu_option(menu, "UI_LAYOUT", &choice);
//    int opt_row = add_menu_option(menu, "UI_ROW", &choice);
//    int opt_column = add_menu_option(menu, "UI_COLUMN", &choice);
//    int opt_wrap = add_menu_option(menu, "UI_WRAP", &choice);
//}
//
//
