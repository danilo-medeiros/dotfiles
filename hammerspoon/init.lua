local leader = hs.hotkey.modal.new("ctrl", "space")

hs.grid.setGrid("2x2")
hs.grid.setMargins("0x0")
hs.window.animationDuration = 0

-- app bindings
local bindings = {
  {key = "g", app = "Google Chrome"},
  {key = "s", app = "Slack"},
  {key = "t", app = "Alacritty"},
  {key = "c", app = "Calendar"},
  {key = "p", app = "Postman"},
  {key = "f", app = "Finder"},
  {key = "z", app = "zoom.us"},
  {key = "n", app = "Notes"},
  {key = "i", app = "IntelliJ IDEA CE"},
  {key = "v", app = "Visual Studio Code"},
  {key = "m", app = "Mail"},
  {key = "w", app = "WhatsApp"}
}

-- bind each app to its key
for _, binding in ipairs(bindings) do
  leader:bind("", binding.key, function()
    hs.application.launchOrFocus(binding.app)
    leader:exit()
  end)
end

-- reload config
leader:bind("", "r", function()
  hs.reload()
  leader:exit()
end)

leader:bind("", "h", function()
  hs.grid.show()
  leader:exit()
end)

local cells = {
  left = {x=0, y=0, w=1, h=2},
  right = {x=1, y=0, w=1, h=2},
  top = {x=0, y=0, w=2, h=1},
  down = {x=0, y=1, w=2, h=1},
  topleft = {x=0, y=0, w=1, h=1},
  topright = {x=1, y=0, w=1, h=1},
  bottomleft = {x=0, y=1, w=1, h=1},
  bottomright = {x=1, y=1, w=1, h=1},
  full = {x=0, y=0, w=2, h=2}
}

local grid_bindings = {
  {key = "Left", cell = cells.left},
  {key = "Right", cell = cells.right},
  {key = "Up", cell = cells.top},
  {key = "Down", cell = cells.down},
  {key = "y", cell = cells.topleft},
  {key = "u", cell = cells.topright},
  {key = "i", cell = cells.bottomleft},
  {key = "o", cell = cells.bottomright},
  {key = "Return", cell = cells.full}
}

-- bind each grid action to its key
for _, binding in ipairs(grid_bindings) do
  leader:bind("", binding.key, function()
    local win = hs.window.focusedWindow()
    if win then
      hs.grid.set(win, binding.cell, win:screen())
    end
    leader:exit()
  end)
end

leader:bind("", "Escape", function()
  leader:exit()
end)
