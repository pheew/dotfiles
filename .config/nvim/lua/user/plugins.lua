local packer = require 'lib.packer-init'

packer.startup(function(use)
	use { 'wbthomason/packer.nvim' } -- Let packer manage itself
   	use { 'tpope/vim-sleuth' } -- Indent autodetection with editorconfig support
   	use { 'tpope/vim-surround' }

	use { 
		'lambdalisue/fern.vim',
		requires = {
			'lambdalisue/nerdfont.vim',
			'lambdalisue/fern-renderer-nerdfont.vim',
			'lambdalisue/fern-hijack.vim'
		},
		setup = function() 
			vim.cmd [[ 
				let g:fern#renderer = "nerdfont"
			]]
		end
	}

	use { 
		'lifepillar/vim-solarized8' ,
		setup = function() 
			vim.g.solarized_diffmode = 'high'
			vim.cmd [[ 
				autocmd vimenter * ++nested colorscheme solarized8
				colorscheme solarized8 
			]]
		end
	}

	use {
		 'tpope/vim-fugitive',
		 requires = 'tpope/vim-rhubarb',
	    --cmd = 'G',
	}

	use {
	    'nvim-telescope/telescope.nvim',
	    requires = {
	      { 'nvim-lua/plenary.nvim' },
	      { 'kyazdani42/nvim-web-devicons' },
	      { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
	      { 'nvim-telescope/telescope-live-grep-raw.nvim' },
	    },
	    config = function()
	      require('user.plugins.telescope')
	    end
	}
end)
