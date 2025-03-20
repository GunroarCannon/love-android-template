local https = require("https")
local ltn12 = require("ltn12")
local json = toybox.json--require("toybox.json") -- Use a JSON library to encode/decode JSON data

-- WalletNetwork class
local WalletNetwork = {}
WalletNetwork.__index = WalletNetwork

-- Constructor
function WalletNetwork.new(baseUrl)
    local self = setmetatable({}, WalletNetwork)
    self.baseUrl = baseUrl or "https://cards-of-loop-sonic-server.onrender.com"
    return self
end

-- Function to make an HTTP POST request
function WalletNetwork:post(endpoint, data)
    local response = {}
    local body = json.encode(data)
    local url = self.baseUrl .. endpoint
    local code, response, headers = https.request(url, {
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = #body,
        },
        data = body,--ltn12.source.string(body),
        --sink = ltn12.sink.table(response),
    })
    log(code) log(response)
    return (response), code
end

-- Function to make an HTTP GET request
function WalletNetwork:get(endpoint)
    local response = {}
    local url = self.baseUrl .. endpoint
    local code, response, headers = https.request(url, {
        method = "GET",
        --sink = ltn12.sink.table(response),
    })
    log(code) log(response)
    return (response), code
end

-- Function to connect wallet
function WalletNetwork:connectWallet(walletAddress)
    local response, code = self:post("/connectWallet", {walletAddress = walletAddress})
    if code == 200 then
        return json.decode(response)
    else
        return response
    end
end

-- Function to update score
function WalletNetwork:updateScore(walletAddress, score)
    local response, code = self:post("/updateScore", {walletAddress = walletAddress, score = score})
    if code == 200 then
        return json.decode(response)
    else
        return nil, response
    end
end

-- Function to check wallet balance
function WalletNetwork:checkWalletBalance(walletAddress)
    local response, code = self:get("/walletBalance/" .. walletAddress)
    if code == 200 then
        return json.decode(response)
    else
        return nil, response
    end
end

return WalletNetwork