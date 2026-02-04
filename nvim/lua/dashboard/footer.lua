local M = {}

math.randomseed(os.time())

local options = {
  arch = {
    "Snort! Snort! Snort!",
    "I use arch btw :3",
  },
  vn = {
    --  Steins;Gate
    "El Psy Kongroo",
    "Tuturu~",
    "This is not the first loop",
    "We’ve met before… in another timeline",
    "The divergence is unstable",
    -- Danganronpa
    "Sore Wa Chigau Yo",
    "Sore Wa Chigau Zo",
    -- Chaos;Head
    "Whose eyes are those eyes?",
    "Are you watching me?",
    "The delusion trigger is active",
    "This world feels wrong",
  },
}

local categories = {
  "vn",
  "vn",
  "arch",
}

function M.random()
  local category = categories[math.random(#categories)]
  local pool = options[category]

  return pool[math.random(#pool)]
end

return M
