-- macOS-style text navigation in insert mode (Ghostty).
--
-- These are mapped to the keys Ghostty actually *sends*, which are not the
-- chords you press. Captured from the terminal:
--
--   Opt+Left    -> ESC b       (readline word-back)  => <M-b>
--   Opt+Right   -> ESC f       (readline word-fwd)   => <M-f>
--   Opt+Delete  -> ESC DEL                           => <M-BS>
--   Cmd+Delete  -> 0x15        (Ctrl-U)              => <C-u>, already native
--   Cmd+Left    -> ESC O H     => <Home>     \
--   Cmd+Right   -> ESC O F     => <End>       | via keybind = super+arrow_*
--   Cmd+Up      -> ESC [ 1;5H  => <C-Home>    | in the Ghostty config; its
--   Cmd+Down    -> ESC [ 1;5F  => <C-End>    /  defaults send Ctrl-A/Ctrl-E
--                                               and eat Cmd+Up/Down entirely.
--
-- No <M-Left>/<M-Right>/<D-...> mappings here: those key codes never reach
-- Neovim from this terminal, so mapping them is dead code.
--
-- Ctrl+Left/Right are deliberately absent too -- macOS Mission Control grabs
-- them system-wide for "Move left/right a space", so the terminal never sees
-- them. Neovim's built-in i_<C-Left>/i_<C-Right> are unreachable as a result.

-- [[ Word motion ]]
-- Neovim's built-in i_<C-Left>/i_<C-Right> move "like b/w", which cross line
-- boundaries -- so Opt+Right on the last word jumps to the next line. macOS
-- stops at the line edge instead, which is what this implements:
--   forward  -> just past the end of the current/next word
--   backward -> the start of the current/previous word
-- Never leaves the current line, by construction.

--- Is `ch` a keyword character? Uses Vim's 'iskeyword', so it follows the
--- filetype and handles multibyte characters correctly.
local function is_word(ch) return vim.fn.match(ch, '\\k') >= 0 end

--- @param step -1|1 direction to move
local function word_motion(step)
  return function()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    -- Split into characters (not bytes) so multibyte text can't land the
    -- cursor mid-character.
    local chars = vim.fn.split(vim.api.nvim_get_current_line(), '\\zs')

    -- offsets[i] = byte column just before character i; the extra trailing
    -- entry is end-of-line.
    local offsets, acc = {}, 0
    for i = 1, #chars + 1 do
      offsets[i] = acc
      acc = acc + (chars[i] and #chars[i] or 0)
    end

    -- Current character index (the cursor always sits on a boundary).
    local idx = #chars + 1
    for i = 1, #chars + 1 do
      if offsets[i] >= col then
        idx = i
        break
      end
    end

    -- The character this step would move over: ahead of the cursor going
    -- forward, behind it going backward.
    local function peek(i) return chars[step > 0 and i or i - 1] end

    -- Skip separators, then skip the word itself. Both loops stop at the line
    -- edge, so a trailing word leaves the cursor at end of line rather than
    -- wrapping.
    while peek(idx) and not is_word(peek(idx)) do
      idx = idx + step
    end
    while peek(idx) and is_word(peek(idx)) do
      idx = idx + step
    end

    vim.api.nvim_win_set_cursor(0, { row, offsets[idx] })
  end
end

vim.keymap.set('i', '<M-f>', word_motion(1), { desc = 'Word forward, stops at line end (Opt+Right)' })
vim.keymap.set('i', '<M-b>', word_motion(-1), { desc = 'Word back, stops at line start (Opt+Left)' })

-- Line start. `^` is first non-blank, which is what you want in indented code;
-- drop this mapping if you'd rather land in column 0. <C-o> runs a single
-- normal-mode command and returns to insert.
vim.keymap.set('i', '<Home>', '<C-o>^', { desc = 'Line start, first non-blank (Cmd+Left)' })

-- Delete word back. <C-w> does this natively; this is the macOS key position.
vim.keymap.set('i', '<M-BS>', '<C-w>', { desc = 'Delete word back (Opt+Delete)' })

-- Not mapped, because they already do the right thing natively:
--   <End>     line end        (Cmd+Right)
--   <C-Home>  file start      (Cmd+Up)
--   <C-End>   file end        (Cmd+Down)
--   <C-u>     delete to line start (Cmd+Delete)
