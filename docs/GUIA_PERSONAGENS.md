# 📋 Guia Completo - Acessar Personagens

## 🎯 3 Formas de Acessar Personagens

### 1. **Menu Flutuante Interativo** (Recomendado) ⭐
Pressione no NeoVim:
```
<leader>c
```

**Resultado:**
- Lista todos os personagens em uma janela flutuante
- Pressione o número do personagem para abrir
- Pressione `q` ou `Esc` para fechar

**Exemplo:**
```
📖 PERSONAGENS
════════════════
1. Corgel
2. Hendrik
3. teste3

(Pressione: 1 para abrir Corgel)
```

---

### 2. **Comando VIM**
Digite no NeoVim:
```
:Personagens
```

**Resultado:** Mesma lista flutuante da opção 1

---

### 3. **Explorador de Arquivos**
Pressione no NeoVim:
```
<leader>C
```

**Resultado:** Abre pasta `01_personagens/` no explorador

---

## 📖 Índice Centralizado

Veja: [PERSONAGENS.md](PERSONAGENS.md)

- ✅ Atualizado automaticamente
- ✅ Mostra todos os personagens
- ✅ Clicável (com links)

---

## 🔄 Manter Índice Atualizado

Após criar novo personagem:

```bash
cd /Users/danielmoraes/LIVRO/book
./scripts/update_personagens.sh
```

Ou via NeoVim:
```
:!./scripts/update_personagens.sh
```

---

## ✨ Fluxo Completo

### Criar Novo Personagem
```
<leader>ep          # Cria novo arquivo
Digite: João        # Nome do personagem
```

### Acessar Personagem
```
<leader>c           # Lista personagens
Pressione: 4        # Abre João
```

### Atualizar Índice
```
./scripts/update_personagens.sh   # Atualiza índice
```

---

## 🎨 Menu Rápido

Veja `<leader>?` no NeoVim para ver todos os atalhos:

```
📁 NAVEGAÇÃO
  <leader>c  → Listar Personagens 📋
  <leader>C  → Explorador Personagens
  <leader>ep → Novo Personagem
```

---

## 📊 Estrutura de Diretórios

```
livros/<livro-ativo>/
├── PERSONAGENS.md    ← Índice centralizado (gerado)
└── 01_personagens/
    ├── Corgel.txt
    ├── Hendrik.txt
    └── teste3.txt
```

---

## 💡 Dicas

- **Buscar por nome:** Use `/` no índice para buscar
- **Editar índice:** Abra `PERSONAGENS.md` manualmente
- **Links clicáveis:** Use Ctrl+] em cima de um link para abrir
- **Sincronização:** Use `:ReadSync PERSONAGENS.md` para ler enquanto escreve

---

## ✅ Resumo

| Ação | Atalho | Resultado |
|------|--------|-----------|
| Listar personagens | `<leader>c` | Menu flutuante |
| Explorador | `<leader>C` | Pasta aberta |
| Novo personagem | `<leader>ep` | Cria arquivo |
| Ver índice | Ver [PERSONAGENS.md](PERSONAGENS.md) | Lista com links |

---

**Todos os personagens agora estão centralizados e acessíveis! 🎉**
