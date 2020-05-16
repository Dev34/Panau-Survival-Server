-- adds instance:GetVariableName and instance:SetVariableName to a class instance
-- less clutter code when using getters & setters, makes atomic operations less painful
function getter_setter(instance, get_set_name)
    local function firstCharacterToUpper(str)
        return (str:gsub("^%l", string.upper))
    end

    local name = ""
    local words = split(get_set_name, "_")
    for k, word in ipairs(words) do
        name = name .. firstCharacterToUpper(word)
    end

    local get_name = "Get" .. name
    local set_name = "Set" .. name

    instance[get_name] = function()
        return instance[get_set_name]
    end
    
    instance[set_name] = function(instance, value)
        instance[get_set_name] = value
    end
end