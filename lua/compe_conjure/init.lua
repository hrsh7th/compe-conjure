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
    priority = 10;
    dub = 0;
    menu = '[Conjure]';
  }
end

function Source.datermine(self, context)
  local offset = vim.regex('[0-9a-zA-Z.!$%&*+/:<=>?#_~\\^\\-\\\\]\\+$'):match_str(context.before_line)
  if not offset then
    return {}
  end
  return { keyword_pattern_offset = offset + 1 }
end

function Source.complete(self, args)
  self:abort()
  local input = args.context:get_input(args.keyword_pattern_offset)
  self.promise_id = ConjureEval['completions-promise'](input)
  self.timer = vim.loop.new_timer()
  self.timer:start(100, 100, vim.schedule_wrap(function()

    -- TODO make sure that the source is connected, otherwise return empty list
    if ConjurePromise['done?'](self.promise_id) then
      args.callback({
        items = ConjurePromise.close(self.promise_id)
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
