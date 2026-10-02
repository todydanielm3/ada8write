# 🎯 CHECKLIST FINAL - Setup do Projeto de Escrita

## ✅ Estrutura Criada

- [x] Diretório `book/` com todas as subpastas
- [x] `00_notas/` - Notas e ideias
- [x] `01_personagens/` - Fichas de personagens
- [x] `02_cenas/` - Cenas individuais
- [x] `03_capitulos/` - Capítulos finalizados
- [x] `90_arquivo/` - Versões antigas
- [x] `99_build/` - Outputs (PDF, DOCX)
- [x] `templates/` - Templates prontos
- [x] `scripts/` - Scripts de automação
- [x] `.nvim/` - Config do NeoVim
- [x] `.vscode/` - Config do VS Code

## ✅ Arquivos Criados

### Templates
- [x] `templates/cena.md`
- [x] `templates/personagem.md`
- [x] `templates/capitulo.md`

### Scripts (executáveis)
- [x] `scripts/new_scene.sh`
- [x] `scripts/new_character.sh`
- [x] `scripts/new_chapter.sh`
- [x] `scripts/build.sh`
- [x] `scripts/export.sh`
- [x] `scripts/nvimw.sh`

### Configurações
- [x] `.nvim/init.lua` (NeoVim)
- [x] `.vscode/settings.json`
- [x] `.vscode/extensions.json`
- [x] `.vscode/keybindings.json`
- [x] `.vscode/tasks.json`

### Documentação
- [x] `README.md`
- [x] `index.md`
- [x] `.editorconfig`
- [x] `.gitignore`

---

## 🔧 Próximos Passos (Você Faz)

### 1. Abrir Projeto no VS Code
```bash
cd /Users/danielmoraes/LIVRO/book
code .
```

### 2. Instalar Extensões do VS Code

O VS Code vai sugerir automaticamente. Clique em **"Instalar Todas"**.

Ou instale manualmente:
```bash
code --install-extension yzhang.markdown-all-in-one
code --install-extension davidanson.vscode-markdownlint
code --install-extension streetsidesoftware.code-spell-checker
code --install-extension streetsidesoftware.code-spell-checker-portuguese-brazilian
code --install-extension valentjn.vscode-ltex
code --install-extension mushan.vscode-paste-image
code --install-extension stkb.rewrap
code --install-extension vscodevim.vim  # OPCIONAL
```

### 3. Testar NeoVim (Primeira Vez)

```bash
cd /Users/danielmoraes/LIVRO/book
./scripts/nvimw.sh
```

**O que vai acontecer:**
- NeoVim vai baixar e instalar plugins automaticamente (lazy.nvim)
- Aguarde a instalação (1-2 minutos na primeira vez)
- Depois, feche com `:q`

### 4. Criar Primeiro Capítulo

```bash
./scripts/new_chapter.sh cap-01-despertar
./scripts/nvimw.sh 03_capitulos/cap-01-despertar.md
```

### 5. Instalar Pandoc (Opcional - para exportar)

```bash
brew install pandoc
```

Para PDF, também instale LaTeX:
```bash
brew install --cask basictex
```

---

## 🧪 Testes Rápidos

### Teste 1: Criar uma cena
```bash
cd /Users/danielmoraes/LIVRO/book
./scripts/new_scene.sh teste-inicial
ls -l 02_cenas/
```

### Teste 2: Criar um personagem
```bash
./scripts/new_character.sh joao-silva
ls -l 01_personagens/
```

### Teste 3: Montar o livro
```bash
./scripts/build.sh
```

### Teste 4: Abrir NeoVim
```bash
./scripts/nvimw.sh
```
(Dentro do NeoVim, teste: `<Space>z` para Zen mode)

---

## 📋 Validação Final

Execute estes comandos e verifique:

```bash
cd /Users/danielmoraes/LIVRO/book

# 1. Scripts são executáveis?
ls -l scripts/*.sh | grep "rwxr"

# 2. Todos os diretórios existem?
ls -d */

# 3. Templates existem?
ls templates/

# 4. Configs existem?
ls .nvim/ .vscode/

# 5. Teste criar uma cena
./scripts/new_scene.sh validacao-final
ls 02_cenas/
```

---

## 🎨 Personalização Recomendada

### 1. Edite o README.md
- Adicione o título do seu livro
- Ajuste meta de palavras em `index.md`

### 2. Configure o Git
```bash
cd /Users/danielmoraes/LIVRO/book
git init
git add .
git commit -m "Setup inicial do projeto de escrita"
```

### 3. Ajuste o NeoVim (opcional)
Edite `.nvim/init.lua`:
- Troque o tema (linha 51-60)
- Ajuste tamanho do Zen mode (linha 71)
- Adicione/remova plugins

### 4. Ajuste o VS Code (opcional)
Edite `.vscode/settings.json`:
- Fontes e tamanhos (linhas 18-20)
- Ative LanguageTool por padrão (linha 67): `"ltex.enabled": true`

---

## 🆘 Problemas Comuns

### NeoVim não inicia
```bash
# Verifique se o arquivo existe
cat .nvim/init.lua | head

# Teste sem a config
nvim
```

### Scripts não executam
```bash
chmod +x scripts/*.sh
```

### VS Code não sugere extensões
```bash
# Feche e reabra o VS Code
# Ou vá em: View → Extensions → busque manualmente
```

---

## ✨ Você Está Pronto!

Tudo foi criado com sucesso. Agora é só começar a escrever!

**Comando para começar:**
```bash
cd /Users/danielmoraes/LIVRO/book
./scripts/new_chapter.sh cap-01-inicio
./scripts/nvimw.sh 03_capitulos/cap-01-inicio.md
```

**Workflow:**
1. Escreva no NeoVim (rascunho, foco, fluxo)
2. Revise no VS Code (preview, ortografia, gramática)
3. Monte com `./scripts/build.sh`
4. Exporte com `./scripts/export.sh`

---

**Boa escrita! 📖✍️**
