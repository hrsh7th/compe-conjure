local Source = {}
local ConjureEval = require'conjure.eval'
local ConjurePromise = require'conjure.promise'

function Source.new()
  local self = setmetatable({}, { __index = Source })
  self.timer = nil
  self.promise_id = nil
  return self
end

function Source.get_metadata(self)
  return {
    priority = 1000;
    filetypes = {"fennel", "janet"};
    dub = 0;
    menu = '[conjure]';
  }
end

function Source.datermine(self, context)
  local offset = vim.regex('[0-9a-zA-Z.!$%&*+/:<=>?#_~\\^\\-\\\\]\\+$'):match_str(context.before_line)
  if not offset then
    return {}
  end
  local trigger
  if vim.fn.index({'.'}, context.before_char) >= 0 then
    trigger = context.col
  else
    trigger = -1
  end
  if vim.bo.filetype == 'fennel' then
    return {
      keyword_pattern_offset = offset + 1,
      trigger_character_offset =  trigger
    }
  else
    return { keyword_pattern_offset = offset + 1, }
  end
end

local function lua_comp_get(s_arr, prefix, r_arr)
  -- TODO: include global variables
  if #s_arr == 0 then return end
  local head = table.remove(s_arr, 1)
  if not r_arr then r_arr = _G end
  if type(r_arr[head]) == 'table' then
    return lua_comp_get(s_arr, prefix .. head .. '.', r_arr[head])
  end
  local keys = vim.tbl_keys(r_arr)
  table.sort(keys)
  local candiates = {}
  for _, v in ipairs(keys) do
    local regex = '^' .. string.gsub(head, '%*', '.*')
    if v:find(regex) then table.insert(candiates, {word = prefix .. v}) end
  end
  return candiates
end

function lua_comp(input)
  local index = input:find('[%w._*]*$')
  local cmd = input:sub(index)
  return lua_comp_get(vim.split(cmd, '.', true), input:sub(1, index - 1))
end

print(vim.inspect(lua_comp("vim.s")))

function Source.complete(self, args)
  self:abort()
  local input = args.context:get_input(args.keyword_pattern_offset)
  self.promise_id = ConjureEval['completions-promise'](input)
  self.timer = vim.loop.new_timer()
  self.timer:start(100, 100, vim.schedule_wrap(function()
    -- TODO make sure that the source is connected, otherwise return empty list
    if ConjurePromise['done?'](self.promise_id) then
      local conjure_items = ConjurePromise.close(self.promise_id)
      -- TODO: Trigger on "."
      local res
      if vim.bo.filetype == 'fennel' then
        res = vim.tbl_extend('force', conjure_items, lua_comp(input))
      else
        res = conjure_items
      end
      args.callback({
        items = res
      })
      self:abort()
    end
  end))
end

function Source.abort(self)
  if self.timer then
    self.timer:stop()
    self.timer:close()
    self.timer = nil
  end
  if self.promise_id then
    ConjurePromise.close(self.promise_id)
    self.promise_id = nil
  end
end

return Source.new()

