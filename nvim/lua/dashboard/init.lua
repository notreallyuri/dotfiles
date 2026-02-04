local header = require("lua.dashboard.header")
local footer = require("lua.dashboard.footer")
local keys = require("lua.dashboard.keys")

return {
  header = header.random(),
  footer = footer.random(),
  keys = keys,
}
