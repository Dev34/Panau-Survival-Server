class "PathNavigation"

function PathNavigation:__init()
    getter_setter(self, "active")
    getter_setter(self, "path")
    getter_setter(self, "speed_multiplier")
    self.active = false

    self.has_computed_path = false
end

function PathNavigation:StartPath()
    self.active = true
    self.life_timer = Timer()
end

function PathNavigation:GetPosition()
    if not self.has_computed_path then
        self:ComputePath()
    end

    local progress_percentage = self.life_timer:GetMilliseconds() / self.lifetime_ms
    local distance_travelled = self.path_distance_total * progress_percentage
    local path_positions = self.path:GetPositions()
    local progress_percentage_to_next_node
    local current_node_index, next_node_index
    for node_index, position in ipairs(path_positions) do
        distance_travelled = distance_travelled - self.path_distance_map[node_index]
        if distance_travelled < 0 then
            progress_percentage_to_next_node = (distance_travelled + self.path_distance_map[node_index]) / self.path_distance_map[node_index]
            current_node_index = node_index
            next_node_index = node_index + 1
            --print("Currently at node " .. tostring(node_index))
            --print("overall progress percentage: " .. tostring(math.round(progress_percentage, 3)))
            --print("progress to next node: " .. tostring(progress_percentage_to_next_node))
            break
        end
    end

    if not next_node_index then
        return path_positions[current_node_index]
    end

    local exact_position = math.lerp(
        path_positions[current_node_index],
        path_positions[next_node_index],
        progress_percentage_to_next_node
    )

    return exact_position
end

--[[
    [1]: 10,
    [2]: 12,
    [3]: 5
]]

function PathNavigation:ComputePath()
    self.has_computed_path = true
    self.path_distance_total = 0
    self.path_distance_map = {}

    local dist
    local next_position
    local distance_to_next_node
    local distance_function = Vector3.Distance
    local path_positions = self.path:GetPositions()
    for node_index, position in ipairs(path_positions) do
        next_position = path_positions[node_index + 1]
        if next_position then
            distance_to_next_node = distance_function(position, next_position)
            self.path_distance_total = self.path_distance_total + distance_to_next_node
            self.path_distance_map[node_index] = distance_to_next_node
        end
    end

    self.lifetime_ms = self.path_distance_total * (1000.0 / self.speed_multiplier) -- TODO: replace with speed
    --print("lifetime_ms: ", self.lifetime_ms)
end
