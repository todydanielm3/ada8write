#!/usr/bin/env bash
# ai_analyze_themes.sh - atalho para: ./scripts/ai.sh themes
exec bash "$(dirname "$0")/ai.sh" themes "$@"
