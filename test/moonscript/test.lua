local quote
quote = function(v)
  if type(v) == 'string' then
    return ('%q'):format(v)
  else
    return tostring(v)
  end
end
local mdump
mdump = function(t, options)
  options = options or { }
  local limit = options.limit or 1000
  local buff = {
    tables = {
      [t] = true
    }
  }
  local k, tbuff = 1, nil
  local put
  put = function(v)
    buff[k] = v
    k = k + 1
  end
  local put_value
  put_value = function(value)
    if type(value) ~= 'table' then
      put(quote(value))
      if limit and k > limit then
        buff[k] = "..."
        error("buffer overrun")
      end
    else
      if not buff.tables[value] then
        buff.tables[value] = true
        tbuff(value)
      else
        put("<cycle>")
      end
    end
    return put(',')
  end
  tbuff = function(t)
    local mt
    if not (options.raw) then
      mt = getmetatable(t)
    end
    if type(t) ~= 'table' or mt and mt.__tostring then
      return put(quote(t))
    else
      put('{')
      local indices = #t > 0 and (function()
        local _tbl_0 = { }
        for i = 1, #t do
          _tbl_0[i] = true
        end
        return _tbl_0
      end)()
      for key, value in pairs(t) do
        local _continue_0 = false
        repeat
          if indices and indices[key] then
            _continue_0 = true
            break
          end
          if type(key) ~= 'string' then
            key = '[' .. tostring(key) .. ']'
          elseif key:match('%s') then
            key = quote(key)
          end
          put(key .. ':')
          put_value(value)
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
      if indices then
        for _index_0 = 1, #t do
          local v = t[_index_0]
          put_value(v)
        end
      end
      if buff[k - 1] == "," then
        k = k - 1
      end
      return put('}')
    end
  end
  pcall(tbuff, t)
  return table.concat(buff)
end
print(mdump({
  1,
  2,
  3
}))
return print(mdump({
  1,
  {
    1,
    {
      1,
      2,
      3
    },
    2,
    3
  },
  {
    1,
    2,
    3
  }
}))
