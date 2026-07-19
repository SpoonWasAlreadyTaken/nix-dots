local G = require('modules.globals')
------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = G.mainMonitor,
    mode     = "1920x1080@144",
    position = "0x0",
    scale    = "auto",
})

hl.monitor({
    output   = G.secondaryMonitor,
    mode     = "1920x1080@60",
    position = "1920x0",
    scale    = "auto",
})

