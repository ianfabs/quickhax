local utils = {}

-- like js Array.map
function utils.map(tbl, f)
  local t = {}
  for k,v in pairs(tbl) do
      t[k] = f(v)
  end
  return t
end

-- anonymous function
function utils.fn(s, ...)
  local src = [[
    local L1, L2, L3, L4, L5, L6, L7, L8, L9 = ...
    return function(P1,P2,P3,P4,P5,P6,P7,P8,P9) return ]] .. s .. [[ end
  ]]
  return loadstring(src)(...)
end

function utils.print_r(arr, indentLevel)
  local str = ""
  local indentStr = "#"

  if(indentLevel == nil) then
      print(utils.print_r(arr, 0))
      return
  end

  for i = 0, indentLevel do
      indentStr = indentStr.."\t"
  end

  for index,value in pairs(arr) do
      if type(value) == "table" then
          str = str..indentStr..index..": \n"..utils.print_r(value, (indentLevel + 1))
      else 
          str = str..indentStr..index..": "..value.."\n"
      end
  end
  return str
end

return utils