local ok, jdtls = pcall(require, "jdtls")
if not ok then
  return
end

local mason = vim.fn.stdpath("data") .. "/mason"
local launcher = mason .. "/bin/jdtls"
if vim.fn.executable(launcher) == 0 then
  vim.notify("jdtls is not installed (:MasonInstall jdtls)", vim.log.levels.WARN)
  return
end

local root = vim.fs.root(0, {
  "settings.gradle",
  "settings.gradle.kts",
  "build.gradle",
  "build.gradle.kts",
  "pom.xml",
  "mvnw",
  "gradlew",
  ".git",
})
if not root then
  return
end

local workspace = vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.fnamemodify(root, ":p:h:t")

local bundles = {}
vim.list_extend(
  bundles,
  vim.fn.glob(
    mason .. "/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
    true,
    true
  )
)
vim.list_extend(
  bundles,
  vim.tbl_filter(
    function(jar) return not jar:match("com%.microsoft%.java%.test%.runner%-jar%-with%-dependencies%.jar$") end,
    vim.fn.glob(mason .. "/packages/java-test/extension/server/*.jar", true, true)
  )
)

local cmd = { launcher, "-data", workspace }

local lombok = mason .. "/packages/jdtls/lombok.jar"
if vim.uv.fs_stat(lombok) then
  table.insert(cmd, "--jvm-arg=-javaagent:" .. lombok)
end

jdtls.start_or_attach({
  cmd = cmd,
  root_dir = root,
  settings = require("plugins.lsp.settings.jdtls"),
  init_options = {
    bundles = bundles,
    extendedClientCapabilities = vim.tbl_deep_extend("force", jdtls.extendedClientCapabilities, {
      resolveAdditionalTextEditsSupport = true,
    }),
  },
  on_attach = function(_, buf)
    local map = function(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc }) end

    map("<leader>co", jdtls.organize_imports, "Organize imports (Java)")
    map("<leader>cv", function() jdtls.extract_variable() end, "Extract variable (Java)")
    map("<leader>cC", function() jdtls.extract_constant() end, "Extract constant (Java)")
    map("<leader>cm", function() jdtls.extract_method() end, "Extract method (Java)")

    vim.keymap.set(
      "v",
      "<leader>cv",
      function() jdtls.extract_variable(true) end,
      { buffer = buf, desc = "Extract variable (Java)" }
    )
    vim.keymap.set(
      "v",
      "<leader>cC",
      function() jdtls.extract_constant(true) end,
      { buffer = buf, desc = "Extract constant (Java)" }
    )
    vim.keymap.set(
      "v",
      "<leader>cm",
      function() jdtls.extract_method(true) end,
      { buffer = buf, desc = "Extract method (Java)" }
    )

    map("<leader>tt", jdtls.test_nearest_method, "Run nearest test (Java)")
    map("<leader>tf", jdtls.test_class, "Run test class (Java)")
    map("<leader>tp", jdtls.pick_test, "Pick test (Java)")
  end,
}, {
  dap = { hotcodereplace = "auto", config_overrides = {} },
})
