--- Configure environment variables for GCC
function PLUGIN:EnvKeys(ctx)
    local mainPath = ctx.path
    local sdkInfo = ctx.sdkInfo['gcc']
    local path = sdkInfo.path

    return {
        {
            key = "PATH",
            value = path .. "/bin"
        }
    }
end
