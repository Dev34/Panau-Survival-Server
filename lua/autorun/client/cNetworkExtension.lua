

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
end

function NetworkAggregation:Send()
    print("sending network aggregation")



    self.request = {}
end