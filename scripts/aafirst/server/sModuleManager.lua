-- Unload some modules only for testing

Events:Subscribe("ServerStart", function()
    Console:Run("unload spn")
    Console:Run("unload settings")
    Console:Run("unload effects")
end)