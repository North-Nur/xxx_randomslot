
ESX = nil
local InZone  
local firstLoadData = false 
Keys 					  = {
   ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
   ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
   ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
   ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
   ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
   ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
   ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
   ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
   ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

checkHasItem = function(item_name, count_)
	local inventory = ESX.GetPlayerData().inventory
	for i=1, #inventory do
		local item = inventory[i]
		if item_name == item.name and item.count >= count_ then
			return true
		end
	end
	return false
end
checkItemCount = function(item_name)
	local inventory = ESX.GetPlayerData().inventory
	for i=1, #inventory do
		local item = inventory[i]
		if item_name == item.name then
			return item.count
		end
	end
	return false
end
getLabelItems = function(item_name)
	local inventory = ESX.GetPlayerData().inventory
	for i=1, #inventory do
		local item = inventory[i]
		if item_name == item.name then
			return item.label
		end
	end
	if item_name == 'cash' or item_name == 'money'  then 
		return 'Cash'
	end 
	if item_name == 'black_money' then 
		return 'Black money'
	end 
	local CarName = nil 
	if GetHashKey(item_name) then
		
		CarName = GetDisplayNameFromVehicleModel(GetHashKey(item_name))
	end 
	return CarName or 'Unknown'
end
Citizen.CreateThread(function()
   while ESX == nil do
	   TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
	   Citizen.Wait(0)
   end
  
--    print(json.encode(PlayerData))
   Wait(4500)
   for _ , v in pairs(Config.Gachapon) do 
		if v.props then 
			RequestModel(GetHashKey(v.props))
			while not HasModelLoaded(v.props) do
				Citizen.Wait(0)
			end
			v.prop = CreateObject(GetHashKey(v.props), v.coords-vector3(0,0,1), false, false, true)
			SetEntityHeading(v.prop , v.heading )
			FreezeEntityPosition(v.prop,true)
		end 
   end 
end)
AddEventHandler('onResourceStop', function(res)
	if res == GetCurrentResourceName() then 
		for _ , v in pairs(Config.Gachapon) do 
			if v.prop then 
				DeleteEntity(v.prop)
			end 
	   end 
	end 
 end)
local FirstLoad = false 
local DataAll = {

}

local OpenUIID = ''


--------------LOOP ALL------------------
CreateThread(function ()
	while true do 
		local sleep = 1000 
		local ped = PlayerPedId()
		local coords = GetEntityCoords(ped)
		for _ , v in pairs(Config.Gachapon) do 
			local Dist = #(coords - v.coords) 
			if Dist <= 3 then
				 sleep = 0 
				exports['pt_drawtext3d']:DrawText3D('SLOT MACHINE', v.title, v.coords + vector3(0, 0, 1.04))
				 -- UI TEXT 
				 if Dist <= 1.4 then 
					if IsControlJustPressed(0, 38) and IsPedOnFoot(ped) then 
						-- PRESS E TO OPEN UI 
						toggleUI(true,v.IDSLOT,v.title)
						print("OK")
					end 
					
				 end 

			end 
		end 
		Wait(sleep)
	end 
end)
local LastTable = {}
local LastOpen  
toggleUI = function ( bool , index , title )
	if bool then 
		OpenUIID = index or ''
	end 
	
	SetNuiFocus(bool,bool)
	if bool then 
		if not firstLoad then 
			TriggerServerEvent('xxx_randomslot:LoadFistData-sv')
		end
		while  not firstLoad do 
			Wait(0)
		end 
	end 
	if LastOpen ~= OpenUIID then 
		local sortedTable = {}
		-- print(json.encode(DataAll[index]))
		for key, value in pairs(DataAll[index].reward) do
			table.insert(sortedTable, {key = key, value = value})
		end

		-- เรียงลำดับตาม Table['ITEMNAME'][2]
		table.sort(sortedTable, function(a, b)
			return a.value[2] < b.value[2] -- เรียงจากน้อยไปมาก
		end)
		LastTable = sortedTable
		LastOpen = OpenUIID
		SendNUIMessage({
			action = 'display',
			bool = bool,
			data = sortedTable,
			itemneed = DataAll[OpenUIID].item,
			count = checkItemCount(DataAll[OpenUIID].item),
			title = title
		})
	else 
		SendNUIMessage({
			action = 'display',
			bool = bool,
		
		})
		SendNUIMessage({
			action = 'syncCount',
			count = checkItemCount(DataAll[OpenUIID].item),
		
		})
	end 
	
end

------------ NUI CALL BACK ------------
local delay = false 
RegisterNUICallback('random',function (data)
	if delay then return end 
	delay = true 
	if checkHasItem(DataAll[OpenUIID].item,1) then 
		-- print(OpenUIID)
		TriggerServerEvent('xxx_randomslot:randomcheck',OpenUIID)
		Wait(500)
		SendNUIMessage({
			action = 'syncCount',
			count = checkItemCount(DataAll[OpenUIID].item),
		
		})
		-- print('RANDOM')
	end 
	Wait(500)
	delay = false 
	
end)
RegisterNUICallback('enter',function (data)
	TriggerServerEvent('xxx_randomslot:enter')

	
end)
RegisterNUICallback('exit',function (data)
	toggleUI(false)
	
end)


---
------------ ALL EVENT ----------------
--LOAD FIRST 
RegisterNetEvent('xxx_randomslot:LoadFirstData')
AddEventHandler('xxx_randomslot:LoadFirstData', function( DATA)
	if not firstLoad then 
		firstLoad = true 
		DataAll = DATA
		for _ , v in pairs(DataAll) do 
			for __ , w in pairs(v.reward) do 
				w[3] = getLabelItems(__)
			end
		end 
	end 
end)
RegisterNetEvent('xxx_randomslot:syncRewardItem')
AddEventHandler('xxx_randomslot:syncRewardItem', function( source , Index, Item, Count)
	if firstLoad then 
		if DataAll[Index] then 
			 DataAll[Index].reward[Item][1] = Count  
			 local serverId = GetPlayerServerId(PlayerId())
			if serverId == source then 
				local positioncheck = 0 
				for _ , v in pairs(LastTable) do 
					if v.key == Item then 
						positioncheck = _ 
					end 
				end 
				SendNUIMessage({
					action = 'random',
					index = (positioncheck - 1)
				})
				Wait(7600)
				
				SendNUIMessage({
					action = 'syncR',
					item = Item,
					count = Count,
					empty = Count >= LastTable[positioncheck].value[2]
				})
			else 
				local positioncheck = 0 
				for _ , v in pairs(LastTable) do 
					if v.key == Item then 
						positioncheck = _ 
					end 
				end 
				SendNUIMessage({
					action = 'syncR',
					item = Item,
					count = Count,
					empty = Count >= LastTable[positioncheck].value[2]
				})
			end 
			
		end 
	end 
end)

-- แสดงผล

-- SYNC RESET BOX SLOT
RegisterNetEvent('xxx_randomslot:syncRewardItemID' )
AddEventHandler('xxx_randomslot:syncRewardItemID', function(ID , DATA)
	if firstLoad then 
		if DataAll[ID] then 
			DataAll[ID] = DATA 
			for _ , v in pairs(DataAll[ID].reward) do 
				v[3] = getLabelItems(_)
			end 
		end 
	end 
end)