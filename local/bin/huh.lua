-- Huh Lua API

local ffi = require("ffi")

local al = require 'al5ffi'

ffi.cdef[[
int huh_init();
int huh_close();

ALLEGRO_DISPLAY* huh_createDisplay(int width, int height);
int huh_frameEnd();  // swap

ALLEGRO_EVENT_QUEUE* huh_getEventQueue();
]]

local huh = {}

huh.init = function()
    ffi.C.huh_init()
end

huh.createDisplay = function(w,h)
    ffi.C.huh_createDisplay(w, h);
end

huh.run = function(h)
    local hdlr = h or {}
    hdlr.onEvent = hdlr.onEvent or function(e) end
    hdlr.onUpdate = hdlr.onUpdate or function() end
    hdlr.onDraw = hdlr.onDraw or function() end

    local event = ffi.new('ALLEGRO_EVENT')
    local queue = ffi.C.huh_getEventQueue()
    local done = false
    while not done do
        if not ffi.C.al_is_event_queue_empty(queue) then
            while ffi.C.al_get_next_event(queue, event) do
                if event.type == al.ALLEGRO_EVENT_DISPLAY_CLOSE then
                    done = true
                elseif event.type == al.ALLEGRO_EVENT_KEY_DOWN then
                    if event.keyboard.keycode == al.ALLEGRO_KEY_ESCAPE then
                        done = true
                    end
                end
                if hdlr.onEvent then
                    hdlr.onEvent(event)
                end
            end            
        end
        hdlr.onUpdate()
        hdlr.onDraw()
    end
end

return huh
