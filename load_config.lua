function parse_xml(content)
    local config = { Config = { KeyBinding = "" } }
    for key, value in string.gmatch(content, "<(%w+)%s*key=\"(.-)\"%s*/>") do
        config.Config[key] = value
    end
    return config
end

function load_file(file)
    local f = io.open(file, "r")
    if f == nil then
        GamePrint("dump_potion: Failed to open file: " .. file)
        return nil
    end
    local content = f:read("*all")
    f:close()
    return content
end

function load_config()
    local config_file = "mods/dump_potion/config.xml"
    local content = ModTextFileGetContent("mods/dump_potion/config.xml")
    if content then
        local config = parse_xml(content)
        local key_binding = get_keycode_from_setting()
        GamePrint("dump_potion: Config loaded. Key: " .. key_binding)
        return key_binding
    end
    return nil
end

-- Utility: Get the keycode for the configured keybind character
function get_keycode_from_setting()
    local char = ModSettingGet("dump_potion.keybind") or "K"
    char = tostring(char):upper()
    -- Keycode mapping: fallback to K (14) or SPACE (44)
    if char == "SPACE" or char == " " then return 44 end
    if char == "K" then return 14 end
    -- Try to find keycode from keycodes.lua (if available)
    local keycodes_all = ModTextFileGetContent("data/scripts/debug/keycodes.lua") or ""
    for line in keycodes_all:gmatch("Key_.-\n") do
        local _, key, code = line:match("(Key_)(.+) = (%d+)")
        if key and code and key:upper() == char then
            return tonumber(code)
        end
    end
    return 14 -- Default to K
end
