
#include <stdio.h>
#include <math.h>
#include <allegro5/allegro.h>
#include <allegro5/allegro_opengl.h>

static ALLEGRO_DISPLAY *g_display = NULL;
static ALLEGRO_EVENT_QUEUE *g_queue = NULL;

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

static void log_printf(char const *format, ...)
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
    
    al_destroy_event_queue(g_queue);
    al_destroy_display(g_display);
    
    close_log(true);
    
    return 0;
}

ALLEGRO_EVENT_QUEUE* huh_getEventQueue()
{
    return g_queue;
}

ALLEGRO_DISPLAY* huh_createDisplay(int width, int height)
{
    log_printf("Creating OpenGL display, size %dx%d\n", width, height);
    
    al_set_new_display_flags(ALLEGRO_OPENGL);

    g_display = al_create_display(width, height);
    if (!g_display) {
        abort_huh("Could not create display.\n");
    }

    assert(g_queue);
    al_register_event_source(g_queue, al_get_display_event_source(g_display));

    return g_display;
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

int huh_frameEnd()
{
    al_flip_display();
    ++g_appInfo.frameCount;
    return 0;
}

