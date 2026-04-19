---
description: Update aeon-loop to the latest version (runs npm update + re-links skills)
allowed-tools: Bash(npx:*)
---

Run `npx --no @theglitchking/aeon-loop update` and report the before/after versions to the user. If the project doesn't have a local install, fall back to `npx -y @theglitchking/aeon-loop update` and note that in your summary.
