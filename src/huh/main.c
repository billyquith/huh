
/* Replace application entry, main(), with c */
#define main ljmain
#include HUH_LUAJIT_PATH
#undef main

#include "huh.h"
#include <allegro5/allegro.h>

/* Allegro needs main() in order to set up its application correctly. */
int main(int argc, char **argv)
{
    return ljmain(argc, argv);
}
