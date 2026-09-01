for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end

hl.bind(mainMod .. " + CTRL + RIGHT", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + CTRL + LEFT", hl.dsp.focus({ workspace = "e-1" }))
