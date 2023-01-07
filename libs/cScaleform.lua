--[[
  ** RealWorld Scaleform Class
  ** Author: MAC <mac@realw.kr>
  ** Version: 1.0.0
]]
Scaleform = rw_class()

function Scaleform:__init()
end

function Scaleform:Request(scaleform)
  local scaleform_handle = RequestScaleformMovie(scaleform)
  local limit = 2000
  local isLoaded = false
  while limit > 0 do
    Citizen.Wait(1)
    if HasScaleformMovieLoaded(scaleform_handle) then
      isLoaded = true
      break
    end
    limit = limit - 1
  end
  if not isLoaded then
    return nil
  end
  return scaleform_handle
end

function Scaleform:Call(scaleform, isReturnType, the_function, ...)
  BeginScaleformMovieMethod(scaleform, the_function)
  local args = {...}
  local returnValue = nil

  if args ~= nil then
    for i = 1, #args do
      local arg_type = type(args[i])

      if arg_type == "boolean" then
        ScaleformMovieMethodAddParamBool(args[i])
      elseif arg_type == "number" then
        if not string.find(args[i], "%.") then
          ScaleformMovieMethodAddParamInt(args[i])
        else
          ScaleformMovieMethodAddParamFloat(args[i])
        end
      elseif arg_type == "string" then
        ScaleformMovieMethodAddParamTextureNameString(args[i])
      end
    end

    if isReturnType == nil then
      EndScaleformMovieMethod()
    else
      local rv = EndScaleformMovieMethodReturnValue()
      local limit = 2000
      while limit > 0 do
        Citizen.Wait(1)
        if IsScaleformMovieMethodReturnValueReady(rv) then
          if isReturnType == "string" then
            returnValue = GetScaleformMovieMethodReturnValueString(rv)
          elseif isReturnType == "int" then
            returnValue = GetScaleformMovieMethodReturnValueInt(rv)
          elseif isReturnType == "bool" then
            returnValue = GetScaleformMovieMethodReturnValueBool(rv)
            if returnValue == 1 or returnValue == true then
              returnValue = true
            else
              returnValue = false
            end
          end
          break
        end
        limit = limit - 1
      end
    end
  end

  return returnValue
end

Scaleform = Scaleform()
