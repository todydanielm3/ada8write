# 🚀 Comece por aqui

Guia de 2 minutos para o ateliê de escrita.

---

## 1. Carregue os atalhos

```bash
cd /Users/danielmoraes/LIVRO/book
source scripts/aliases.sh
```

Para não repetir isso toda vez:

```bash
echo 'source /Users/danielmoraes/LIVRO/book/scripts/aliases.sh' >> ~/.zshrc
```

---

## 2. Abra o painel

```bash
escrever
```

O cabeçalho mostra sempre **qual livro está ativo** e o progresso em palavras.

---

## 3. Um livro por vez

Cada livro é uma pasta independente em `livros/`. Textos, configuração, build e
memória da IA pertencem só a ele.

```bash
livros                      # lista (● = ativo)
livros o-escondido          # ativa outro livro
novo-livro "A Casa Vazia"   # cria um livro do zero
```

No menu: **b** troca de livro, **L** cria um novo.

---

## 4. Escreva

Todo arquivo criado é **`.txt` vazio** — nada entre você e o texto.

```bash
novo-capitulo "1.1.O começo"
nova-cena confronto-final --open
novo-personagem maria --template   # --template = ficha estruturada
nova-nota "ideias para o final"
```

No menu: **1-4** criam, **5-8** abrem o que já existe.

---

## 5. Produza

```bash
montar       # junta 03_capitulos/ em 99_build/book.md
exportar     # PDF, DOCX e EPUB
palavras     # relatório de contagem
```

---

## 6. Converse com a IA

```bash
ai-metricas      # dashboard local, sem API
ai-consistencia  # checa contradições na narrativa
ai-temas
ai-ritmo
```

A IA só enxerga o livro ativo. Livro novo = memória nova.

---

## Fluxo sugerido

1. **Rascunhe** cenas em `02_cenas/` sem revisar nada.
2. **Organize** as cenas em capítulos dentro de `03_capitulos/`.
3. **Revise** no VS Code (ortografia e gramática ligadas).
4. **Monte e exporte** quando quiser ver o livro inteiro.

Mais detalhes no `README.md` da raiz.
