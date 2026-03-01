return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  lazy = false,
  ---@module 'neo-tree'
  ---@type neotree.Config
  opts = {
    window = {
      mappings = {
        ["l"] = {
          function(state)
            local node = state.tree:get_node()
            if node.type == "directory" then
              if not node:is_expanded() then
                require("neo-tree.sources.filesystem.commands").open(state)
              end
            else
              require("neo-tree.sources.filesystem.commands").open(state)
            end
          end,
          desc = "open or expand",
        },
        ["h"] = {
          function(state)
            local node = state.tree:get_node()
            if node.type == "directory" and node:is_expanded() then
              require("neo-tree.sources.filesystem.commands").close_node(state)
            else
              local parent_id = node:get_parent_id()
              if parent_id then
                local parent = state.tree:get_node(parent_id)
                if parent and parent:is_expanded() then
                  require("neo-tree.sources.filesystem.commands").close_node(state)
                  state.tree:navigate_to_node(parent)
                end
              end
            end
          end,
          desc = "fold or go to parent",
        },
      },
    },
  },
}
