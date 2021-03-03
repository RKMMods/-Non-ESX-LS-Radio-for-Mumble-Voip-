local radioMenu = false

function PrintChatMessage(text)
    TriggerEvent('chatMessage', "system", { 255, 0, 0 }, text)
end

function enableRadio(enable)
  SetNuiFocus(true, true)
  radioMenu = enable
  PhonePlayIn()

  SendNUIMessage({
    type = "enableui",
    enable = enable
  })
end

RegisterCommand('radio', function(source, args)
    if Config.enableCmd then
      enableRadio(true)
    end
end, false)

RegisterNUICallback('joinRadio', function(data, cb)
    local _source = source
    local playerName = GetPlayerName(PlayerId())

      if tonumber(data.channel) <= Config.RestrictedChannels then         
            exports["mumble-voip"]:SetRadioChannel(0)
            exports["mumble-voip"]:SetRadioChannel(tonumber(data.channel))
            exports["mumble-voip"]:SetMumbleProperty("radioEnabled", true)          
            exports['mythic_notify']:DoHudText('inform', Config.messages['joined_to_radio'] .. data.channel .. '.00 MHz </b>')
            TriggerEvent('notification',Config.messages['joined_to_radio'] .. data.channel .. '.00 MHz </b>',1)
      else
        if tonumber(data.channel) > Config.RestrictedChannels then
          exports["mumble-voip"]:SetRadioChannel(0)
          exports["mumble-voip"]:SetRadioChannel(tonumber(data.channel))
          exports["mumble-voip"]:SetMumbleProperty("radioEnabled", true)
          TriggerEvent('notification',Config.messages['joined_to_radio'] .. data.channel .. '.00 MHz </b>',1)  
          exports['mythic_notify']:DoHudText('info', Config.messages['joined_to_radio'] .. data.channel .. '.00 MHz </b>')        
        else
          TriggerEvent('notification',Config.messages['you_on_radio'] .. data.channel .. '.00 MHz </b>',1)  
          exports['mythic_notify']:DoHudText('error', Config.messages['you_on_radio'] .. data.channel .. '.00 MHz </b>')
        end
      end
    cb('ok')
end)

RegisterNUICallback('leaveRadio', function(data, cb)
   local playerName = GetPlayerName(PlayerId())
    exports["mumble-voip"]:SetRadioChannel(0)
    exports["mumble-voip"]:SetMumbleProperty("radioEnabled", false)
    TriggerEvent('notification', Config.messages['you_leave'],1)  
    exports['mythic_notify']:DoHudText('error', Config.messages['you_leave'] )    
   cb('ok')

end)

RegisterNUICallback('escape', function(data, cb)
    enableRadio(false)
    SetNuiFocus(false, false)
    PhonePlayOut()
    cb('ok')
end)

RegisterNetEvent('ls-radio:use')
AddEventHandler('ls-radio:use', function()
  enableRadio(true)
end)

RegisterNetEvent('ls-radio:onRadioDrop')
AddEventHandler('ls-radio:onRadioDrop', function(source)
  local playerName = GetPlayerName(source)
    exports["mumble-voip"]:SetRadioChannel(0)     
   -- TriggerEvent('notification', Config.messages['you_leave'],1)     
    exports['mythic_notify']:DoHudText('inform', Config.messages['you_leave'])
end)

Citizen.CreateThread(function()
    while true do
        if radioMenu then                      
            DisableControlAction(0, 1, guiEnabled) -- LookLeftRight
            DisableControlAction(0, 2, guiEnabled) -- LookUpDown
            DisableControlAction(0, 142, guiEnabled) -- MeleeAttackAlternate
            DisableControlAction(0, 106, guiEnabled) -- VehicleMouseControlOverride
            if IsDisabledControlJustReleased(0, 142) then -- MeleeAttackAlternate
                SendNUIMessage({
                    type = "click"
                })
            end
        end
        Citizen.Wait(0)
    end
end)

local Radio = {

	Prop = `prop_cs_hand_radio`,
	Bone = 28422,
	Offset = vector3(0.0, 0.0, 0.0),
	Rotation = vector3(0.0, 0.0, 0.0),
	Dictionary = {
		"cellphone@",
		"cellphone@in_car@ds",
		"cellphone@str",
		"random@arrests",
	},
	Animation = {
		"cellphone_text_in",
		"cellphone_text_out",
		"cellphone_call_listen_a",
		"generic_radio_chatter",
	},
	Clicks = true, -- Radio clicks
}

-- Citizen.CreateThread(function()
-- 	while true do
--     Citizen.Wait(0)
--     if IsControlJustPressed(0, 137) then
--       loadanimdict('random@arrests')
--       TaskPlayAnim(GetPlayerPed(-1), 'random@arrests', 'generic_radio_chatter', 8.0, -8, -1 , 63 , 0, 0, 0, 0)      
--       SetEnableHandcuffs(PlayerId(), true)
--     elseif IsControlJustReleased(0, 137) then  
--       StopAnimTask(GetPlayerPed(-1), 'random@arrests', 'generic_radio_chatter', 2.0)       
--       --ClearPedTasks(GetPlayerPed(-1))         
--       SetEnableHandcuffs(PlayerId(), false)
--     end
--     if IsEntityPlayingAnim(GetPlayerPed(PlayerId()), 'random@arrests', 'generic_radio_enter', 3) then
--       DisableActions(PlayerId())
--     elseif IsEntityPlayingAnim(GetPlayerPed(PlayerId()), 'random@arrests', 'radio_chatter', 3) then
--       DisableActions(PlayerId())
--     end
-- 	end
-- end )

Citizen.CreateThread(function()
  while true do
      Citizen.Wait( 0 )
      local ped = PlayerPedId()
      if DoesEntityExist( ped ) and not IsEntityDead( ped ) then
          if not IsPauseMenuActive() then 
              loadAnimDict("random@arrests")
              loadAnimDict("cellphone@")
              if IsControlJustReleased( 0, 137 ) and IsEntityPlayingAnim(ped, "random@arrests", "generic_radio_enter", 3) or IsEntityPlayingAnim(ped, "random@arrests", "radio_chatter", 3) then -- INPUT_CHARACTER_WHEEL (LEFT ALT)
                  ClearPedTasks(ped)
              else
                  if IsControlJustPressed( 0, 137 ) and not IsEntityPlayingAnim(ped, "cellphone@", "cellphone_text_to_call", 3) and not IsPlayerFreeAiming(PlayerId()) then -- INPUT_CHARACTER_WHEEL (LEFT ALT)
                      TaskPlayAnim(ped, "random@arrests", "generic_radio_enter", 8.0, 2.0, -1, 50, 2.0, 0, 0, 0 )
                  elseif IsControlJustPressed( 0, 137 ) and not IsEntityPlayingAnim(ped, "cellphone@", "cellphone_text_to_call", 3) and IsPlayerFreeAiming(PlayerId()) then -- INPUT_CHARACTER_WHEEL (LEFT ALT)
                      TaskPlayAnim(ped, "random@arrests", "radio_chatter", 8.0, 2.0, -1, 50, 2.0, 0, 0, 0 )
                  end 
              end
          end 
      end 
  end
end)

function loadanimdict(dictname)
  if not HasAnimDictLoaded(dictname) then
	  RequestAnimDict(dictname) 
	  while not HasAnimDictLoaded(dictname) do 
		  Citizen.Wait(1)
	  end
  end
end	

function DisableActions(ped)
	DisableControlAction(1, 140, true)
	DisableControlAction(1, 141, true)
	DisableControlAction(1, 142, true)
	DisableControlAction(1, 37, true) -- Disables INPUT_SELECT_WEAPON (TAB)
	DisablePlayerFiring(ped, true) -- Disable weapon firing
end
