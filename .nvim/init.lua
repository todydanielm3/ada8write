-- init.lua - Configuração do NeoVim para escrita
-- Local: book/.nvim/init.lua
-- Para usar: ./scripts/nvimw.sh ou nvim -u book/.nvim/init.lua

-- ============================================================================
-- CONFIGURAÇÕES BÁSICAS
-- ============================================================================

-- Líder
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Opções gerais
local opt = vim.opt

-- Interface
opt.number = true              -- Números de linha
opt.relativenumber = true      -- Números relativos
opt.signcolumn = 'yes'         -- Coluna de sinais sempre visível
opt.cursorline = true          -- Destaca linha atual
opt.wrap = true                -- Quebra de linha visual
opt.linebreak = true           -- Quebra em palavras, não no meio
opt.breakindent = true         -- Mantém indentação em quebras
opt.showbreak = '↪ '           -- Indicador de quebra de linha

-- Escrita
opt.spell = true               -- Corretor ortográfico
opt.spelllang = 'pt_br,en'     -- Idiomas
opt.spellcapcheck = 'cap'      -- Verifica maiúsculas
opt.conceallevel = 2           -- Oculta marcação Markdown (opcional)
opt.textwidth = 80             -- Quebra automática na coluna 80
opt.formatoptions:append('t') -- Auto-wrap ao digitar

-- Busca
opt.ignorecase = true          -- Ignora maiúsculas na busca
opt.smartcase = true           -- Exceto se buscar com maiúscula

-- Arquivos
opt.undofile = true            -- Histórico persistente
opt.backup = false             -- Sem backups automáticos
opt.swapfile = false           -- Sem swap files

-- Interface limpa
opt.showmode = false           -- Não mostra modo (INSERT, etc)
opt.laststatus = 2             -- Barra de status sempre
opt.cmdheight = 1              -- Altura da linha de comando

-- Indentação (para estrutura de notas)
opt.expandtab = true           -- Espaços em vez de tabs
opt.shiftwidth = 2             -- Tamanho da indentação
opt.tabstop = 2                -- Largura do tab

-- Splits
opt.splitright = true          -- Split vertical à direita
opt.splitbelow = true          -- Split horizontal abaixo

-- Mouse e clipboard
opt.mouse = 'a'                -- Mouse habilitado
opt.clipboard = 'unnamedplus'  -- Usa clipboard do sistema

-- Aparência
opt.termguicolors = true       -- Cores 24-bit
opt.background = 'dark'        -- Tema escuro

-- ============================================================================
-- PLUGIN MANAGER - lazy.nvim
-- ============================================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- PLUGINS
-- ============================================================================

require("lazy").setup({
  -- Tema
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        transparent = false,
        styles = {
          sidebars = "dark",
          floats = "dark",
        },
      })
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  -- Modo Zen
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    keys = {
      { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" },
    },
    opts = {
      window = {
        width = 90,
        options = {
          number = false,
          relativenumber = false,
          signcolumn = "no",
          cursorline = false,
        },
      },
      plugins = {
        options = {
          enabled = true,
          ruler = false,
          showcmd = false,
        },
        gitsigns = { enabled = false },
      },
    },
  },

  -- Telescope removido (incompatível com versão antiga do NeoVim)
  -- Use <leader>/ para buscar com grep nativo

  -- Which-key - Mostra atalhos
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = {
        spelling = {
          enabled = true,
          suggestions = 20,
        },
      },
    },
  },

  -- Neo-tree - Explorador de arquivos
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
      { "<leader>e", "<cmd>Neotree toggle left<cr>", desc = "Explorador" },
    },
    opts = {
      close_if_last_window = false,
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
        follow_current_file = { enabled = true },
      },
      window = {
        position = "left",
        width = 30,
      },
    },
  },

  -- Markdown extras
  {
    "preservim/vim-markdown",
    ft = "markdown",
    config = function()
      vim.g.vim_markdown_folding_disabled = 1
      vim.g.vim_markdown_frontmatter = 1
      vim.g.vim_markdown_new_list_item_indent = 0
      vim.g.vim_markdown_auto_insert_bullets = 1
    end,
  },
})

-- ============================================================================
-- KEYMAPS PERSONALIZADOS
-- ============================================================================

local keymap = vim.keymap.set

-- ============================================================================
-- MENU PRINCIPAL - Janela flutuante com opções
-- ============================================================================

-- Função para criar janela flutuante com menu
local function show_menu()
  local menu_items = {
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "PROJETO DE ESCRITA - MENU RÁPIDO",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "",
    "NAVEGAÇÃO",
    "  <leader>e  → Explorador (Neo-tree)",
    "  <leader>n  → Notas",
    "  <leader>c  → Listar Personagens",
    "  <leader>s  → Cenas",
    "  <leader>p  → Capítulos",
    "",
    "CRIAR NOVO ARQUIVO",
    "  <leader>en → Nova Nota",
    "  <leader>ep → Novo Personagem",
    "  <leader>ec → Nova Cena",
    "  <leader>ek → Novo Capítulo",
    "",
    "ASSISTENTE IA",
    "  <leader>al → Buscar personagem",
    "  <leader>ac → Consistência",
    "  <leader>ar → Ritmo narrativo",
    "  <leader>at → Temas",
    "  <leader>ap → Repetições",
    "  <leader>am → Atualizar memória",
    "  <leader>aq → Pergunta criativa",
    "  <leader>as → Analisar cena atual",
    "  <leader>ai → Status do projeto",
    "  <leader>ad → Dashboard métricas",
    "",
    "ORTOGRAFIA",
    "  ]s         → Próximo erro",
    "  [s         → Erro anterior",
    "  z=         → Ver sugestões",
    "  <leader>sf → Corrigir palavra",
    "  <leader>sF → Corrigir TUDO",
    "",
    "ARQUIVO",
    "  <leader>w  → Salvar",
    "  <leader>q  → Fechar",
    "  <leader>z  → Zen Mode",
    "",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
  }
  
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, menu_items)
  
  local width = 50
  local height = #menu_items
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)
  
  local opts = {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
    title = " Menu Rápido ",
    title_pos = "center",
  }
  
  vim.api.nvim_open_win(buf, true, opts)
  vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
  vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf })
  vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', { buffer = buf })
end

-- Atalho para mostrar menu
keymap('n', '<leader>?', show_menu, { desc = 'Mostrar Menu' })

-- ============================================================================
-- FUNÇÃO: Criar novo arquivo com nome em pop-up
-- ============================================================================

local function book_ext()
  -- Le a extensao padrao de book.config (fallback: txt)
  local ok, lines = pcall(vim.fn.readfile, vim.fn.getcwd() .. '/book.config')
  if ok and lines then
    for _, l in ipairs(lines) do
      local v = l:match('^BOOK_EXT="?([%w]+)"?')
      if v then return v end
    end
  end
  return 'txt'
end

local function create_new_file(dir_path)
  local input = vim.fn.input('Nome do arquivo (sem extensão): ')
  if input == '' then
    print('Cancelado')
    return
  end

  local file_path = dir_path .. input .. '.' .. book_ext()

  -- Verifica se já existe
  if vim.fn.filereadable(file_path) == 1 then
    print('Arquivo já existe!')
    return
  end

  -- Cria o arquivo VAZIO (sem template) e abre
  vim.cmd('edit ' .. vim.fn.fnameescape(file_path))
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { '' })

  print('Arquivo criado: ' .. file_path)
end

-- ============================================================================
-- FUNÇÃO: Listar e abrir personagens
-- ============================================================================

local function list_personagens()
  local dir = '01_personagens'
  local personagens = {}
  
  -- Lista todos os arquivos de texto (.txt e .md)
  for _, pattern in ipairs({ '/*.txt', '/*.md' }) do
    for file in vim.fn.glob(dir .. pattern):gmatch('[^\n]+') do
      local name = vim.fn.fnamemodify(file, ':t:r')  -- Nome sem extensão
      table.insert(personagens, { name = name, file = file })
    end
  end
  
  if #personagens == 0 then
    print('Nenhum personagem encontrado')
    return
  end
  
  -- Cria buffer com lista
  local buf = vim.api.nvim_create_buf(false, true)
  local lines = { 'PERSONAGENS', '════════════════' }
  
  for i, char in ipairs(personagens) do
    table.insert(lines, string.format('%d. %s', i, char.name))
  end
  
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  
  -- Abre em janela flutuante
  local width = 30
  local height = #lines + 2
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)
  
  local opts = {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    border = 'rounded',
    title = ' Personagens ',
    title_pos = 'center',
  }
  
  local win = vim.api.nvim_open_win(buf, true, opts)
  vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
  
  -- Atalhos na janela
  for i, char in ipairs(personagens) do
    vim.keymap.set('n', tostring(i), function()
      vim.api.nvim_win_close(win, true)
      vim.cmd('edit ' .. char.file)
    end, { buffer = buf })
  end
  
  vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf })
  vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', { buffer = buf })
end

-- ============================================================================
-- FUNÇÃO: Abrir arquivo paralelo com sincronização de linhas
-- ============================================================================

local sync_buffers = {}  -- Rastreia pares sincronizados

local function open_reader_sync(file_path)
  -- Obtém o buffer atual (arquivo de escrita)
  local write_buf = vim.api.nvim_get_current_buf()
  local write_win = vim.api.nvim_get_current_win()
  
  -- Abre arquivo de leitura em split à esquerda
  vim.cmd('vsplit')
  vim.cmd('edit ' .. file_path)
  
  local read_buf = vim.api.nvim_get_current_buf()
  local read_win = vim.api.nvim_get_current_win()
  
  -- Volta para a janela de escrita
  vim.api.nvim_set_current_win(write_win)
  
  -- Registra o par sincronizado
  sync_buffers[write_buf] = {
    read_buf = read_buf,
    read_win = read_win,
  }
  
  print("Leitor sincronizado! Posição acompanha sua escrita.")
  
  -- Autocomando para sincronizar cursor/linhas
  vim.api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI'}, {
    buffer = write_buf,
    callback = function()
      if sync_buffers[write_buf] then
        local line = vim.api.nvim_win_get_cursor(write_win)[1]
        local read_win = sync_buffers[write_buf].read_win
        
        -- Verifica se a janela ainda existe
        if vim.api.nvim_win_is_valid(read_win) then
          -- Verifica se a linha existe no buffer
          local read_buf = vim.api.nvim_win_get_buf(read_win)
          local line_count = vim.api.nvim_buf_line_count(read_buf)
          
          if line <= line_count then
            vim.api.nvim_win_set_cursor(read_win, {line, 0})
          end
        end
      end
    end,
  })
end

-- ============================================================================
-- CORREÇÃO AUTOMÁTICA DE ORTOGRAFIA
-- ============================================================================

local function spell_fix_all()
  -- Salva posição atual
  local save_cursor = vim.api.nvim_win_get_cursor(0)
  vim.cmd('normal! gg')

  local fixed_count = 0
  local max_iterations = 500  -- segurança contra loop infinito

  for _ = 1, max_iterations do
    -- Busca próximo erro ortográfico
    local pos = vim.fn.searchpos('[^]', 'W')
    if pos[1] == 0 and pos[2] == 0 then break end

    local word = vim.fn.expand('<cword>')
    local suggestions = vim.fn.spellsuggest(word, 1)

    if suggestions and #suggestions > 0 then
      -- Usa 1z= para aplicar primeira sugestão automaticamente
      vim.cmd('normal! 1z=')
      fixed_count = fixed_count + 1
    end
  end

  -- Restaura posição
  pcall(vim.api.nvim_win_set_cursor, 0, save_cursor)
  print(string.format('Corrigidas %d palavras', fixed_count))
end

-- Versão simplificada: corrige palavra sob cursor
local function spell_fix_word()
  local word = vim.fn.expand('<cword>')
  local suggestions = vim.fn.spellsuggest(word, 1)
  
  if suggestions and #suggestions > 0 then
    vim.cmd('normal! "_dw')
    vim.cmd('normal! i' .. suggestions[1])
    print('Corrigido: ' .. word .. ' → ' .. suggestions[1])
  else
    print('Sem sugestões para: ' .. word)
  end
end

-- ============================================================================
-- NAVEGAÇÃO E ATALHOS PRINCIPAIS
-- ============================================================================

-- Navegação entre pastas do projeto
keymap('n', '<leader>e', '<cmd>Neotree toggle<cr>', { desc = 'Explorador' })
keymap('n', '<leader>n', '<cmd>e 00_notas/<cr>', { desc = 'Abrir Notas' })
keymap('n', '<leader>c', function() list_personagens() end, { desc = 'Listar Personagens' })
keymap('n', '<leader>C', '<cmd>e 01_personagens/<cr>', { desc = 'Explorador Personagens' })
keymap('n', '<leader>s', '<cmd>e 02_cenas/<cr>', { desc = 'Abrir Cenas' })
keymap('n', '<leader>p', '<cmd>e 03_capitulos/<cr>', { desc = 'Abrir Capítulos' })

-- ============================================================================
-- MODO LEITURA & ESCRITA (SINCRONIZADO)
-- ============================================================================

-- Comando para abrir arquivo de referência sincronizado
vim.api.nvim_create_user_command('ReadSync', function(opts)
  local file = opts.args ~= '' and opts.args or vim.fn.input('Arquivo para ler: ', '', 'file')
  if file ~= '' then
    open_reader_sync(file)
  end
end, { nargs = '?' })

-- Atalho rápido
keymap('n', '<leader>rs', ':ReadSync ', { desc = 'Ler arquivo sincronizado' })

-- ============================================================================
-- CRIAR NOVO ARQUIVO - Com pop-up
-- ============================================================================

keymap('n', '<leader>en', function() create_new_file('00_notas/') end, { desc = 'Nova Nota' })
keymap('n', '<leader>ep', function() create_new_file('01_personagens/') end, { desc = 'Novo Personagem' })
keymap('n', '<leader>ec', function() create_new_file('02_cenas/') end, { desc = 'Nova Cena' })
keymap('n', '<leader>ek', function() create_new_file('03_capitulos/') end, { desc = 'Novo Capítulo' })

-- ============================================================================
-- SALVAMENTO E FECHAMENTO
-- ============================================================================

-- Salvamento rápido
keymap('n', '<leader>w', '<cmd>w<cr>', { desc = 'Salvar' })
keymap('n', '<leader>q', '<cmd>q<cr>', { desc = 'Fechar' })
keymap('n', '<leader>qa', '<cmd>qa<cr>', { desc = 'Fechar Tudo' })

-- ============================================================================
-- BUSCA & EDIÇÃO
-- ============================================================================

-- Busca nativa com /: use Ctrl+N/Ctrl+P para navegação
-- keymap('n', '<leader>/', '<cmd>Telescope live_grep<cr>', { desc = 'Buscar no projeto' })  -- Removido

-- ============================================================================
-- CORREÇÃO ORTOGRÁFICA
-- ============================================================================

-- Navegar entre erros ortográficos (vim spell nativo)
keymap('n', ']s', ']s', { desc = 'Próximo erro ortográfico' })
keymap('n', '[s', '[s', { desc = 'Erro ortográfico anterior' })
-- z= já é nativo do vim para sugestões de ortografia

-- Adicionar palavra ao dicionário
keymap('n', '<leader>sa', 'zg', { desc = 'Adicionar ao dicionário' })

-- Remover palavra do dicionário
keymap('n', '<leader>sr', 'zw', { desc = 'Remover do dicionário' })

-- CORREÇÃO AUTOMÁTICA
-- Corrige a palavra sob o cursor
keymap('n', '<leader>sf', function() spell_fix_word() end, { desc = 'Corrigir palavra' })

-- Corrige TODAS as palavras erradas no arquivo
keymap('n', '<leader>sF', function() spell_fix_all() end, { desc = 'Corrigir TUDO' })

-- ============================================================================
-- ANÁLISE & CONTAGEM
-- ============================================================================

-- Contagem de palavras
keymap('n', '<leader>wc', function()
  local words = vim.fn.wordcount().words
  print("Palavras: " .. words)
end, { desc = 'Contar palavras' })

-- Contagem de linhas
keymap('n', '<leader>wl', function()
  local lines = vim.api.nvim_buf_line_count(0)
  print("Linhas: " .. lines)
end, { desc = 'Contar linhas' })

-- ============================================================================
-- SPLITS
-- ============================================================================

keymap('n', '<leader>sp', '<cmd>split<cr>', { desc = 'Split horizontal' })
keymap('n', '<leader>vp', '<cmd>vsplit<cr>', { desc = 'Split vertical' })

-- ============================================================================
-- NAVEGAÇÃO EM LINHAS QUEBRADAS & OUTROS
-- ============================================================================

-- Navegação em linhas quebradas
keymap('n', 'j', 'gj', { desc = 'Linha visual abaixo' })
keymap('n', 'k', 'gk', { desc = 'Linha visual acima' })

-- Limpa highlight da busca
keymap('n', '<Esc>', '<cmd>nohlsearch<cr>', { desc = 'Limpar busca' })

-- ============================================================================
-- AUTOCOMANDOS
-- ============================================================================

local augroup = vim.api.nvim_create_augroup('WritingMode', { clear = true })

-- Markdown: ajustes específicos
vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = 'markdown',
  callback = function()
    -- Ativa spell em TUDO, inclusive em blocos indentados
    vim.opt_local.spell = true
    vim.opt_local.spelllang = 'pt_br,en'
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    
    -- Desabilita sintaxe de código para ativar spell em indentações
    -- Isso força spell a verificar TODO o markdown
    vim.cmd("setlocal conceallevel=0")
    vim.cmd("syntax off | syntax on")  -- Recarrega syntax
  end,
})

-- Destaca linhas muito longas (opcional - avisar se passar de 100 chars)
vim.api.nvim_create_autocmd('BufEnter', {
  group = augroup,
  pattern = { '*.md', '*.txt' },
  callback = function()
    vim.wo.colorcolumn = ''  -- Sem régua visual
  end,
})

-- Arquivos .txt sao o formato padrao de escrita: mesmo conforto do markdown
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  group = augroup,
  pattern = '*.txt',
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = 'pt_br,en'
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.conceallevel = 0
  end,
})

-- ============================================================================
-- COMANDO PARA BAIXAR DICIONÁRIOS
-- ============================================================================

vim.api.nvim_create_user_command('SpellInstall', function()
  local spell_dir = vim.fn.stdpath("config") .. "/spell"
  if vim.fn.isdirectory(spell_dir) == 0 then
    vim.fn.mkdir(spell_dir, "p")
    print("Pasta de spell criada: " .. spell_dir)
  end
  
  -- Comando para baixar dicionários
  vim.cmd([[
    cd spell
    !curl -L https://ftp.nluug.nl/vim/runtime/spell/pt.utf-8.spl -o pt.utf-8.spl
    !curl -L https://ftp.nluug.nl/vim/runtime/spell/pt.utf-8.sug -o pt.utf-8.sug
    !curl -L https://ftp.nluug.nl/vim/runtime/spell/en.utf-8.spl -o en.utf-8.spl
    !curl -L https://ftp.nluug.nl/vim/runtime/spell/en.utf-8.sug -o en.utf-8.sug
    cd ..
  ]])
  
  print("Dicionários baixados!")
end, {})

-- Comando para forçar rechecagem de spell
vim.api.nvim_create_user_command('SpellCheck', function()
  vim.cmd("set spell!")
  vim.cmd("set spell")
  print("Spell rechecado!")
end, {})

-- Comando para listar personagens
vim.api.nvim_create_user_command('Personagens', list_personagens, { 
  desc = 'Listar todos os personagens' 
})

-- Comandos de Correção Automática
vim.api.nvim_create_user_command('SpellFix', spell_fix_word, { 
  desc = 'Corrigir palavra sob o cursor' 
})

vim.api.nvim_create_user_command('SpellFixAll', spell_fix_all, { 
  desc = 'Corrigir TODAS as palavras erradas' 
})


-- ============================================================================
-- ASSISTENTE DE IA - Integração com narrative_ai.py
-- ============================================================================

local ai_script = vim.fn.getcwd() .. '/.ai_assistant/narrative_ai.py'
local metrics_script = vim.fn.getcwd() .. '/.ai_assistant/metrics.py'

-- Função genérica para rodar comando de IA e mostrar resultado em float
local function ai_run(cmd_args, title)
  local full_cmd = 'python3 ' .. ai_script .. ' ' .. cmd_args
  local output = vim.fn.systemlist(full_cmd)

  -- Criar buffer com resultado
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)

  -- Calcular tamanho da janela
  local max_width = math.min(80, vim.o.columns - 10)
  local max_height = math.min(#output + 2, vim.o.lines - 6)
  local col = math.floor((vim.o.columns - max_width) / 2)
  local row = math.floor((vim.o.lines - max_height) / 2)

  local opts = {
    relative = 'editor',
    width = max_width,
    height = max_height,
    col = col,
    row = row,
    style = 'minimal',
    border = 'rounded',
    title = ' ' .. (title or 'IA') .. ' ',
    title_pos = 'center',
  }

  vim.api.nvim_open_win(buf, true, opts)
  vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
  vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf })
  vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', { buffer = buf })
end

-- Busca rápida de personagem (sem API, instantâneo)
local function character_quick_lookup()
  local name = vim.fn.input('Personagem: ')
  if name == '' then return end
  ai_run('character ' .. name, name)
end

-- Análise da cena atual
local function analyze_current_scene()
  local file = vim.fn.expand('%:t')
  if file == '' then
    print('Nenhum arquivo aberto')
    return
  end
  print('Analisando cena: ' .. file .. '...')
  ai_run('scene ' .. file, 'Análise: ' .. file)
end

-- Métricas rápidas
local function show_metrics()
  local full_cmd = 'python3 ' .. metrics_script
  local output = vim.fn.systemlist(full_cmd)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)

  local max_width = math.min(70, vim.o.columns - 10)
  local max_height = math.min(#output + 2, vim.o.lines - 6)
  local col = math.floor((vim.o.columns - max_width) / 2)
  local row = math.floor((vim.o.lines - max_height) / 2)

  vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = max_width,
    height = max_height,
    col = col,
    row = row,
    style = 'minimal',
    border = 'rounded',
    title = ' Métricas ',
    title_pos = 'center',
  })
  vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
  vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf })
  vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', { buffer = buf })
end

-- Keymaps de IA (prefixo <leader>a = AI)
keymap('n', '<leader>al', function() character_quick_lookup() end, { desc = 'IA: Buscar personagem' })
keymap('n', '<leader>ac', function()
  print('Analisando consistência...')
  ai_run('consistency', 'Consistência')
end, { desc = 'IA: Consistência' })
keymap('n', '<leader>ar', function()
  print('Analisando ritmo...')
  ai_run('pacing', 'Ritmo')
end, { desc = 'IA: Ritmo' })
keymap('n', '<leader>at', function()
  print('Analisando temas...')
  ai_run('themes', 'Temas')
end, { desc = 'IA: Temas' })
keymap('n', '<leader>ap', function()
  print('Detectando repetições...')
  ai_run('repetitions', 'Repetições')
end, { desc = 'IA: Repetições' })
keymap('n', '<leader>am', function()
  print('Atualizando memória...')
  ai_run('memory', 'Memória')
end, { desc = 'IA: Atualizar memória' })
keymap('n', '<leader>aq', function()
  print('Gerando pergunta...')
  ai_run('question', 'Pergunta Criativa')
end, { desc = 'IA: Pergunta criativa' })
keymap('n', '<leader>as', function() analyze_current_scene() end, { desc = 'IA: Analisar cena atual' })
keymap('n', '<leader>ai', function() ai_run('status', 'Status') end, { desc = 'IA: Status do projeto' })
keymap('n', '<leader>ad', function() show_metrics() end, { desc = 'IA: Dashboard métricas' })

-- Comandos :AI para quem preferir digitar
vim.api.nvim_create_user_command('AIConsistency', function() ai_run('consistency', 'Consistência') end, { desc = 'Verificar consistência' })
vim.api.nvim_create_user_command('AIPacing', function() ai_run('pacing', 'Ritmo') end, { desc = 'Analisar ritmo' })
vim.api.nvim_create_user_command('AIThemes', function() ai_run('themes', 'Temas') end, { desc = 'Analisar temas' })
vim.api.nvim_create_user_command('AIRepetitions', function() ai_run('repetitions', 'Repetições') end, { desc = 'Detectar repetições' })
vim.api.nvim_create_user_command('AIMemory', function() ai_run('memory', 'Memória') end, { desc = 'Atualizar memória' })
vim.api.nvim_create_user_command('AIQuestion', function() ai_run('question', 'Pergunta') end, { desc = 'Pergunta criativa' })
vim.api.nvim_create_user_command('AIScene', function() analyze_current_scene() end, { desc = 'Analisar cena atual' })
vim.api.nvim_create_user_command('AIStatus', function() ai_run('status', 'Status') end, { desc = 'Status do projeto' })
vim.api.nvim_create_user_command('AIMetrics', function() show_metrics() end, { desc = 'Dashboard métricas' })
vim.api.nvim_create_user_command('AICharacter', function(opts)
  if opts.args == '' then
    character_quick_lookup()
  else
    ai_run('character ' .. opts.args, opts.args)
  end
end, { nargs = '?', desc = 'Buscar personagem' })

-- ============================================================================
-- MENSAGEM DE BOAS-VINDAS
-- ============================================================================

vim.defer_fn(function()
  print("NeoVim - Modo Escrita | <leader>? Menu | <leader>a* IA")
end, 100)

-- ============================================================================
-- FIM DA CONFIGURAÇÃO
-- ============================================================================
