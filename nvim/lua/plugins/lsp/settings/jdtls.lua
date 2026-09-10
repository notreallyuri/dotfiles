local function runtimes()
  local found = {}
  for _, root in ipairs({ "/usr/lib/jvm", "/usr/lib64/jvm", vim.fn.expand("~/.sdkman/candidates/java") }) do
    for name, kind in vim.fs.dir(root) do
      local version = name:match("^java%-(%d+)%-") or name:match("^(%d+)[%.%-]")
      if version and (kind == "directory" or kind == "link") then
        local path = vim.fn.resolve(vim.fs.joinpath(root, name))
        if vim.fn.isdirectory(vim.fs.joinpath(path, "bin")) == 1 then
          found["JavaSE-" .. version] = path
        end
      end
    end
  end

  local list = {}
  for name, path in pairs(found) do
    table.insert(list, { name = name, path = path })
  end
  table.sort(list, function(a, b) return a.name < b.name end)
  return list
end

return {
  java = {
    eclipse = { downloadSources = true },
    maven = { downloadSources = true },
    references = { includeDecompiledSources = true },
    implementationsCodeLens = { enabled = true },
    referencesCodeLens = { enabled = true },
    signatureHelp = { enabled = true, description = { enabled = true } },
    format = { enabled = true },
    configuration = {
      updateBuildConfiguration = "interactive",
      runtimes = runtimes(),
    },
    inlayHints = {
      parameterNames = { enabled = "all" },
    },
    completion = {
      importOrder = { "java", "javax", "com", "org" },
      favoriteStaticMembers = {
        "java.util.Objects.requireNonNull",
        "java.util.Objects.requireNonNullElse",
        "org.junit.jupiter.api.Assertions.*",
        "org.junit.jupiter.api.Assumptions.*",
        "org.mockito.Mockito.*",
        "org.mockito.ArgumentMatchers.*",
        "org.assertj.core.api.Assertions.*",
      },
      filteredTypes = {
        "com.sun.*",
        "io.micrometer.shaded.*",
        "java.awt.*",
        "jdk.*",
        "sun.*",
      },
    },
    sources = {
      organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 },
    },
    codeGeneration = {
      useBlocks = true,
      hashCodeEquals = { useJava7Objects = true },
      toString = {
        template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
      },
    },
  },
}
