# 🔧 Guia de Correção Ortográfica Automática

## ✨ Funcionalidades Implementadas

Seu NeoVim agora tem correção ortográfica **automática** para português brasileiro!

---

## 📋 Como Usar

### 1. **Corrigir UMA palavra**
Coloque o cursor sobre a palavra errada e pressione:
```
<leader>sf
```
Ou use o comando:
```
:SpellFix
```

**Exemplo:**
```
Antes:  Esta eh uma senteça.
Depois: Esta é uma sentença.
```

---

### 2. **Corrigir TODAS as palavras no arquivo**
Para corrigir todo o documento de uma vez:
```
<leader>sF
```
Ou use o comando:
```
:SpellFixAll
```

**Exemplo:**
```
Antes:  Este eh um teste para verifficar se a correção automatica funciona.
Depois: Este é um teste para verificar se a correção automática funciona.
```

---

## 📍 Navegação Entre Erros

Mesmo sem corrigir automaticamente, você pode navegar e corrigir manualmente:

| Atalho | Ação |
|--------|------|
| `]s` | Próximo erro |
| `[s` | Erro anterior |
| `z=` | Ver sugestões |
| `<leader>sa` | Adicionar palavra ao dicionário |
| `<leader>sr` | Remover palavra do dicionário |

---

## 🎯 Workflow Recomendado

### Opção 1: Corrigir Tudo de Uma Vez
1. Escreva seu parágrafo/capítulo
2. Pressione `<leader>sF` para corrigir todos os erros
3. Continue escrevendo

### Opção 2: Corrigir Conforme Escreve
1. Termine a palavra
2. Se vir o sublinhado vermelho, pressione `<leader>sf`
3. Continue escrevendo

### Opção 3: Revisão Manual
1. Use `]s` para ir ao próximo erro
2. Pressione `z=` para ver sugestões
3. Escolha a correta (geralmente a primeira)
4. Pressione `Enter` para aceitar

---

## 🌍 Idiomas Configurados

Seu dicionário está configurado para:
- 🇧🇷 **Português Brasileiro** (pt_br)
- 🇬🇧 **Inglês** (en)

---

## 📝 Arquivo de Teste

Para testar, abra: `teste_spell.md`

```bash
nvim teste_spell.md
# ou
./scripts/nvimw.sh teste_spell.md
```

Depois pressione `<leader>sF` para corrigir tudo!

---

## ⚙️ Troubleshooting

**Problema:** O spell não está funcionando
```
:set spell
```

**Problema:** Quer reinstalar dicionários
```
:SpellInstall
```

**Problema:** Quer ativar/desativar spell checking
```
:SpellCheck
```

---

## 💡 Dicas

- **Palavras corretas não reconhecidas?** Use `<leader>sa` para adicionar ao dicionário
- **Muito rápido demais?** Use a navegação manual com `]s` + `z=`
- **Quer fazer comentários?** Os erros em comentários também são corrigidos

---

**Desenvolvido com ❤️ para seu Projeto de Escrita**
