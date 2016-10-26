
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

-- Create new UI context
hui.new = function()
    return setmetatable({ _ids = {}, _last = -1 }, { __index = fns })
end

-- Internal registration of item
fns._register = function(self, name, id)
    self._ids[name or '_'] = id
    self._last = id
    return self
end

--------------------------------------------------
-- Set item layout properties
--------------------------------------------------

-- insert self in parent
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

fns.size = function(self, w,h)
    local id = self._last
    C.uiSetSize(id, w,h)
    return self
end

--------------------------------------------------
-- Items
--  * Convenience items that have drawers
--------------------------------------------------

-- Layout item with no drawer
fns.item = function(self, name)
    local id = C.huiItem()
    return self:_register(name, id)
end

-- Fullscreen, useful for root
fns.fullScreen = function(self, name)
    local id = C.huiFullscreen()
    return self:_register(name, id)
end

fns.button = function(self, name, label, icon)
    local id = C.huiButton(icon, label, nil)
    return self:_register(name, id)
end

return hui
