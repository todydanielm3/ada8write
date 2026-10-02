#!/usr/bin/env bash
# ai_detect_repetitions.sh - atalho para: ./scripts/ai.sh repetitions
exec bash "$(dirname "$0")/ai.sh" repetitions "$@"
