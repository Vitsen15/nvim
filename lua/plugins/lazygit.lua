return {
	"folke/snacks.nvim",
	opts = {
		lazygit = {
			win = {
				keys = {
					hide = {
						"q",
						function(self)
							self:hide()
							if package.loaded["neo-tree.sources.git_status"] then
								require("neo-tree.sources.git_status").refresh()
							end
						end,
						mode = "t",
						desc = "Hide lazygit (preserves state)",
					},
				},
			},
		},
	},
}
