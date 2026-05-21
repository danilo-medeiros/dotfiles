local M = {}

local ns = vim.api.nvim_create_namespace("sticky_notes")

local function get_root()
  local root = vim.trim(vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"))
  return (vim.v.shell_error == 0 and root ~= "") and root or vim.fn.getcwd()
end

local function load_notes(root)
  local path = root .. "/.codenotes"
  local f = io.open(path, "r")
  if not f then return {} end
  local content = f:read("*a")
  f:close()

  local notes = {}
  local current = {}

  local function flush()
    if #current == 0 then return end
    local header = current[1]
    local file, line_str = header:match("^(.+):(%d+)$")
    if file and line_str then
      local text_lines = {}
      for i = 2, #current do
        table.insert(text_lines, current[i])
      end
      table.insert(notes, {
        file = file,
        line = tonumber(line_str),
        text = table.concat(text_lines, "\n"),
      })
    end
    current = {}
  end

  for line in (content .. "\n"):gmatch("([^\n]*)\n") do
    line = line:gsub("\r", "")
    if line:match("^%s*$") then
      flush()
    else
      table.insert(current, line)
    end
  end
  flush()

  return notes
end

local function save_notes(root, notes)
  local path = root .. "/.codenotes"
  local f = io.open(path, "w")
  if not f then return false end
  local entries = {}
  for _, note in ipairs(notes) do
    local entry = note.file .. ":" .. note.line
    if note.text ~= "" then
      entry = entry .. "\n" .. note.text
    end
    table.insert(entries, entry)
  end
  f:write(table.concat(entries, "\n\n"))
  if #entries > 0 then f:write("\n") end
  f:close()
  return true
end

local function buf_rel_path(bufnr, root)
  local abs = vim.api.nvim_buf_get_name(bufnr)
  if abs == "" then return nil end
  abs = vim.fn.resolve(abs)
  local prefix = root .. "/"
  if abs:sub(1, #prefix) == prefix then
    return abs:sub(#prefix + 1)
  end
  return nil
end

local function wrap_text(text, max_width)
  local result = {}
  for _, line in ipairs(vim.split(text, "\n", { plain = true })) do
    if vim.fn.strdisplaywidth(line) <= max_width then
      table.insert(result, line)
    else
      local current = ""
      for word in line:gmatch("%S+") do
        local candidate = current == "" and word or (current .. " " .. word)
        if vim.fn.strdisplaywidth(candidate) <= max_width then
          current = candidate
        else
          if current ~= "" then table.insert(result, current) end
          current = word
        end
      end
      if current ~= "" then table.insert(result, current) end
    end
  end
  return result
end

local function render(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local root = get_root()
  local rel = buf_rel_path(bufnr, root)
  if not rel then return end

  local win = vim.fn.bufwinid(bufnr)
  if win == -1 then return end
  local wininfo = vim.fn.getwininfo(win)[1]
  local text_width = wininfo.width - wininfo.textoff

  local max_note_width = math.min(60, math.floor(text_width * 0.45))

  local notes = load_notes(root)
  local line_count = vim.api.nvim_buf_line_count(bufnr)

  for _, note in ipairs(notes) do
    if note.file ~= rel then goto continue end
    if type(note.line) ~= "number" or type(note.text) ~= "string" then goto continue end

    local lnum = note.line - 1
    if lnum < 0 or lnum >= line_count then goto continue end

    local wrapped = wrap_text(note.text, max_note_width)
    local first = wrapped[1] or ""

    local virt_lines = nil
    if #wrapped > 1 then
      virt_lines = {}
      for i = 2, #wrapped do
        local chunk = "   " .. wrapped[i]
        local pad = string.rep(" ", math.max(0, text_width - vim.fn.strdisplaywidth(chunk)))
        table.insert(virt_lines, { { pad .. chunk, "StickyNote" } })
      end
    end

    vim.api.nvim_buf_set_extmark(bufnr, ns, lnum, 0, {
      virt_text = { { "  " .. first, "StickyNote" } },
      virt_text_pos = "right_align",
      virt_lines = virt_lines,
      hl_mode = "combine",
    })

    ::continue::
  end
end

local function add_note(bufnr)
  local root = get_root()
  local rel = buf_rel_path(bufnr, root)
  if not rel then return end

  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  local parent_win = vim.api.nvim_get_current_win()

  local input_buf = vim.api.nvim_create_buf(false, true)
  local width = 60
  local height = 8
  local win_width = vim.api.nvim_win_get_width(parent_win)
  local win_height = vim.api.nvim_win_get_height(parent_win)

  local float_win = vim.api.nvim_open_win(input_buf, true, {
    relative = "win",
    win = parent_win,
    row = math.max(0, math.floor(win_height / 2) - math.floor(height / 2)),
    col = math.max(0, math.floor(win_width / 2) - math.floor(width / 2)),
    width = width,
    height = height,
    style = "minimal",
    border = "single",
    title = " note: " .. rel .. ":" .. lnum .. " ",
    title_pos = "center",
  })

  vim.cmd("startinsert")

  local function confirm()
    local lines = vim.api.nvim_buf_get_lines(input_buf, 0, -1, false)
    while #lines > 0 and lines[#lines]:match("^%s*$") do
      table.remove(lines)
    end
    local text = table.concat(lines, "\n")
    vim.api.nvim_win_close(float_win, true)
    if text == "" then return end

    local notes = load_notes(root)
    table.insert(notes, { file = rel, line = lnum, text = text })
    save_notes(root, notes)
    render(bufnr)
    vim.notify("Note added", vim.log.levels.INFO)
  end

  local function cancel()
    vim.api.nvim_win_close(float_win, true)
  end

  vim.keymap.set("n", "<CR>", confirm, { buffer = input_buf, nowait = true })
  vim.keymap.set("n", "<Esc>", cancel, { buffer = input_buf, nowait = true })
  vim.keymap.set("n", "q", cancel, { buffer = input_buf, nowait = true })
end

local function drop_note(bufnr)
  local root = get_root()
  local rel = buf_rel_path(bufnr, root)
  if not rel then return end

  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  local notes = load_notes(root)

  local new_notes = {}
  local removed = false
  for _, note in ipairs(notes) do
    if note.file == rel and note.line == lnum then
      removed = true
    else
      table.insert(new_notes, note)
    end
  end

  if not removed then
    vim.notify("No note at line " .. lnum, vim.log.levels.WARN)
    return
  end

  save_notes(root, new_notes)
  render(bufnr)
  vim.notify("Note removed", vim.log.levels.INFO)
end

function M.setup()
  vim.api.nvim_set_hl(0, "StickyNote", { fg = "#e8c46a", italic = true, default = true })

  vim.api.nvim_create_user_command("NI", function()
    add_note(vim.api.nvim_get_current_buf())
  end, { desc = "Add sticky note at current line" })

  vim.api.nvim_create_user_command("NN", function()
    drop_note(vim.api.nvim_get_current_buf())
  end, { desc = "Remove sticky note at current line" })

  vim.api.nvim_create_augroup("StickyNotes", { clear = true })
  vim.api.nvim_create_autocmd("BufEnter", {
    group = "StickyNotes",
    callback = function(ev)
      render(ev.buf)
    end,
  })
end

return M
