ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local DataAll = {}

Citizen.CreateThread(function()
    for _, v in pairs(Config.Gachapon) do
        DataAll[v.IDSLOT] = {
            item = v.item,
            reward = {}
        }
    end
end)

RegisterServerEvent('xxx_randomslot:LoadFistData-sv')
AddEventHandler('xxx_randomslot:LoadFistData-sv', function()
    local _source = source
    TriggerClientEvent('xxx_randomslot:LoadFirstData', _source, DataAll)
end)

RegisterServerEvent('xxx_randomslot:randomcheck')
AddEventHandler('xxx_randomslot:randomcheck', function(IDSLOT)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if DataAll[IDSLOT] then
        local itemNeeded = DataAll[IDSLOT].item
        if xPlayer.getInventoryItem(itemNeeded).count >= 1 then
            xPlayer.removeInventoryItem(itemNeeded, 1)

            local randomItem = 'cement'
            local randomCount = math.random(1, 5)

            if DataAll[IDSLOT].reward[randomItem] then
                DataAll[IDSLOT].reward[randomItem][1] = DataAll[IDSLOT].reward[randomItem][1] + randomCount
                if DataAll[IDSLOT].reward[randomItem][1] > DataAll[IDSLOT].reward[randomItem][2] then
                    DataAll[IDSLOT].reward[randomItem][1] = DataAll[IDSLOT].reward[randomItem][2]
                end
            else
                DataAll[IDSLOT].reward[randomItem] = {randomCount, 100, 'Cement'} 
            end

            xPlayer.addInventoryItem(randomItem, randomCount)

            TriggerClientEvent('xxx_randomslot:syncRewardItem', -1, _source, IDSLOT, randomItem, DataAll[IDSLOT].reward[randomItem][1])
        else
            TriggerClientEvent('esx:showNotification', _source, 'คุณไม่มี ' .. itemNeeded .. ' เพียงพอ')
        end
    end
end)

RegisterServerEvent('xxx_randomslot:syncRewardItemID')
AddEventHandler('xxx_randomslot:syncRewardItemID', function(IDSLOT, DATA)
    if DataAll[IDSLOT] then
        DataAll[IDSLOT] = DATA
        TriggerClientEvent('xxx_randomslot:syncRewardItemID', -1, IDSLOT, DATA)
    end
end)

RegisterServerEvent('xxx_randomslot:enter')
AddEventHandler('xxx_randomslot:enter', function()
    local _source = source
    TriggerClientEvent('esx:showNotification', _source, 'คุณเข้าสู่ระบบแล้ว')
end)