

local network_send = Network.Send
function Network:Send(event_name, args)
    local aggregation = network_aggregations[event_name]
    if aggregation then
        aggregation:AddRequest(args)
    else
        network_send(event_name, args)
    end
end

-- aggregates network:send's up until the delay after the first request, then sends
function Network:SetAggregationSendDelay(event_name, delay)
    network_aggregations[event_name] = NetworkAggregation(delay)
end


local network_aggregations = {}
class "NetworkAggregation"

function NetworkAggregation:__init(delay)
    self.delay = delay
    self.requests = {}
    self.send_timer = Timer()
end

function NetworkAggregation:AddRequest(request_data)
    print("NetworkAggregation:AddRequest Entered")
    if #self.requests == 0 then
        self:FreshBatch()
    end
    table.insert(self.requests, request_data)
end

function NetworkAggregation:FreshBatch()
    self.send_timer:Restart()
    self.send_check_thread = Thread(function()
        local continue = true
        while continue do
            continue = self:CheckIfShouldSend()
            if continue then
                Timer.Sleep(10)
            else
                break
            end
        end
    end)
end

function NetworkAggregation:CheckIfShouldSend()
    if self.send_timer:GetMilliseconds() >= self.delay then
        self:Send()
        return false
    else
        return true
    end
end

function NetworkAggregation:Send()
    print("sending network aggregation with requests:")
    output_table(self.requests)

    self.send_check_thread = nil
    self.requests = {}
end