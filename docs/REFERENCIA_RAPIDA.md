# 📖 Referência Rápida - Correção Ortográfica

## 🎯 Objetivo

Corrigir erros ortográficos em português brasileiro **automaticamente** no NeoVim.

---

## ⚡ Uso Rápido

### Corrigir Palavra Sob Cursor
```
<leader>sf
```

### Corrigir TUDO no Arquivo
```
<leader>sF
```

---

## 📋 Todos os Atalhos

| Atalho | Ação |
|--------|------|
| `<leader>sf` | Corrige palavra sob cursor |
| `<leader>sF` | Corrige TUDO no arquivo 🚀 |
| `]s` | Vai para próximo erro |
| `[s` | Vai para erro anterior |
| `z=` | Mostra sugestões |
| `<leader>sa` | Adiciona palavra ao dicionário |
| `<leader>sr` | Remove palavra do dicionário |
| `<leader>?` | Mostra menu com todos |

---

## 💻 Comandos

```vim
:SpellFix       " Corrigir palavra
:SpellFixAll    " Corrigir arquivo
:SpellCheck     " Ativar/desativar spell check
:SpellInstall   " Reinstalar dicionários
```

---

## 🌍 Idiomas

- 🇧🇷 Português Brasileiro
- 🇬🇧 Inglês

---

## 📁 Estrutura

**Arquivo principal:** `.nvim/init.lua`

**Funções:**
- `spell_fix_word()` - Corrige palavra
- `spell_fix_all()` - Corrige arquivo

**Localização das funções:** Linhas 376-415

---

## 🧪 Teste Rápido

```bash
cd /Users/danielmoraes/LIVRO/book
./scripts/nvimw.sh teste_spell.md
# No NeoVim: <leader>sF
```

---

## ✨ Exemplos

### Antes
```
Este eh um teste para verifficar.
```

### Depois (após <leader>sF)
```
Este é um teste para verificar.
```

---

## 🎓 Workflow

1. Escreva normalmente
2. Veja os sublinhados vermelhos (erros)
3. Pressione `<leader>sF` para corrigir TUDO
4. Continue escrevendo

---

## ❓ Dúvidas

- **Menu completo?** `<leader>?`
- **Guia detalhado?** Ver `SPELL_GUIDE.md`
- **Configuração técnica?** Ver `SPELL_CONFIG.md`
- **Teste?** Ver `TESTE_RAPIDO.md`

---

**Pronto para usar! 🚀**
