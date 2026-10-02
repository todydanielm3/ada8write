#!/usr/bin/env bash
# ai_check_pacing.sh - atalho para: ./scripts/ai.sh pacing
exec bash "$(dirname "$0")/ai.sh" pacing "$@"
