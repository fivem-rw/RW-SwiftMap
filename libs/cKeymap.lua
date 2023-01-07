--[[
  ** RealWorld Keymap Class
  ** Author: MAC <mac@realw.kr>
  ** Version: 1.0.0
]]
Keymap = rw_class()

function Keymap:__init()
  self.maps = {}
  self.id_pool = IdPool()

  self.isKeyDownWait = false
  self.keyDownKey = nil
  self.keyHold = false

  self.actionKeys = {
    {
      ["type"] = "keyboard",
      ["name"] = "Action_LCONTROL",
      ["key"] = "LCONTROL"
    },
    {
      ["type"] = "keyboard",
      ["name"] = "Action_LSHIFT",
      ["key"] = "LSHIFT"
    },
    {
      ["type"] = "keyboard",
      ["name"] = "Action_LMENU",
      ["key"] = "LMENU"
    }
  }
  self.actionKeyMaps = {}
  self:RegisterActionKeys()

  Citizen.CreateThread(
    function()
      while true do
        Citizen.Wait(1)
        if self.isKeyDownWait then
          local kc = 0
          while self.isKeyDownWait do
            Citizen.Wait(10)
            if kc > 50 and self.isKeyDownWait and self.keyDownKey then
              self.isKeyDownWait = false
              self.keyHold = true
              for id, callback in pairs(self.maps[self.keyDownKey]) do
                callback({event = "KeyKeepDown", actionKeys = self.actionKeyMaps})
              end
              self.keyDownKey = nil
            end
            kc = kc + 1
          end
        end
      end
    end
  )
end

function Keymap:Register(key, keytype, name, cb)
  local id = self.id_pool:GetNextId()

  if not self.maps[key] then
    self.maps[key] = {}

    local keymap_name = string.format("keymap_%s", name)
    RegisterKeyMapping("+" .. keymap_name, name, keytype, key)

    RegisterCommand(
      "+" .. keymap_name,
      function()
        self.isKeyDownWait = true
        self.keyDownKey = key
        for id, callback in pairs(self.maps[key]) do
          callback({event = "KeyDown", actionKeys = self.actionKeyMaps})
        end
      end
    )

    RegisterCommand(
      "-" .. keymap_name,
      function()
        self.isKeyDownWait = false
        self.keyDownKey = nil
        if self.keyHold then
          self.keyHold = false
          for id, callback in pairs(self.maps[key]) do
            callback({event = "KeyKeepUp", actionKeys = self.actionKeyMaps})
          end
        else
          for id, callback in pairs(self.maps[key]) do
            callback({event = "KeyUp", actionKeys = self.actionKeyMaps})
          end
        end
      end
    )
  end

  self.maps[key][id] = cb

  return id
end

function Keymap:Unregister(key, id)
  if self.maps[key] and self.maps[key][id] then
    self.maps[key][id] = nil
  end
end

function Keymap:RegisterActionKeys()
  for _, keyObj in ipairs(self.actionKeys) do
    self.actionKeyMaps[keyObj.key] = false

    local keymapName = string.format("keymap_%s", keyObj.name)
    RegisterKeyMapping("+" .. keymapName, keyObj.name, keyObj.type, keyObj.key)

    RegisterCommand(
      "+" .. keymapName,
      function()
        self.actionKeyMaps[keyObj.key] = true
      end
    )

    RegisterCommand(
      "-" .. keymapName,
      function()
        self.actionKeyMaps[keyObj.key] = false
      end
    )
  end
end

function Keymap:IsCheckActionKey(activeKey)
  local isActive = false
  for key, active in pairs(self.actionKeyMaps) do
    if activeKey == key and active == true then
      isActive = true
      break
    end
  end
  return isActive
end

Keymap = Keymap()
