# 🤖 Assistente de IA para Escrita Criativa

Um observador silencioso que conhece profundamente sua história e te avisa quando algo começa a quebrar.

## 🎯 Filosofia

Este assistente **NÃO**:
- ❌ Escreve por você
- ❌ Sugere texto pronto
- ❌ "Otimiza" seu estilo
- ❌ Interrompe constantemente

Este assistente **SIM**:
- ✅ Conhece toda sua história
- ✅ Identifica inconsistências narrativas
- ✅ Alerta sobre problemas de ritmo
- ✅ Faz perguntas para estimular reflexão
- ✅ Mantém métricas que importam

## 🚀 Como Usar

### No Menu Interativo

Digite `escrever` no terminal e escolha:

- **a** - Dashboard de métricas completo
- **r** - Verificar consistência narrativa
- **t** - Análise temática
- **n** - Atualizar memória narrativa

### Comandos Diretos no Terminal

```bash
# Ver dashboard de métricas
ai-metricas

# Verificar consistência
ai-consistencia

# Análise temática
ai-temas

# Atualizar memória narrativa
ai-memoria

# Detectar repetições
ai-repeticoes
```

## 📊 Funcionalidades

### 1. Memória Narrativa Estruturada
Mantém um resumo ativo de:
- Linha do tempo de eventos
- Status emocional dos personagens
- Conflitos abertos vs resolvidos
- Temas centrais

### 2. Análise de Consistência
Detecta:
- Comportamentos que contradizem motivações estabelecidas
- Eventos que contradizem consequências anteriores
- Oportunidades narrativas perdidas

### 3. Monitor de Ritmo
Identifica:
- Capítulos lentos vs rápidos
- Zonas de exposição excessiva
- Picos de tensão
- Áreas sem mudança emocional

### 4. Detecção de Repetições
Alerta quando:
- Estruturas de cena se repetem
- Conflitos semelhantes aparecem sem evolução
- Diálogos cumprem a mesma função dramática

### 5. Análise Temática
Monitora:
- Coerência com temas centrais
- Capítulos que fogem do tom
- Oportunidades de reforço temático

### 6. Métricas Avançadas
Acompanha:
- Total de palavras, cenas, capítulos
- Proporção diálogo vs narrativa
- Proporção ação vs reflexão
- Dias de escrita consecutivos (streak)
- Maior pausa entre sessões
- Comprimento médio de cenas

## 🧠 Como Funciona

1. **Leitura**: O assistente lê todos os seus capítulos e fichas de personagens
2. **Análise**: Usa GPT-4 para análise profunda do contexto narrativo
3. **Memória**: Mantém cache local com o estado da história
4. **Insights**: Oferece alertas breves e contextuais

## ⚙️ Configuração

A chave da API OpenAI está configurada em:
```
.ai_assistant/.env
```

**IMPORTANTE**: Este arquivo NUNCA deve ser commitado no git (já está no .gitignore)

## 📁 Estrutura

```
.ai_assistant/
├── .env                    # Configuração da API (NÃO COMMITAR!)
├── narrative_ai.py         # Motor de análise narrativa
├── ai_cli.py              # Interface de linha de comando
├── metrics.py             # Sistema de métricas
├── requirements.txt       # Dependências Python
└── cache/
    ├── narrative_memory.json    # Memória da história
    └── writing_metrics.json     # Métricas de escrita
```

## 💡 Workflow Sugerido

1. **Ao começar a escrever**: `ai-memoria` (atualiza contexto)
2. **Durante a escrita**: Foque na criação
3. **Após sessão**: `ai-metricas` (veja progresso)
4. **Antes de revisar**: `ai-consistencia` e `ai-temas`

## 🎓 Exemplo de Uso

```bash
# Atualizar memória antes de começar
$ ai-memoria
🧠 Atualizando memória narrativa...
✅ Memória atualizada com sucesso!

📚 Temas: poder, culpa, redenção
⚠️  Conflitos abertos: 3
📅 Última atualização: 2026-02-05

# Ver métricas do projeto
$ ai-metricas
📊 DASHBOARD DE MÉTRICAS DE ESCRITA
====================================

📖 VISÃO GERAL
  • Total Words: 15420
  • Total Chapters: 3
  • Total Scenes: 12
  • Writing Streak: 7 dias

🎭 COMPOSIÇÃO NARRATIVA
  • Dialogue Ratio: 35%
  • Action Ratio: 62%
  • Avg Scene Length: 1285 palavras

⚡ PRODUTIVIDADE
  • Longest Pause: 2 dias
  • Avg Words Per Session: 842
  • Total Sessions: 18
```

## 🔐 Segurança

- A chave da API está protegida no `.env`
- O arquivo está no `.gitignore`
- Dados ficam apenas localmente no cache

## 🤝 Suporte

Se encontrar problemas, verifique:
1. Dependências instaladas: `python3 -m pip install openai python-dotenv`
2. Arquivo `.env` existe e tem a chave correta
3. Scripts têm permissão de execução: `chmod +x scripts/ai_*.sh`

---

**"Eu criei um assistente de IA que não escreve por mim, mas conhece minha história melhor do que qualquer leitor beta — e me avisa quando algo começa a quebrar."**
