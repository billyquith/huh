

struct VgInfo
{
    int wwid, whei;     /* Window size */
    float wpixRatio;    /* Window pixel ratio */
};

int vg_init(struct VgInfo info);
int vg_close();

void vg_frameBegin();
void vg_frameEnd();

struct NVGcontext* vg_context();
