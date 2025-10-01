--- Helper functions for mise-gcc plugin
local M = {}

--- Get number of parallel jobs for compilation
--- @return number Number of jobs to use with make -j
function M.get_parallel_jobs()
    local cmd = require("cmd")

    -- Try nproc (Linux)
    local result = cmd.exec("nproc 2>/dev/null || true")
    if result and result:match("%d+") then
        return tonumber(result:match("%d+"))
    end

    -- Try sysctl (macOS, BSD)
    result = cmd.exec("sysctl -n hw.ncpu 2>/dev/null || true")
    if result and result:match("%d+") then
        return tonumber(result:match("%d+"))
    end

    -- Default fallback
    return 2
end

--- Check if running on macOS
--- @return boolean True if macOS
function M.is_macos()
    return RUNTIME.osType == "Darwin"
end

return M
