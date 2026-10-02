#!/usr/bin/env bash
# ai_check_consistency.sh - atalho para: ./scripts/ai.sh consistency
exec bash "$(dirname "$0")/ai.sh" consistency "$@"
