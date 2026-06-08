#!/usr/bin/env bash
set -euo pipefail

api_file="pages/api/execute/code.ts"

for required in \
  "EXECUTE_API_TOKEN" \
  "WWW-Authenticate" \
  "timingSafeEqual" \
  "extractParameters" \
  "openai.chat.completions.create"
do
  if ! rg -q "$required" "$api_file"; then
    echo "missing required execute API guard: $required" >&2
    exit 1
  fi
done

if rg -q "match\\[1\\]|code\\.match\\(" "$api_file"; then
  echo "execute API still depends on unchecked regex match parsing" >&2
  exit 1
fi

if ! awk '
  /EXECUTE_API_TOKEN/ { token = NR }
  /new OpenAI/ && !client { client = NR }
  /openai\.chat\.completions\.create/ { call = NR }
  END { exit !(token && client && call && token < client && client < call) }
' "$api_file"; then
  echo "OpenAI client must be created only after execute token checks" >&2
  exit 1
fi

echo "execute API authorization checks are present"
