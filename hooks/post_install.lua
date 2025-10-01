--- Build and install GCC from source
function PLUGIN:PostInstall(ctx)
    local rootPath = ctx.rootPath
    local sdkInfo = ctx.sdkInfo['gcc']
    local path = sdkInfo.path
    local version = sdkInfo.version
    local helper = require("lib.helper")

    print("\n🔨 Building GCC " .. version .. " from source...")
    print("⚠️  WARNING: GCC compilation can take significant time and disk space")

    -- Get parallel jobs count
    local jobs = helper.get_parallel_jobs()
    print("   Using " .. jobs .. " parallel jobs")

    -- Download prerequisites (GMP, MPFR, MPC, ISL)
    print("\n📦 Downloading GCC prerequisites (GMP, MPFR, MPC, ISL)...")
    local download_result = os.execute("cd \"" .. path .. "\" && ./contrib/download_prerequisites 2>&1")
    if download_result ~= 0 then
        error("Failed to download GCC prerequisites")
    end

    -- Create build directory (GCC requires out-of-tree build)
    local build_dir = path .. "/build"
    os.execute("mkdir -p \"" .. build_dir .. "\" 2>&1")

    -- Configure GCC
    print("\n⚙️  Configuring GCC...")
    print("   This may take several minutes...")

    local configure_cmd = "cd \"" .. build_dir .. "\" && " ..
        "\"" .. path .. "/configure\" " ..
        "--prefix=\"" .. path .. "\" " ..
        "--enable-languages=c,c++ " ..
        "--disable-multilib " ..
        "--disable-bootstrap " ..
        "2>&1 | grep -E '(checking|creating|error|warning|fatal)' || true"

    local configure_result = os.execute(configure_cmd)
    if configure_result ~= 0 then
        -- Re-run without filtering to show full output
        os.execute("cd \"" .. build_dir .. "\" && \"" .. path .. "/configure\" " ..
            "--prefix=\"" .. path .. "\" " ..
            "--enable-languages=c,c++ " ..
            "--disable-multilib " ..
            "--disable-bootstrap")
        error("GCC configuration failed")
    end

    -- Build GCC
    print("\n🏗️  Compiling GCC with " .. jobs .. " parallel jobs...")
    print("   This may take a while...")
    print("   Tip: Use 'mise install --raw gcc@version' to see full build output")

    local make_cmd = "make -C \"" .. build_dir .. "\" -j" .. jobs .. " 2>&1 | " ..
        "grep -E '^(make\\[|.*error|.*warning|Building)' || true"

    local make_result = os.execute(make_cmd)
    if make_result ~= 0 then
        print("\n⚠️  Compilation failed. Re-running to show errors:")
        os.execute("make -C \"" .. build_dir .. "\" -j" .. jobs)
        error("GCC compilation failed")
    end

    -- Install GCC
    print("\n📦 Installing GCC...")
    local install_cmd = "make -C \"" .. build_dir .. "\" install 2>&1 | " ..
        "grep -E '(Installing|error)' || true"

    local install_result = os.execute(install_cmd)
    if install_result ~= 0 then
        os.execute("make -C \"" .. build_dir .. "\" install")
        error("GCC installation failed")
    end

    -- Clean up build artifacts to save space
    print("\n🧹 Cleaning up build artifacts...")
    os.execute("rm -rf \"" .. build_dir .. "\" 2>/dev/null")
    os.execute("find \"" .. path .. "\" -maxdepth 1 -type f -name '*.tar.*' -delete 2>/dev/null || true")

    -- Remove source directories but keep installed files
    local dirs_to_remove = {
        "gcc", "libstdc++-v3", "libgcc", "libiberty", "intl", "libcpp",
        "fixincludes", "contrib", "config", "gmp*", "mpfr*", "mpc*", "isl*"
    }
    for _, dir in ipairs(dirs_to_remove) do
        os.execute("rm -rf \"" .. path .. "/\"" .. dir .. " 2>/dev/null || true")
    end

    print("✅ GCC " .. version .. " installed successfully!")
    print("   C compiler: " .. path .. "/bin/gcc")
    print("   C++ compiler: " .. path .. "/bin/g++\n")
end
