# Retire GPT-3.5 Default Design

## Problem

The execute proxy still admitted `gpt-3.5-turbo` by default even though the
editor uses `gpt-4o-mini`. OpenAI's current model documentation classifies
GPT-3.5 Turbo as legacy and recommends GPT-4o mini in its place because it is
cheaper, more capable, multimodal, and comparably fast.

## Options

1. Keep both defaults. This preserves stale compatibility but continues to
   expose a legacy, more expensive choice.
2. Expand to newer models. This broadens spend and parameter-compatibility
   risk beyond the prototype's reviewed request shape.
3. Narrow the maximum set to the existing editor default, `gpt-4o-mini`.

## Decision

Use option 3. Environment configuration remains narrowing-only and cannot
restore `gpt-3.5-turbo`. Keep Chat Completions unchanged in this focused pass;
Responses migration requires separate API and product design.

## Official References

- [GPT-3.5 Turbo](https://developers.openai.com/api/docs/models/gpt-3.5-turbo)
- [GPT-4o mini](https://developers.openai.com/api/docs/models/gpt-4o-mini)
- [Chat Completions](https://platform.openai.com/docs/api-reference/chat/create)
