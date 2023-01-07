local OpenSwiftMap = function()
  if IsFrontendReadyForControl() then
    SetFrontendActive(false)
  else
    if IsFrontendReadyForControl() then
      SetFrontendActive(false)
    else
      SetNuiFocus(false, false)
      ActivateFrontendMenu(GetHashKey("FE_MENU_VERSION_SP_PAUSE"), true)
      for i = 1, 10 do
        Citizen.Wait(100)
        local sf = Scaleform:Request("PAUSE_MENU_SP_CONTENT")
        if Scaleform:Call(sf, "bool", "SET_REALWORLD_MAP_MODE_MADE_BY_MAC") then
          break
        end
      end
    end
  end
end

Citizen.CreateThread(
  function()
    Citizen.Wait(100)
    Keymap:Register(
      "M",
      "keyboard",
      "MapControl",
      function(data)
        if data.event == "KeyUp" then
          OpenSwiftMap()
        end
      end
    )
  end
)
