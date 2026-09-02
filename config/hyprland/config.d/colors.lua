-- Runtime color loading for Hyprland.
--
-- Reads ~/.config/minima/colors.json (regenerated live by matugen) and the
-- minima config ($MINIMA_CONFIG, for theme.darkTheme), then exposes a helper
-- `rgba()` and a table `C` mapping Material color names to resolved 6-digit
-- hex.  Applied on every config load.  WallpaperPicker runs `matugen && hyprctl
-- reload` after generating colors, so a reload re-applies them automatically.

local function read_file(path)
    local f = io.open(path, "rb")
    if not f then
        return nil
    end
    local content = f:read("*a")
    f:close()
    return content
end

-- Minimal recursive-descent JSON parser (string/number/bool/null/array/object).
local function json_parse(s)
    local pos = 1
    local function skip_ws()
        local _, e = s:find("^[ \t\r\n]*", pos)
        pos = e + 1
    end

    local function parse_string()
        if s:sub(pos, pos) ~= '"' then
            return nil
        end
        local i = pos + 1
        local buf = {}
        while i <= #s do
            local c = s:sub(i, i)
            if c == "\\" then
                local esc = s:sub(i + 1, i + 1)
                if esc == "n" then
                    buf[#buf + 1] = "\n"
                elseif esc == "t" then
                    buf[#buf + 1] = "\t"
                elseif esc == "r" then
                    buf[#buf + 1] = "\r"
                elseif esc == "u" then
                    local code = s:sub(i + 2, i + 5)
                    buf[#buf + 1] = utf8.char(tonumber(code, 16) or 63)
                    i = i + 4
                else
                    buf[#buf + 1] = esc
                end
                i = i + 2
            elseif c == '"' then
                pos = i + 1
                return table.concat(buf)
            else
                buf[#buf + 1] = c
                i = i + 1
            end
        end
        return nil
    end

    local function parse_value()
        skip_ws()
        local c = s:sub(pos, pos)
        if c == "{" then
            pos = pos + 1
            local obj = {}
            skip_ws()
            if s:sub(pos, pos) == "}" then
                pos = pos + 1
                return obj
            end
            while true do
                skip_ws()
                local k = parse_string()
                if k == nil then
                    return nil
                end
                skip_ws()
                if s:sub(pos, pos) ~= ":" then
                    return nil
                end
                pos = pos + 1
                local v = parse_value()
                obj[k] = v
                skip_ws()
                local sep = s:sub(pos, pos)
                if sep == "," then
                    pos = pos + 1
                elseif sep == "}" then
                    pos = pos + 1
                    return obj
                else
                    return nil
                end
            end
        elseif c == "[" then
            pos = pos + 1
            local arr = {}
            skip_ws()
            if s:sub(pos, pos) == "]" then
                pos = pos + 1
                return arr
            end
            while true do
                local v = parse_value()
                arr[#arr + 1] = v
                skip_ws()
                local sep = s:sub(pos, pos)
                if sep == "," then
                    pos = pos + 1
                elseif sep == "]" then
                    pos = pos + 1
                    return arr
                else
                    return nil
                end
            end
        elseif c == '"' then
            return parse_string()
        elseif c == "t" and s:sub(pos, pos + 3) == "true" then
            pos = pos + 4
            return true
        elseif c == "f" and s:sub(pos, pos + 4) == "false" then
            pos = pos + 5
            return false
        elseif c == "n" and s:sub(pos, pos + 3) == "null" then
            pos = pos + 4
            return nil
        else
            local _, e = s:find("^[0-9%-%.eE+]+", pos)
            if not e then
                return nil
            end
            local n = tonumber(s:sub(pos, e))
            pos = e + 1
            return n
        end
    end

    local result = parse_value()
    skip_ws()
    if result == nil or pos <= #s then
        return nil
    end
    return result
end

local colorsJson = read_file(os.getenv("HOME") .. "/.config/minima/colors.json")
local colorsData = colorsJson and json_parse(colorsJson) or nil

-- Resolve the theme branch (dark vs light) from $MINIMA_CONFIG.
local darkTheme = true
local cfgJson = read_file(os.getenv("MINIMA_CONFIG"))
if cfgJson then
    local cfgData = json_parse(cfgJson)
    if cfgData and cfgData.theme and type(cfgData.theme.darkTheme) == "boolean" then
        darkTheme = cfgData.theme.darkTheme
    end
end

local branch = darkTheme and "dark" or "light"
local colors = colorsData
    and colorsData.colors
    and colorsData.colors[branch]
    or nil

-- Convert "#rrggbb" (or "rrggbb") to "rgba(rrggbbff)".
local function rgba(hex)
    if type(hex) ~= "string" then
        return nil
    end
    local h = hex:match("^#?(%x%x%x%x%x%x)$")
    if not h then
        return nil
    end
    return "rgba(" .. h .. "ff)"
end

local C = {}
local known = {
    "background", "error", "error_container", "inverse_on_surface",
    "inverse_primary", "inverse_surface", "on_background", "on_error",
    "on_error_container", "on_primary", "on_primary_container",
    "on_primary_fixed", "on_primary_fixed_variant", "on_secondary",
    "on_secondary_container", "on_secondary_fixed", "on_secondary_fixed_variant",
    "on_surface", "on_surface_variant", "on_tertiary", "on_tertiary_container",
    "on_tertiary_fixed", "on_tertiary_fixed_variant", "outline",
    "outline_variant", "primary", "primary_container", "primary_fixed",
    "primary_fixed_dim", "scrim", "secondary", "secondary_container",
    "secondary_fixed", "secondary_fixed_dim", "shadow", "surface",
    "surface_bright", "surface_container", "surface_container_high",
    "surface_container_highest", "surface_container_low",
    "surface_container_lowest", "surface_dim", "surface_tint",
    "surface_variant", "tertiary", "tertiary_container", "tertiary_fixed",
    "tertiary_fixed_dim",
}
for _, name in ipairs(known) do
    local raw = colors and colors[name] or nil
    C[name] = raw and raw:gsub("^#", "") or nil
end

-- Table + helper consumed by decorations/layout modules below.
COLORS = C
_rgba = rgba
