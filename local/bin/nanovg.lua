
local ffi = require 'ffi'

local nvg = {}

nvg.PI = 3.14159265358979323846264338327

-- enum NVGwinding
nvg.NVG_CCW = 1
nvg.NVG_CW = 2

-- enum NVGsolidity
nvg.NVG_SOLID = 1
nvg.NVG_HOLE = 2

-- enum NVGlineCap
nvg.NVG_BUTT = 0
nvg.NVG_ROUND = 1
nvg.NVG_SQUARE = 2
nvg.NVG_BEVEL = 3
nvg.NVG_MITER = 4

-- enum NVGalign
nvg.NVG_ALIGN_LEFT 		= 1
nvg.NVG_ALIGN_CENTER 	= 2
nvg.NVG_ALIGN_RIGHT 	= 4
nvg.NVG_ALIGN_TOP 		= 8
nvg.NVG_ALIGN_MIDDLE	= 16
nvg.NVG_ALIGN_BOTTOM	= 32
nvg.NVG_ALIGN_BASELINE	= 64

-- enum NVGblendFactor
nvg.NVG_ZERO = 1
nvg.NVG_ONE = 2
nvg.NVG_SRC_COLOR = 4
nvg.NVG_ONE_MINUS_SRC_COLOR = 8
nvg.NVG_DST_COLOR = 16
nvg.NVG_ONE_MINUS_DST_COLOR = 32
nvg.NVG_SRC_ALPHA = 64
nvg.NVG_ONE_MINUS_SRC_ALPHA = 128
nvg.NVG_DST_ALPHA = 256
nvg.NVG_ONE_MINUS_DST_ALPHA = 512
nvg.NVG_SRC_ALPHA_SATURATE = 1024

-- enum NVGcompositeOperation
nvg.NVG_SOURCE_OVER = 0
nvg.NVG_SOURCE_IN = 1
nvg.NVG_SOURCE_OUT = 2
nvg.NVG_ATOP = 3
nvg.NVG_DESTINATION_OVER = 4
nvg.NVG_DESTINATION_IN = 5
nvg.NVG_DESTINATION_OUT = 6
nvg.NVG_DESTINATION_ATOP = 7
nvg.NVG_LIGHTER = 8
nvg.NVG_COPY = 9
nvg.NVG_XOR = 10

ffi.cdef[[

// NanoVG: Copyright (c) 2013 Mikko Mononen memon@inside.org

typedef struct NVGcontext NVGcontext;

struct NVGcolor {
	union {
		float rgba[4];
		struct {
			float r,g,b,a;
		};
	};
};
typedef struct NVGcolor NVGcolor;

struct NVGpaint {
	float xform[6];
	float extent[2];
	float radius;
	float feather;
	NVGcolor innerColor;
	NVGcolor outerColor;
	int image;
};
typedef struct NVGpaint NVGpaint;

enum NVGwinding {
	NVG_CCW = 1,			// Winding for solid shapes
	NVG_CW = 2,				// Winding for holes
};

enum NVGsolidity {
	NVG_SOLID = 1,			// CCW
	NVG_HOLE = 2,			// CW
};

enum NVGlineCap {
	NVG_BUTT,
	NVG_ROUND,
	NVG_SQUARE,
	NVG_BEVEL,
	NVG_MITER,
};

enum NVGalign {
	// Horizontal align
	NVG_ALIGN_LEFT 		= 1<<0,	// Default, align text horizontally to left.
	NVG_ALIGN_CENTER 	= 1<<1,	// Align text horizontally to center.
	NVG_ALIGN_RIGHT 	= 1<<2,	// Align text horizontally to right.
	// Vertical align
	NVG_ALIGN_TOP 		= 1<<3,	// Align text vertically to top.
	NVG_ALIGN_MIDDLE	= 1<<4,	// Align text vertically to middle.
	NVG_ALIGN_BOTTOM	= 1<<5,	// Align text vertically to bottom.
	NVG_ALIGN_BASELINE	= 1<<6, // Default, align text vertically to baseline.
};

enum NVGblendFactor {
	NVG_ZERO = 1<<0,
	NVG_ONE = 1<<1,
	NVG_SRC_COLOR = 1<<2,
	NVG_ONE_MINUS_SRC_COLOR = 1<<3,
	NVG_DST_COLOR = 1<<4,
	NVG_ONE_MINUS_DST_COLOR = 1<<5,
	NVG_SRC_ALPHA = 1<<6,
	NVG_ONE_MINUS_SRC_ALPHA = 1<<7,
	NVG_DST_ALPHA = 1<<8,
	NVG_ONE_MINUS_DST_ALPHA = 1<<9,
	NVG_SRC_ALPHA_SATURATE = 1<<10,
};

enum NVGcompositeOperation {
	NVG_SOURCE_OVER,
	NVG_SOURCE_IN,
	NVG_SOURCE_OUT,
	NVG_ATOP,
	NVG_DESTINATION_OVER,
	NVG_DESTINATION_IN,
	NVG_DESTINATION_OUT,
	NVG_DESTINATION_ATOP,
	NVG_LIGHTER,
	NVG_COPY,
	NVG_XOR,
};

struct NVGcompositeOperationState {
	int srcRGB;
	int dstRGB;
	int srcAlpha;
	int dstAlpha;
};
typedef struct NVGcompositeOperationState NVGcompositeOperationState;

struct NVGglyphPosition {
	const char* str;	// Position of the glyph in the input string.
	float x;			// The x-coordinate of the logical glyph position.
	float minx, maxx;	// The bounds of the glyph shape.
};
typedef struct NVGglyphPosition NVGglyphPosition;

struct NVGtextRow {
	const char* start;	// Pointer to the input text where the row starts.
	const char* end;	// Pointer to the input text where the row ends (one past the last character).
	const char* next;	// Pointer to the beginning of the next row.
	float width;		// Logical width of the row.
	float minx, maxx;	// Actual bounds of the row. Logical with and bounds can differ because of kerning and some parts over extending.
};
typedef struct NVGtextRow NVGtextRow;

enum NVGimageFlags {
    NVG_IMAGE_GENERATE_MIPMAPS	= 1<<0,     // Generate mipmaps during creation of the image.
	NVG_IMAGE_REPEATX			= 1<<1,		// Repeat image in X direction.
	NVG_IMAGE_REPEATY			= 1<<2,		// Repeat image in Y direction.
	NVG_IMAGE_FLIPY				= 1<<3,		// Flips (inverses) image in Y direction when rendered.
	NVG_IMAGE_PREMULTIPLIED		= 1<<4,		// Image data has premultiplied alpha.
};

void nvgBeginFrame(NVGcontext* ctx, int windowWidth, int windowHeight, float devicePixelRatio);
void nvgCancelFrame(NVGcontext* ctx);
void nvgEndFrame(NVGcontext* ctx);

void nvgGlobalCompositeOperation(NVGcontext* ctx, int op);
void nvgGlobalCompositeBlendFunc(NVGcontext* ctx, int sfactor, int dfactor);
void nvgGlobalCompositeBlendFuncSeparate(NVGcontext* ctx, int srcRGB, int dstRGB, int srcAlpha, int dstAlpha);

NVGcolor nvgRGB(unsigned char r, unsigned char g, unsigned char b);
NVGcolor nvgRGBf(float r, float g, float b);
NVGcolor nvgRGBA(unsigned char r, unsigned char g, unsigned char b, unsigned char a);
NVGcolor nvgRGBAf(float r, float g, float b, float a);
NVGcolor nvgLerpRGBA(NVGcolor c0, NVGcolor c1, float u);
NVGcolor nvgTransRGBA(NVGcolor c0, unsigned char a);
NVGcolor nvgTransRGBAf(NVGcolor c0, float a);
NVGcolor nvgHSL(float h, float s, float l);
NVGcolor nvgHSLA(float h, float s, float l, unsigned char a);

void nvgSave(NVGcontext* ctx);
void nvgRestore(NVGcontext* ctx);
void nvgReset(NVGcontext* ctx);

void nvgStrokeColor(NVGcontext* ctx, NVGcolor color);
void nvgStrokePaint(NVGcontext* ctx, NVGpaint paint);
void nvgFillColor(NVGcontext* ctx, NVGcolor color);
void nvgFillPaint(NVGcontext* ctx, NVGpaint paint);
void nvgMiterLimit(NVGcontext* ctx, float limit);
void nvgStrokeWidth(NVGcontext* ctx, float size);
void nvgLineCap(NVGcontext* ctx, int cap);
void nvgLineJoin(NVGcontext* ctx, int join);
void nvgGlobalAlpha(NVGcontext* ctx, float alpha);

void nvgResetTransform(NVGcontext* ctx);
void nvgTransform(NVGcontext* ctx, float a, float b, float c, float d, float e, float f);
void nvgTranslate(NVGcontext* ctx, float x, float y);
void nvgRotate(NVGcontext* ctx, float angle);
void nvgSkewX(NVGcontext* ctx, float angle);
void nvgSkewY(NVGcontext* ctx, float angle);
void nvgScale(NVGcontext* ctx, float x, float y);
void nvgCurrentTransform(NVGcontext* ctx, float* xform);

void nvgTransformIdentity(float* dst);
void nvgTransformTranslate(float* dst, float tx, float ty);
void nvgTransformScale(float* dst, float sx, float sy);
void nvgTransformRotate(float* dst, float a);
void nvgTransformSkewX(float* dst, float a);
void nvgTransformSkewY(float* dst, float a);
void nvgTransformMultiply(float* dst, const float* src);
void nvgTransformPremultiply(float* dst, const float* src);
int nvgTransformInverse(float* dst, const float* src);
void nvgTransformPoint(float* dstx, float* dsty, const float* xform, float srcx, float srcy);

float nvgDegToRad(float deg);
float nvgRadToDeg(float rad);

int nvgCreateImage(NVGcontext* ctx, const char* filename, int imageFlags);
int nvgCreateImageMem(NVGcontext* ctx, int imageFlags, unsigned char* data, int ndata);
int nvgCreateImageRGBA(NVGcontext* ctx, int w, int h, int imageFlags, const unsigned char* data);
void nvgUpdateImage(NVGcontext* ctx, int image, const unsigned char* data);
void nvgImageSize(NVGcontext* ctx, int image, int* w, int* h);
void nvgDeleteImage(NVGcontext* ctx, int image);

NVGpaint nvgLinearGradient(NVGcontext* ctx, float sx, float sy, float ex, float ey,
						   NVGcolor icol, NVGcolor ocol);
NVGpaint nvgBoxGradient(NVGcontext* ctx, float x, float y, float w, float h,
						float r, float f, NVGcolor icol, NVGcolor ocol);
NVGpaint nvgRadialGradient(NVGcontext* ctx, float cx, float cy, float inr, float outr,
						   NVGcolor icol, NVGcolor ocol);
NVGpaint nvgImagePattern(NVGcontext* ctx, float ox, float oy, float ex, float ey,
						 float angle, int image, float alpha);

void nvgScissor(NVGcontext* ctx, float x, float y, float w, float h);
void nvgIntersectScissor(NVGcontext* ctx, float x, float y, float w, float h);
void nvgResetScissor(NVGcontext* ctx);

void nvgBeginPath(NVGcontext* ctx);
void nvgMoveTo(NVGcontext* ctx, float x, float y);
void nvgLineTo(NVGcontext* ctx, float x, float y);
void nvgBezierTo(NVGcontext* ctx, float c1x, float c1y, float c2x, float c2y, float x, float y);
void nvgQuadTo(NVGcontext* ctx, float cx, float cy, float x, float y);
void nvgArcTo(NVGcontext* ctx, float x1, float y1, float x2, float y2, float radius);
void nvgClosePath(NVGcontext* ctx);
void nvgPathWinding(NVGcontext* ctx, int dir);
void nvgArc(NVGcontext* ctx, float cx, float cy, float r, float a0, float a1, int dir);
void nvgRect(NVGcontext* ctx, float x, float y, float w, float h);
void nvgRoundedRect(NVGcontext* ctx, float x, float y, float w, float h, float r);
void nvgRoundedRectVarying(NVGcontext* ctx, float x, float y, float w, float h, float radTopLeft, float radTopRight, float radBottomRight, float radBottomLeft);
void nvgEllipse(NVGcontext* ctx, float cx, float cy, float rx, float ry);
void nvgCircle(NVGcontext* ctx, float cx, float cy, float r);
void nvgFill(NVGcontext* ctx);
void nvgStroke(NVGcontext* ctx);

int nvgCreateFont(NVGcontext* ctx, const char* name, const char* filename);
int nvgCreateFontMem(NVGcontext* ctx, const char* name, unsigned char* data, int ndata, int freeData);
int nvgFindFont(NVGcontext* ctx, const char* name);
int nvgAddFallbackFontId(NVGcontext* ctx, int baseFont, int fallbackFont);
int nvgAddFallbackFont(NVGcontext* ctx, const char* baseFont, const char* fallbackFont);
void nvgFontSize(NVGcontext* ctx, float size);
void nvgFontBlur(NVGcontext* ctx, float blur);
void nvgTextLetterSpacing(NVGcontext* ctx, float spacing);
void nvgTextLineHeight(NVGcontext* ctx, float lineHeight);
void nvgTextAlign(NVGcontext* ctx, int align);
void nvgFontFaceId(NVGcontext* ctx, int font);
void nvgFontFace(NVGcontext* ctx, const char* font);
float nvgText(NVGcontext* ctx, float x, float y, const char* string, const char* end);
void nvgTextBox(NVGcontext* ctx, float x, float y, float breakRowWidth, const char* string, const char* end);
float nvgTextBounds(NVGcontext* ctx, float x, float y, const char* string, const char* end, float* bounds);
void nvgTextBoxBounds(NVGcontext* ctx, float x, float y, float breakRowWidth, const char* string, const char* end, float* bounds);
int nvgTextGlyphPositions(NVGcontext* ctx, float x, float y, const char* string, const char* end, NVGglyphPosition* positions, int maxPositions);
void nvgTextMetrics(NVGcontext* ctx, float* ascender, float* descender, float* lineh);
int nvgTextBreakLines(NVGcontext* ctx, const char* string, const char* end, float breakRowWidth, NVGtextRow* rows, int maxRows);

]]

return nvg
