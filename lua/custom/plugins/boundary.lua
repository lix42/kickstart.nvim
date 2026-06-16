-- boundary.nvim - visualize React Server Component boundaries.
-- Shows a `use client` marker as virtual text next to JSX usages of client
-- components, so you can see which parts of a tree cross the server/client
-- boundary. Lives in lua/custom/plugins/ so it survives upstream syncs without
-- conflicts.
--
-- The repo has no main/master branch; the author publishes to the `release`
-- branch (currently tag v0.1.1), so we pin to it.
vim.pack.add { { src = 'https://github.com/kenzo-pj/boundary.nvim', version = 'release' } }

require('boundary').setup {
  auto = true, -- auto-refresh markers on BufEnter/BufWritePost/TextChanged/InsertLeave
}

-- With `auto = true` markers refresh on their own; `:BoundaryRefresh` re-scans
-- the current buffer manually if an external change is missed.
