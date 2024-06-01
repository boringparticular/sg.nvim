local shared = require "sg.components.shared"

---@class CodyHistoryOpts
---@field open function(self): Create a buf, win pair
---@field split string?
---@field height number|string
---@field width number|string
---@field row number|string
---@field col number|string
---@field filetype string?

---@class CodyHistory
---@field open function(self): Open the window and bufnr, mutating self to store new win and bufnr
---@field opts CodyHistoryOpts
---@field bufnr number
---@field win number
---@field visible boolean
local CodyHistory = {}
CodyHistory.__index = CodyHistory

--- Create a new CodyHistory
---@param opts CodyHistoryOpts
---@return CodyHistory
function CodyHistory.init(opts)
  return setmetatable({
    open = assert(opts.open, "Must have open function passed"),
    opts = opts,
    bufnr = -1,
    win = -1,
    visible = false,
  }, CodyHistory)
end

function CodyHistory:show()
  self:open()

  vim.api.nvim_buf_set_name(self.bufnr, string.format("Cody History (%d)", self.bufnr))
  vim.wo[self.win].foldmethod = "marker"
  vim.wo[self.win].conceallevel = 3
  vim.wo[self.win].concealcursor = "n"

  vim.bo[self.bufnr].filetype = self.opts.filetype or "markdown.cody_history"

  local last_line = vim.api.nvim_buf_line_count(self.bufnr)
  local last_column = #vim.api.nvim_buf_get_lines(self.bufnr, last_line - 1, last_line, false)[1]
  vim.api.nvim_win_set_cursor(self.bufnr, {last_line, last_column})

end

function CodyHistory:delete()
  self:hide()
  self.bufnr = shared.buf_del(self.bufnr)
end

function CodyHistory:hide()
  self.win = shared.win_del(self.win)
end

return CodyHistory
