
local huh = require 'huh'

huh.init()
huh.createDisplay(640,480)
huh.run{
    onEvent = function (e) print(e) end    
}
