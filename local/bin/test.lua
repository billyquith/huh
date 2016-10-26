
local ffi = require 'ffi'
local huh = require 'huh'
local nvg = require 'nanovg'
local hui = require 'hui'

huh.init()
huh.createDisplay(640,480)

function drawUi()
    local g = hui.new()
    local lo, bx = hui.layout, hui.box
    
    g:fullScreen('root')
    
    g:item('menu'):box(bx.ROW):layout(lo.HFILL + lo.TOP):insert('root')
        
    g:button('b1', 'Hello1', 0):insert('menu'):layout(lo.HFILL):size(100,20)
    g:button('b2', 'Hello2', 0):insert('menu'):layout(lo.HFILL):size(100,20)
    g:button('b3', 'Hello3', 0):insert('menu'):layout(lo.HFILL):size(100,20)
end

huh.run{
    onEvent = function (e) print(e) end,
    onDraw = function()
        
        drawUi()
    
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
