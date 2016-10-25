
local bnd = require 'bndffi'
local oui = require 'ouiffi'
local ffi = require 'ffi'
local C = ffi.C

ffi.cdef[[

int huiFullscreen();
int huiHBox();
int huiVBox();

int huiPanel();
int huiLabel(int iconid, const char *label);
int huiButton(int iconid, const char *label, UIhandler handler);

]]

local hui = {}
local fns = {}

hui.layout = {
    LEFT = oui.UI_LEFT,
    TOP = oui.UI_TOP,
    RIGHT = oui.UI_RIGHT,
    DOWN = oui.UI_DOWN,
    HFILL = oui.UI_HFILL,
    VFILL = oui.UI_VFILL,
    HCENTER = oui.UI_HCENTER,
    VCENTER = oui.UI_VCENTER,
    CENTER = oui.UI_CENTER,
    FILL = oui.UI_FILL,
    BREAK = oui.UI_BREAK
}

hui.box = {
    ROW = oui.UI_ROW,
    COLUMN = oui.UI_COLUMN,
    LAYOUT = oui.UI_LAYOUT,
    FLEX = oui.UI_FLEX,
    NOWRAP = oui.UI_NOWRAP,
    WRAP = oui.UI_WRAP,
    START = oui.UI_START,
    MIDDLE = oui.UI_MIDDLE,
    END = oui.UI_END,
    JUSTIFY = oui.UI_JUSTIFY
}

hui.new = function()
    return setmetatable({ cmds = {}, ids = {} }, { __index = fns })
end

fns.addCmd = function(self, c, name)
    table.insert(self.cmds, c)
end        

fns.draw = function(self)
    self.ids = {}
    for i = 1,#self.cmds do
        local c = self.cmds[i]
        c(self)
    end
end

fns.item = function(self, args)
    local nm, lo, bx, pa = args.name, args.layout, args.box, args.parent
    local fn = args.func or function() return C.uiItem() end
    
    local c = function(self)
        local id = fn()
        self.ids[nm or '_'] = id
        if lo then C.uiSetLayout(id, lo) end
        if bx then C.uiSetBox(id, bx) end
        if pa then
            local pid = self.ids[pa]
            C.uiInsert(pid, id)
        end
    end
    
    self:addCmd(c)
end

fns.fullScreen = function(self, args)
    args.func = function() return C.huiFullscreen() end
    return self:item(args)
end

return hui
