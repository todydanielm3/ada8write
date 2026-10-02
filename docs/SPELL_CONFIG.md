# ✨ Correção Ortográfica Automática - NeoVim

## 🎯 O que foi implementado

Seu NeoVim agora tem **correção ortográfica automática** em português brasileiro com os seguintes recursos:

### ✅ Funcionalidades Principais

1. **Corrigir Palavra Sob Cursor**
   - Atalho: `<leader>sf`
   - Comando: `:SpellFix`
   - Usa a primeira sugestão (mais provável)

2. **Corrigir TUDO no Arquivo** 🚀
   - Atalho: `<leader>sF`
   - Comando: `:SpellFixAll`
   - Itera por todos os erros do arquivo

3. **Navegação Entre Erros**
   - `]s` = Próximo erro
   - `[s` = Erro anterior
   - `z=` = Ver sugestões (manual)

4. **Gerenciar Dicionário**
   - `<leader>sa` = Adicionar palavra ao dicionário
   - `<leader>sr` = Remover do dicionário

---

## 🚀 Quick Start

### Testar a Correção
```bash
cd /Users/danielmoraes/LIVRO/book
nvim teste_spell.md
```

**No NeoVim:**
```
<leader>sF    # Corrige TUDO
# ou
<leader>sf    # Corrige palavra sob cursor
```

---

## 📋 Arquivo de Configuração

**Localização:** `/Users/danielmoraes/LIVRO/book/.nvim/init.lua`

**Funções principais adicionadas (linhas 376-415):**

```lua
-- Corrige TODAS as palavras erradas
local function spell_fix_all()
  -- Move ao início
  -- Loop através de cada erro
  -- Aplica primeira sugestão
end

-- Corrige palavra sob cursor
local function spell_fix_word()
  -- Pega sugestões
  -- Substitui pela primeira
end
```

**Atalhos adicionados (linhas 484-489):**

```lua
<leader>sf  → spell_fix_word()   # Palavra
<leader>sF  → spell_fix_all()    # Tudo
```

**Comandos adicionados (linhas 594-600):**

```lua
:SpellFix       # Corrigir palavra
:SpellFixAll    # Corrigir arquivo todo
```

---

## 🌍 Idiomas Configurados

- 🇧🇷 Português Brasileiro (pt_br)
- 🇬🇧 Inglês (en)

Dicionários instalados em: `~/.config/nvim/spell/`

---

## 📝 Exemplo de Uso

### Antes (com erros):
```
Este eh um teste para verifficar se a correção automatica funciona.
```

### Depois (após <leader>sF):
```
Este é um teste para verificar se a correção automática funciona.
```

---

## ⚙️ Comandos Úteis

| Comando | Ação |
|---------|------|
| `:SpellFix` | Corrige palavra sob cursor |
| `:SpellFixAll` | Corrige arquivo todo |
| `:SpellCheck` | Ativa/desativa spell check |
| `:SpellInstall` | Reinstala dicionários |

---

## 🔧 Menu Interativo

Pressione `<leader>?` para ver todas as opções, incluindo:
- ✅ Ortografia (com as novas correções!)
- 📖 Leitura & Escrita sincronizada
- 📁 Navegação
- ✏️ Criar novo arquivo
- 💾 Arquivo
- 🔍 Busca & Edição
- 📊 Análise

---

## 📚 Documentação Completa

Veja: **[SPELL_GUIDE.md](SPELL_GUIDE.md)** para guia detalhado

---

## 📁 Estrutura do Projeto

```
book/
├── .nvim/
│   └── init.lua              ← Configuração principal (com spell fix)
├── teste_spell.md            ← Arquivo de teste
├── SPELL_GUIDE.md            ← Guia completo de ortografia
├── SPELL_CONFIG.md           ← Este arquivo
├── 00_notas/
├── 01_personagens/
├── 02_cenas/
└── 03_capitulos/
```

---

## ✨ Resumo

Você agora pode:

1. ✍️ Escrever seu texto
2. 🔍 Deixar o spell checker sublinhar erros
3. 🚀 Pressionar `<leader>sF` para corrigir TUDO
4. 💾 Salvar (`<leader>w`) e continuar

**Tudo automático e em português brasileiro! 🇧🇷**
