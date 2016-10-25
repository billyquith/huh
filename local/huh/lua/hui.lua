
local bnd = require 'bndffi'
local oui = require 'ouiffi'
local ffi = require 'ffi'
local C = ffi.C

ffi.cdef[[

typedef void(*huiDrawer)(NVGcontext *vg, int item, int corners);
void huiSetDrawer(int item, huiDrawer d);

int huiFullscreen();
int huiItem();
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
    return setmetatable({ _ids = {}, _last = -1 }, { __index = fns })
end

local itemDefFn = function() return C.uiItem() end

fns.register = function(self, name, id)
    self._ids[name or '_'] = id
    self._last = id
    return self
end

fns.insert = function(self, parent)
    local pid = self._ids[parent]
    local id = self._last
    C.uiInsert(pid, id)
    return self
end

fns.layout = function(self, lo)
    local id = self._last
    C.uiSetLayout(id, lo)
    return self
end

fns.box = function(self, bx)
    local id = self._last
    C.uiSetBox(id, bx)
    return self
end

fns.item = function(self, name)
    local id = C.huiItem()
    return self:register(name, id)
end

fns.fullScreen = function(self, name)
    local id = C.huiFullscreen()
    return self:register(name, id)
end

fns.button = function(self, name, label, icon)
    local id = C.huiButton(icon, label, nil)
    return self:register(name, id)
end

return hui
