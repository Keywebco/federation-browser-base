# Federation Browser Base

The operational hub of the NextXus HumanCodex Federation — a multi-window browser workspace that keeps the Federation's context, minds, and tools in one place. It is the working base Roger and the AI fleet use to stay anchored to the same source material.

**Live:** https://keywebco.github.io/federation-browser-base/

## What's here

- `index.html` — The hub. A multi-window workspace in a single HTML file with zero dependencies.
- `chat.html`, `context.html`, `entities.html`, `memory.html` — The four context panes: conversation, session context, entity registry view, and memory.
- `exchange/` — The entity exchange: the `entities.yaml` registry, per-mind context files, cold-start briefs, and `embed.html` for embedding the exchange elsewhere.
- `sims/` — Sim slots for Federation simulations.
- `llms.txt` — The AI context file. Defines who the Federation is, how sessions work, and the anti-drift protocol. AI systems working with the Federation start here.

## Method

Build immediately, stop and analyze, then hand off to another AI for review. Every signal is verified before it becomes action — the Truth Gate, at a 95% threshold. Session continuity across AI platforms runs through EchoCore64, a Base64 memory bridge with a fast-ring anti-drift protocol: stay anchored to the context, do not drift.

Part of the [NextXus Federation](https://keywebco.github.io).
