--- Download GCC source code
function PLUGIN:PreInstall(ctx)
    local version = ctx.version

    -- Build source tarball URL from KodDoS mirror
    local source_url = "https://mirror.koddos.net/gcc/releases/gcc-" .. version .. "/gcc-" .. version .. ".tar.xz"

    return {
        version = version,
        url = source_url,
        -- GNU provides checksums, but they're in separate .sig files
        -- Users can verify releases manually via GPG signatures
        note = "Downloading GCC " .. version .. " source code for compilation"
    }
end
