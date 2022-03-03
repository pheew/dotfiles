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

	use {
	  'L3MON4D3/LuaSnip',
	  config = function()
	    require('user.plugins.luasnip')
	  end
	}

	use {
	    'nvim-treesitter/nvim-treesitter',
	    run = ':TSUpdate',
	    requires = {
	      'nvim-treesitter/playground',
	      'nvim-treesitter/nvim-treesitter-textobjects',
	      'lewis6991/spellsitter.nvim',
	      'JoosepAlviste/nvim-ts-context-commentstring',
	    },
	    config = function()
	      require('user.plugins.treesitter')
	      require('spellsitter').setup()
	    end
	}

	use {
	    'neovim/nvim-lspconfig',
	    requires = {
	    'hrsh7th/nvim-cmp',
	      'b0o/schemastore.nvim',
	      --'folke/lsp-colors.nvim',
	      'weilbith/nvim-code-action-menu',
	    },
	    config = function ()
	      require('user.plugins.lspconfig')
	    end
	}

	 use {
	    'hrsh7th/nvim-cmp',
	    requires = {
	      'hrsh7th/cmp-nvim-lsp',
	      'hrsh7th/cmp-buffer',
	      'saadparwaiz1/cmp_luasnip',
	      'L3MON4D3/LuaSnip',
	      'jessarcher/cmp-path',
	      'hrsh7th/cmp-nvim-lua',
	      'onsails/lspkind-nvim',
	      'hrsh7th/cmp-nvim-lsp-signature-help',
	    },
	    config = function()
	      require('user.plugins.cmp')
	    end
	  }

         use {
            'nvim-lualine/lualine.nvim',
            requires = { 'kyazdani42/nvim-web-devicons', opt = true },
            config = function() 
               require('user.plugins.lualine')
            end
         }
end)
