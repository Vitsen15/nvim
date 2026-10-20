-- Clipboard for tmux, SSH and herdr sessions.
-- Copy: Wayland clipboard (when available) plus OSC 52 to the terminal.
-- Paste: Wayland clipboard or tmux buffer, else this Neovim's last copy.
-- Paste never queries the terminal over OSC 52: many terminals don't answer,
-- and each unanswered query blocks paste for ten seconds. To bring in text
-- from the host, use the terminal's own paste.
local M = {}

local function proc_lines(pid, file)
  local ok, lines = pcall(vim.fn.readfile, "/proc/" .. pid .. "/" .. file)
  return ok and lines or {}
end

local function proc_ppid(pid)
  for _, line in ipairs(proc_lines(pid, "status")) do
    local ppid = line:match("^PPid:%s+(%d+)")
    if ppid then
      return tonumber(ppid)
    end
  end
end

local function ancestor_process_named(name)
  local pid = vim.fn.getpid()

  for _ = 1, 16 do
    local ppid = proc_ppid(pid)
    if not ppid or ppid <= 1 then
      return false
    end

    local comm = proc_lines(ppid, "comm")[1] or ""
    if comm:find(name, 1, true) then
      return true
    end

    pid = ppid
  end

  return false
end

function M.setup()
  local in_tmux = vim.env.TMUX ~= nil
  local in_ssh = vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil
  local in_herdr = vim.env.HERDR_PANE_ID ~= nil or ancestor_process_named("herdr")

  if not (in_tmux or in_ssh or in_herdr) then
    return
  end

  local osc52 = require("vim.ui.clipboard.osc52")
  local has_wayland = vim.env.WAYLAND_DISPLAY ~= nil
    and vim.fn.executable("wl-copy") == 1
    and vim.fn.executable("wl-paste") == 1

  local has_tmux = in_tmux and vim.fn.executable("tmux") == 1
  local last_copy = {}

  -- Cache tmux's set-clipboard setting instead of asking on every yank.
  -- Refreshed on FocusGained (needs tmux `focus-events on`).
  local tmux_export
  local function tmux_export_enabled()
    if tmux_export == nil then
      local setting = vim.fn.systemlist({ "tmux", "show-options", "-sv", "set-clipboard" })
      if vim.v.shell_error == 0 then
        tmux_export = setting[1] == "on" or setting[1] == "external"
      end
    end
    return tmux_export == true
  end

  if has_tmux then
    vim.api.nvim_create_autocmd("FocusGained", {
      group = vim.api.nvim_create_augroup("omarchy_remote_clipboard", { clear = true }),
      callback = function()
        tmux_export = nil
      end,
    })
  end

  local function copy(register)
    local emit = osc52.copy(register)

    return function(lines, regtype)
      last_copy[register] = { vim.deepcopy(lines), regtype }

      if has_wayland then
        local cmd = { "wl-copy", "--sensitive", "--type", "text/plain" }
        if register == "*" then
          cmd[#cmd + 1] = "--primary"
        end
        vim.fn.system(cmd, lines)
      end

      if vim.g.omarchy_remote_clipboard_osc52 ~= false then
        if has_tmux and register == "+" then
          -- tmux can't hold an empty buffer. Mark the current one as cleared
          -- (instead of deleting it) so paste returns nothing until the next copy.
          if #lines == 0 or (#lines == 1 and lines[1] == "") then
            vim.fn.system({ "tmux", "set-option", "-sF", "@omarchy-nvim-cleared-buffer", "#{buffer_name}" })
            return
          end
          -- Hand the text to tmux: large OSC 52 printed from the pane exceeds
          -- tmux's input limit. -w forwards it to the terminal but ignores
          -- set-clipboard, so add it only when that setting allows. -w reaches
          -- only the most recently active tmux client.
          local cmd = { "tmux", "load-buffer" }
          if tmux_export_enabled() then
            cmd[#cmd + 1] = "-w"
          end
          cmd[#cmd + 1] = "-"
          vim.fn.system(cmd, lines)
          if vim.v.shell_error == 0 then
            return
          end
        end
        emit(lines)
      end
    end
  end

  local function paste(register)
    return function()
      local cmd
      -- The tmux buffer is shared by all Neovim instances. Over SSH, prefer it
      -- to the remote host's own clipboard.
      if has_tmux and register == "+" and (in_ssh or not has_wayland)
        and vim.g.omarchy_remote_clipboard_osc52 ~= false then
        local buffers = vim.fn.systemlist({ "tmux", "display-message", "-p",
          "#{buffer_name}\n#{@omarchy-nvim-cleared-buffer}" })
        if vim.v.shell_error ~= 0 then
          return vim.deepcopy(last_copy[register] or { {}, "v" })
        end
        if not buffers[1] or buffers[1] == "" or buffers[1] == buffers[2] then
          return { {}, "v" }
        end
        -- Read by name, so a copy made in between can't swap the content.
        cmd = { "tmux", "save-buffer", "-b", buffers[1], "-" }
      elseif has_wayland then
        cmd = { "wl-paste", "--no-newline" }
        if register == "*" then
          cmd[#cmd + 1] = "--primary"
        end
      end

      if cmd then
        local lines = vim.fn.systemlist(cmd, "", 1)
        if vim.v.shell_error == 0 then
          -- Our own last copy: keep its register type (linewise, blockwise).
          if last_copy[register] and vim.deep_equal(lines, last_copy[register][1]) then
            return vim.deepcopy(last_copy[register])
          end
          return lines
        end
      end

      return vim.deepcopy(last_copy[register] or { {}, "v" })
    end
  end

  vim.g.clipboard = {
    name = "OmarchyRemoteClipboard",
    copy = { ["+"] = copy("+"), ["*"] = copy("*") },
    paste = { ["+"] = paste("+"), ["*"] = paste("*") },
    cache_enabled = 0,
  }

  -- LazyVim turns off unnamedplus over SSH; this provider handles SSH, so turn
  -- it back on. Opt out with vim.g.omarchy_remote_clipboard_sync = false.
  if vim.g.omarchy_remote_clipboard_sync ~= false then
    vim.opt.clipboard:append("unnamedplus")
  end
end

return M
