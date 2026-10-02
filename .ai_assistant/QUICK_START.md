# 🚀 GUIA RÁPIDO - Assistente IA

## ⚡ Comandos Essenciais

### Via Menu Interativo
```bash
escrever
# Depois escolha:
# a - Dashboard de métricas
# r - Verificar consistência
# t - Análise temática  
# n - Atualizar memória narrativa
```

### Via Terminal Direto
```bash
ai-metricas        # Dashboard completo
ai-memoria         # Atualizar contexto da história
ai-consistencia    # Verificar problemas narrativos
ai-temas           # Análise temática
ai-repeticoes      # Detectar padrões repetitivos
```

## 📖 Workflow Recomendado

### 1. Antes de Escrever (1x por dia)
```bash
ai-memoria
```
Atualiza o contexto da IA com todo o conteúdo escrito.

### 2. Durante a Escrita
**Não use a IA!** Foque 100% na criação.

### 3. Após Sessão de Escrita
```bash
ai-metricas
```
Veja seu progresso, streak, proporções de diálogo/ação.

### 4. Antes de Revisar
```bash
ai-consistencia
ai-temas
```
Identifique problemas antes de mergulhar na revisão.

## 💡 O que Esperar

### ✅ A IA VAI:
- Identificar inconsistências de comportamento
- Alertar sobre furos narrativos
- Mostrar padrões de ritmo
- Detectar repetições
- Fazer perguntas criativas

### ❌ A IA NÃO VAI:
- Escrever texto por você
- Corrigir gramática
- Sugerir frases prontas
- Interferir durante a escrita

## 🎯 Exemplo de Uso Real

```bash
# Segunda-feira, início da semana
$ ai-memoria
✅ Memória atualizada!
📚 Temas: lealdade, traição, redenção
⚠️  Conflitos abertos: 4

# Escrever durante a semana...
# (sem usar IA)

# Sexta-feira, fim da semana
$ ai-metricas
📊 DASHBOARD
Total: 18.453 palavras (+2.130 esta semana)
Streak: 5 dias 🔥
Diálogo: 42% | Ação: 68%

$ ai-consistencia
🔍 ANÁLISE
⚠️  Cap 3: Personagem reage de forma muito branda 
   considerando o trauma descrito no Cap 1
💡 Capítulo 4 está muito expositivo (considere 
   adicionar cena de ação)

$ ai-temas
🎭 ANÁLISE TEMÁTICA
✅ Tema "lealdade" forte e consistente
⚠️  Tema "redenção" aparece pouco nos últimos 2 caps
💡 Cap 5 poderia reforçar a temática central
```

## 🔧 Solução de Problemas

### Erro: "ModuleNotFoundError: No module named 'openai'"
```bash
python3 -m pip install openai python-dotenv
```

### Erro: "OpenAI API key not found"
Verifique se `.ai_assistant/.env` existe e tem a chave.

### Análise retorna vazio
Execute `ai-memoria` primeiro para atualizar o contexto.

## 📚 Mais Informações

Leia o README completo em:
`.ai_assistant/README.md`

---

**Lembre-se**: A IA é um observador, não um co-autor. Você sempre tem a palavra final.
