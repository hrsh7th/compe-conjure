local Pattern = require'compe.pattern'
-- TODO: Activate only when in the filetype match g:compe_conjure_fts
-- For now just {"fennel", "clojure", "janet"}

-- FIXME: When opening a supported filetype,
-- require'compe':register_lua_source('conjure', require'compe_conjure')
-- need to be call. It should be activated automatically?

-- FIXME: do not show duplications and same keyword with
-- differences such as TODO and TODO. Also do not show duplications
-- with other sources like buffer source.

-- FIXME: do not show a full suggestion until triggerd by /, like str/format.
-- show str until / is added show what is under str

local Source = {}

local function completor(input)
  -- Only works if a server is supported, otherwise returns error
  local promise_id = require('conjure.eval')['completions-promise'](input)
  local checker = require'conjure.promise'
  if checker['done?'](promise_id) then
    return checker.close(promise_id)
    -- returns a list of kv = word, value
  end
end

function Source.new()
  return setmetatable({}, { __index = Source })
end

function Source.get_metadata(self)
  return {
    priority = 10;
    dub = 0;
    menu = '[Conjure]';
  }
end

function Source.datermine(self, context)
  return {
    keyword_pattern_offset = Pattern:get_keyword_pattern_offset(context)
    -- TODO is this important?
    -- matchstr(l:typed, '[0-9a-zA-Z.!$%&*+/:<=>?#_~\^\-\\]\+')
  }
end

function Source.complete(self, context)
  context.callback({
    items = completor("")
    -- FIXME: completor takes input, but has no effect on the returning results
  })
end


return Source
-- references
-- https://github.com/jlesquembre/coc-conjure/blob/master/index.js
-- https://github.com/thecontinium/asyncomplete-conjure.vim/blob/master/autoload/asyncomplete/sources/conjure.vim
