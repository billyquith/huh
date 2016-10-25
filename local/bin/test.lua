
local ffi = require 'ffi'
local huh = require 'huh'
local nvg = require 'nanovg'
local hui = require 'hui'

huh.init()
huh.createDisplay(640,480)

function declUi()
    local g = hui.new()

    g:fullScreen{ name='root' }
    g:item{ name='menu', parent='root', layout=hui.layout.HFILL + hui.layout.TOP, box=hui.box.ROW }
    
    return g
end

local ui1 = declUi()

huh.run{
    onEvent = function (e) print(e) end,
    onDraw = function()
        ui1:draw()
    
        local fc = ffi.C        
        local vg = fc.huh_nanovg()
        -- nvgLineCap(vg, caps[i]);
        fc.nvgLineJoin(vg, nvg.NVG_ROUND);
        local s = 30
	   	fc.nvgStrokeWidth(vg, s)
	   	fc.nvgStrokeColor(vg, fc.nvgRGBA(200,150,0,255))
	   	fc.nvgBeginPath(vg)
	   	fc.nvgMoveTo(vg, 100,100)
	   	fc.nvgLineTo(vg, 300,150)
	   	fc.nvgLineTo(vg, 200,200)
	   	fc.nvgLineTo(vg, 200,400)
	   	fc.nvgStroke(vg);
    end
}
