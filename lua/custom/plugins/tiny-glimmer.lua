-- tiny-glimmer.nvim - smooth animations for text operations (yank, paste,
-- search, undo/redo). Lives in lua/custom/plugins/ so it survives upstream
-- syncs without conflicts.
--
-- Note: the module name is `tiny-glimmer` (hyphen), matching the repo.
vim.pack.add { 'https://github.com/rachartier/tiny-glimmer.nvim' }

require('tiny-glimmer').setup {
  overwrite = {
    -- Animate search jumps; auto_map (on by default) remaps n/N/*/# for us,
    -- so no manual key wiring is needed with our eager vim.pack load.
    search = { enabled = true }, -- search already uses the pulse animation by default
    -- Use pulse everywhere for a consistent feel (yank/paste default to fade/reverse_fade).
    yank = { default_animation = 'pulse' },
    paste = { default_animation = 'pulse' },
  },
}

-- tiny-glimmer registers its own TextYankPost animation (yank overwrite is on
-- by default). Kickstart also highlights yanks via vim.hl.on_yank() in its
-- `kickstart-highlight-yank` augroup (init.lua Section 1), so both would fire
-- and double up. Re-declaring that augroup with clear=true drops kickstart's
-- autocmd, leaving only the glimmer animation. We do it here -- this file loads
-- after Section 1 -- instead of editing init.lua, to stay conflict-free with
-- upstream. (If upstream ever renames the augroup this becomes a harmless
-- no-op: the only symptom would be the old flash returning alongside the glimmer.)
vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true })
