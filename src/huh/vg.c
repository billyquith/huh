#include <allegro5/allegro.h>
#include <allegro5/allegro_opengl.h>

#include "nanovg/nanovg.h"
#define NANOVG_GL2_IMPLEMENTATION
#include "nanovg/nanovg_gl.h"

#include "huh.h"

static NVGcontext *g_ctx = NULL;

int vg_init()
{
	g_ctx = nvgCreateGL2(NVG_STENCIL_STROKES | NVG_DEBUG);
    if (!g_ctx)
    {
        log_printf("Nanovg context failed to create.\n");
        return 1;
    }    
    
    return 0;
}

int vg_close()
{
    if (g_ctx)
        nvgDeleteGL2(g_ctx);
    g_ctx = NULL;
    return 0;
}

NVGcontext* vg_context()
{
    return g_ctx;
}

void vg_frameBegin()
{
    nvgBeginFrame(g_ctx, 640, 480, 640.f/480);
}

void vg_frameEnd()
{
    nvgEndFrame(g_ctx);
}
