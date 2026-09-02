hl.config({
	general = {
		gaps_in = 2,
		gaps_out = 4,
		border_size = 1,
	},
})

hl.curve("windowIn", {
	type = "bezier",
	points = { { 0.06, 0.71 }, { 0.25, 1 } },
})
hl.curve("windowResize", {
	type = "bezier",
	points = { { 0.04, 0.67 }, { 0.38, 1 } },
})
hl.curve("workspacesMove", {
	type = "bezier",
	points = { { 0.1, 0.75 }, { 0.15, 1 } },
})

hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "windowIn", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "windowIn", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 2.5, bezier = "windowResize" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "layers", enabled = true, speed = 4, bezier = "windowIn", style = "slide" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "workspacesMove", style = "slide" })
hl.animation({
	leaf = "specialWorkspace",
	enabled = true,
	speed = 3,
	bezier = "workspacesMove",
	style = "slidefadevert -50%",
})
