-- Unload some modules only for testing

Events:Subscribe("ServerStart", function()
    Console:Run("unload settings")
    Console:Run("unload survival") -- TODO: remove this
    --Console:Run("unload terrainmap")
    Console:Run("unload effects")
end)