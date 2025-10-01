--- List all available GCC versions from mirror
function PLUGIN:Available(ctx)
    local http = require("http")

    -- Fetch directory listing from KodDoS mirror
    local resp, err = http.get({
        url = "https://mirror.koddos.net/gcc/releases/"
    })

    if err ~= nil then
        error("Failed to fetch GCC versions: " .. err)
    end

    if resp.status_code ~= 200 then
        error("Mirror returned status " .. resp.status_code .. ": " .. resp.body)
    end

    -- Parse HTML directory listing for gcc-X.Y.Z/ directories
    local result = {}
    local seen = {}

    -- Match directory entries like: <a href="gcc-13.2.0/">gcc-13.2.0/</a>
    for dir in resp.body:gmatch('<a href="gcc%-([^"]+)/">') do
        -- Extract version (e.g., "13.2.0")
        local version = dir

        -- Only include if it looks like a version number (contains dots)
        -- and we haven't seen it yet
        if version:match("^%d+%.%d+") and not seen[version] then
            seen[version] = true
            table.insert(result, {
                version = version,
                note = nil
            })
        end
    end

    if #result == 0 then
        error("No GCC releases found")
    end

    -- Sort versions in descending order (newest first)
    table.sort(result, function(a, b)
        local function version_key(v)
            local parts = {}
            for part in v:gmatch("%d+") do
                table.insert(parts, tonumber(part))
            end
            return parts
        end

        local a_parts = version_key(a.version)
        local b_parts = version_key(b.version)

        for i = 1, math.max(#a_parts, #b_parts) do
            local a_val = a_parts[i] or 0
            local b_val = b_parts[i] or 0
            if a_val ~= b_val then
                return a_val > b_val
            end
        end
        return false
    end)

    return result
end
