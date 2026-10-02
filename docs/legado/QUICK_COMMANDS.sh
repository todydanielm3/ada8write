#!/usr/bin/env bash
# COMANDOS RÁPIDOS - Cole no terminal para executar

cat <<'ASCII'
 .--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--.
 / .. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \
 \ \/\ \/\ \/\ \/\ \/\ \/\ \/\ \/\ \/\ \/\ \/\ \/\ \/\ \/\ \/\ \/ /
  \/ /\/ /\/ /\/ /\/ /\/ /\/ /\/ /\/ /\/ /\/ /\/ /\/ /\/ /\/ /\/ /
  / /\/ /`' /`' /`' /`' /`' /`' /`' /`' /`' /`' /`' /`' /`' /\/ /\
 / /\ \/`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'\ \/\ \
 \ \/\ \                                                    /\ \/ /
 / /\ \/                                                    \ \/\ \
 \ \/\ \                 Projeto de Escrita                  /\ \/ /
  \/ /\/         Comandos Rápidos para o Terminal            /\/ /\ 
  / /\/\             by Daniel Moraes - 2026                /\/ /\ /
 / /\ \/                                                    \ \/\ \
 \ \/\ \.--..--..--..--..--..--..--..--..--..--..--..--..--./\ \/ /
  \/ /\/ ../ ../ ../ ../ ../ ../ ../ ../ ../ ../ ../ ../ ../ /\/ /
  / /\/ /\/ /\/ /\/ /\/ /\/ /\/ /\/ /\/ /\/ /\/ /\/ /\/ /\/ /\/ /\
 / /\ \/\ \/\ \/\ \/\ \/\ \/\ \/\ \/\ \/\ \/\ \/\ \/\ \/\ \/\ \/\ \
 \ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ /
  `--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'

ASCII
echo ""
echo "📖 Setup do Projeto de Escrita - Comandos Rápidos"
echo "=================================================="

# Navegar para o projeto
alias livro='cd /Users/danielmoraes/LIVRO/book'

# Aliases úteis
alias nova-cena='bash /Users/danielmoraes/LIVRO/book/scripts/new_scene.sh'
alias novo-personagem='bash /Users/danielmoraes/LIVRO/book/scripts/new_character.sh'
alias novo-capitulo='bash /Users/danielmoraes/LIVRO/book/scripts/new_chapter.sh'
alias montar='bash /Users/danielmoraes/LIVRO/book/scripts/build.sh'
alias exportar='bash /Users/danielmoraes/LIVRO/book/scripts/export.sh'
alias escrever='cd /Users/danielmoraes/LIVRO/book && bash /Users/danielmoraes/LIVRO/book/scripts/menu.sh'
alias palavras='cd /Users/danielmoraes/LIVRO/book && python3 .ai_assistant/narrative_ai.py status'
alias atualizar-personagens='bash /Users/danielmoraes/LIVRO/book/scripts/update_personagens.sh'

# Aliases do Assistente IA
alias ai-metricas='cd /Users/danielmoraes/LIVRO/book && python3 .ai_assistant/metrics.py'
alias ai-consistencia='cd /Users/danielmoraes/LIVRO/book && python3 .ai_assistant/narrative_ai.py consistency'
alias ai-ritmo='cd /Users/danielmoraes/LIVRO/book && python3 .ai_assistant/narrative_ai.py pacing'
alias ai-temas='cd /Users/danielmoraes/LIVRO/book && python3 .ai_assistant/narrative_ai.py themes'
alias ai-memoria='cd /Users/danielmoraes/LIVRO/book && python3 .ai_assistant/narrative_ai.py memory'
alias ai-repeticoes='cd /Users/danielmoraes/LIVRO/book && python3 .ai_assistant/narrative_ai.py repetitions'
alias ai-pergunta='cd /Users/danielmoraes/LIVRO/book && python3 .ai_assistant/narrative_ai.py question'
alias ai-status='cd /Users/danielmoraes/LIVRO/book && python3 .ai_assistant/narrative_ai.py status'

echo "✅ Aliases criados:"
echo "   livro             → navegar para o projeto"
echo "   nova-cena         → criar nova cena"
echo "   novo-personagem   → criar novo personagem"
echo "   novo-capitulo     → criar novo capítulo"
echo "   montar            → montar o livro"
echo "   exportar          → exportar para PDF/DOCX"
echo "   escrever          → abrir menu interativo"
echo "   palavras          → contar palavras"
echo "   atualizar-personagens → atualizar índice de personagens"
echo ""
echo "🤖 Assistente IA:"
echo "   ai-metricas       → dashboard de métricas"
echo "   ai-consistencia   → verificar consistência"
echo "   ai-ritmo          → análise de ritmo narrativo"
echo "   ai-temas          → análise temática"
echo "   ai-memoria        → atualizar memória narrativa"
echo "   ai-repeticoes     → detectar repetições"
echo "   ai-pergunta       → pergunta criativa"
echo "   ai-status         → status do projeto"
echo ""
echo "💡 Exemplos de uso:"
echo "   nova-cena confronto-final"
echo "   novo-personagem maria-silva"
echo "   novo-capitulo cap-01-despertar"
echo "   ai-metricas"
echo ""
echo "📁 Estrutura do projeto:"
echo "   00_notas/         → anotações e diários"
echo "   01_personagens/   → fichas de personagens"
echo "   02_cenas/         → cenas individuais"
echo "   03_capitulos/     → capítulos compilados"
echo "   99_build/         → livro montado"
echo ""
echo "📌 Para tornar permanente, adicione ao ~/.zshrc:"
echo "   source /Users/danielmoraes/LIVRO/book/QUICK_COMMANDS.sh"
