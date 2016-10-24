
#include <stdio.h>
#include <math.h>
#include <allegro5/allegro.h>
#include <allegro5/allegro_opengl.h>
#include "vg.h"

static ALLEGRO_DISPLAY *g_display = NULL;
static ALLEGRO_EVENT_QUEUE *g_queue = NULL;
static char *g_resDir = NULL;

struct AppInfo {
    double appStartTime;
    int frameCount;
};

static struct AppInfo g_appInfo;

static void abort_huh(char const *format, ...)
{
    va_list args;
    va_start(args, format);
    vfprintf(stderr, format, args);
    va_end(args);
    exit(1);
}

static void open_log(void)
{
}

static void close_log(bool wait_for_user)
{
    (void)wait_for_user;
}

void log_printf(char const *format, ...)
{
    va_list args;
    va_start(args, format);
#ifdef ALLEGRO_ANDROID
    char x[1024];
    vsnprintf(x, sizeof x, format, args);
    ALLEGRO_TRACE_CHANNEL_LEVEL("log", 1)(x);
#else
    vprintf(format, args);
#endif
    va_end(args);
}

int huh_init()
{
    if (!al_init()) {
        abort_huh("Allegro failed to initialise.\n");
    }
    
    open_log();
    
    char buff[256];
    char *hpath = getenv("HUH_PATH");
    strcpy(buff, hpath ? hpath : ".");
    strcat(buff, "/res");
    g_resDir = strdup(buff);
    log_printf("Resource dir: %s\n", g_resDir);

    al_install_keyboard();

    g_queue = al_create_event_queue();
    al_register_event_source(g_queue, al_get_keyboard_event_source());
    
    g_appInfo.appStartTime = al_get_time();
    g_appInfo.frameCount = 0;

    log_printf("Huh initialised\n");
    return 1;
}

int huh_close()
{
    log_printf("%.1f FPS\n", g_appInfo.frameCount / (al_get_time() - g_appInfo.appStartTime));
    
    if (g_queue)
        al_destroy_event_queue(g_queue);
    
    vg_close();
    
    if (g_display)
        al_destroy_display(g_display);
    
    close_log(true);
    
    if (g_resDir)
        free(g_resDir);
    
    return 0;
}

const char* huh_resDir()
{
    return g_resDir;
}

const char* huh_resPath(const char *relPath)
{
    static char rpath[256];
    strcpy(rpath, huh_resDir());
    strcat(rpath, "/");
    strcat(rpath, relPath);
    //log_printf("Res: %s\n", rpath);
    return rpath;
}

ALLEGRO_EVENT_QUEUE* huh_getEventQueue()
{
    return g_queue;
}

struct NVGcontext* huh_nanovg()
{
    return vg_context();
}

ALLEGRO_DISPLAY* huh_createDisplay(int width, int height)
{
    log_printf("Creating OpenGL display, size %dx%d\n", width, height);
    
    al_set_new_display_flags(ALLEGRO_OPENGL);

    g_display = al_create_display(width, height);
    if (!g_display) {
        abort_huh("Could not create display.\n");
    }
    
    // information about OpenGL
    char *gldesc = NULL;
    int glvar = al_get_opengl_variant();
    gldesc = glvar == ALLEGRO_OPENGL_ES ? "OpenGL ES" : "OpenGL";
    uint32_t glver = al_get_opengl_version();
    log_printf("Using %s %d.%d%d\n", gldesc, (glver>>24)&0xff, (glver>>16)&0xff, (glver>>8)&0xff);
    
    struct VgInfo vgi = {
        .wwid = width, .whei = height, .wpixRatio = (float)width / height
    };
    if (vg_init(vgi) != 0)
        abort_huh("Nanovg context creation failed.\n");        

    assert(g_queue);
    al_register_event_source(g_queue, al_get_display_event_source(g_display));

    return g_display;
}

int huh_frameBegin()
{
    vg_frameBegin();
    return 0;
}

int huh_frameEnd()
{
    vg_frameEnd();
    al_flip_display();
    ++g_appInfo.frameCount;
    return 0;
}

int huh_run(void(*update)())
{
    ALLEGRO_EVENT event;
    int done = 0;
    while (!done) {
        /* Check for ESC key or close button event and quit in either case. */
        if (!al_is_event_queue_empty(g_queue)) {
            while (al_get_next_event(g_queue, &event)) {
                switch (event.type) {
                    case ALLEGRO_EVENT_DISPLAY_CLOSE:
                        done = 1;
                        break;
                        
                    case ALLEGRO_EVENT_KEY_DOWN:
                        if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
                            done = 1;
                        break;
                }
            }
        }
        update();
    }
    return 0;
}

