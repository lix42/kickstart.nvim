-- Standalone option overrides (kept here to stay conflict-free with upstream).

-- switchbuf: when a jump/split command targets a buffer that is already
-- visible in another window, reuse that window instead of opening a duplicate.
-- 'useopen' adds the reuse behavior; 'uselast' (Neovim's default) is preserved
-- so quickfix jumps still land in the previously-used window.
-- NOTE: this is honored by :sb*/:sbuffer and quickfix/loclist jumps, NOT by
-- plain :b or the Telescope buffer picker (,,).
vim.o.switchbuf = 'useopen,uselast'
