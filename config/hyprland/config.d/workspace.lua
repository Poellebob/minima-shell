-- Workspace Configuration

-- Workspaces
for i = 1, 10 do
  local key = i % 10
  hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  if hy3 ~= nil then
    hl.bind(mod .. " + SHIFT + " .. key, hy3.move_to_workspace(tostring(i)))
  else
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
  end
end

-- Scroll through workspaces
hl.bind(mod .. " + CTRL + Right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + CTRL + Left", hl.dsp.focus({ workspace = "e-1" }))
