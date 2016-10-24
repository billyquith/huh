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

void ui_handler(int item, UIevent event);


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
    
    g_uictx = uiCreateContext(4096, 64*1024);
    uiMakeCurrent(g_uictx);
    uiSetHandler(ui_handler);

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
}

void vg_frameEnd()
{
    nvgEndFrame(g_vg);
}

/*--------------------------------------------------------------------------------*
 * Blendish & Oui. */

typedef struct {
    int subtype;
    UIhandler handler;
} UIData;

void ui_handler(int item, UIevent event)
{
    UIData *data = (UIData *)uiGetHandle(item);
    if (data && data->handler)
    {
        data->handler(item, event);
    }
}


