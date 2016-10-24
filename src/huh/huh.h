
int huh_init();

const char* huh_resDir();
const char* huh_resPath(const char *relPath);

int huh_frameBegin();
int huh_frameEnd();

struct NVGcontext* huh_nanovg();

void log_printf(char const *format, ...);


