
local ffi = require 'ffi'
local huh = require 'huh'
local nvg = require 'nanovg'
local hui = require 'hui'

huh.init()
huh.createDisplay(640,480)

function drawUi()
    local g = hui.new()
    
    g:fullScreen('root')
    
    g:item('menu')
        :layout(hui.layout.HFILL + hui.layout.TOP)
        :box(hui.box.ROW)
        :insert('root')
        
    g:button('b1', 'Hello1', 0):insert('menu'):layout(hui.layout.TOP + hui.layout.HFILL)
    g:button('b2', 'Hello2', 0):insert('menu'):layout(hui.layout.TOP + hui.layout.HFILL)
    g:button('b3', 'Hello3', 0):insert('menu'):layout(hui.layout.TOP + hui.layout.HFILL)
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
