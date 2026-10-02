#!/usr/bin/env bash
# ai.sh - Executa o assistente de IA sempre no contexto do livro ativo.
#
#   ./scripts/ai.sh status
#   ./scripts/ai.sh consistency
#   ./scripts/ai.sh themes | pacing | memory | repetitions | question
#   ./scripts/ai.sh metrics        (dashboard de metricas)

set -uo pipefail
. "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

require_book
mkdir -p "$BOOK_CACHE_DIR"

CMD="${1:-status}"
shift 2>/dev/null || true

if [ "$CMD" = "metrics" ]; then
    exec python3 "${PLATFORM_ROOT}/.ai_assistant/metrics.py" "$@"
fi

exec python3 "${PLATFORM_ROOT}/.ai_assistant/narrative_ai.py" "$CMD" "$@"
