-- counts an associative Lua table (use #table for sequential tables) - Dev_34
function count_table(table)
    local count = 0

    for k, v in pairs(table) do
        count = count + 1
    end

    return count
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function math.round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function output_table(t)
    print("-----", t, "-----")
    for key, value in pairs(t) do
        if type(value) ~= "table" then
            print("[", key, "]: ", value)
        else
            print(key .. " {")
            for k, v in pairs(value) do
                if type(v) ~= "table" then
                    print("[", k, "]: ", v)
                else
                    print(k .. " {")
                    for k2, v2 in pairs(v) do
                        print("[", k2, "]: ", v2)
                    end
                    print("}")
                end
            end
            print("}")
        end
    end
    print("------------------------")
end

-- Dev_34
function random_table_value(t)
    local keys = {}
    for k in pairs(t) do table.insert(keys, k) end
    return t[keys[math.random(#keys)]]
end

-- Dev_34
function random_table_key(t)
    local keys = {}
    for k in pairs(t) do table.insert(keys, k) end
    return keys[math.random(#keys)]
end

-- omitted keys is a table where key is index and value can be anything except false or 0
function random_weighted_table_value(weighted_table, omitted_keys)
    if not omitted_keys then
        omitted_keys = {}
    end

    local sum = 0
    for key, weight in pairs(weighted_table) do
        if not omitted_keys[key] then
            sum = sum + weight
        end
    end

    local rand = math.random() * sum
    local found
    for key, weight in pairs(weighted_table) do
        if not omitted_keys[key] then
            rand = rand - weight
            if rand < 0 then
                found = key
                break
            end
        end
    end

    return found
end

function table.compare(tbl1, tbl2)
	for k, v in pairs(tbl1) do
		if tbl2[k] ~= v then
			return false
		end
	end

	for k, v in pairs(tbl2) do
		if tbl1[k] ~= v then
			return false
		end
	end

	return true
end

-- splits a string given a seperator
-- returns a sequential table of tokens, which could be empty
function split(input_str, seperator)
    if seperator == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(input_str, "([^" .. seperator .. "]+)") do
        table.insert(t, str)
    end
    return t
end

-- returns a reversed table where the values are Copy'ed
function reversed_copy(t)
    local reversed_copied_table = {}
    for i = #t, 1, -1 do
        table.insert(reversed_copied_table, Copy(t[i]))
    end
    return reversed_copied_table
end