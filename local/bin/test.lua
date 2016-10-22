
local ffi = require 'ffi'
local huh = require 'huh'
local nvg = require 'nanovg'

huh.init()
huh.createDisplay(640,480)
huh.run{
    onEvent = function (e) print(e) end,
    onDraw = function()
        local vg = ffi.C.huh_nanovg()
        
        -- nvgLineCap(vg, caps[i]);
        ffi.C.nvgLineJoin(vg, nvg.NVG_ROUND);
        local s = 30
		ffi.C.nvgStrokeWidth(vg, s)
		ffi.C.nvgStrokeColor(vg, ffi.C.nvgRGBA(200,150,0,255))
		ffi.C.nvgBeginPath(vg)
		ffi.C.nvgMoveTo(vg, 100,100)
		ffi.C.nvgLineTo(vg, 300,150)
		ffi.C.nvgLineTo(vg, 200,200)
		ffi.C.nvgLineTo(vg, 200,400)
		ffi.C.nvgStroke(vg);
    end
}
