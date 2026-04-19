#!/usr/bin/env node
// Postinstall — delegates to @theglitchking/claude-plugin-runtime.
// aeon-loop's skill content lives under plugins/aeon-loop/skills/ (the
// marketplace-plugin layout), so skillsDir is null here; the marketplace
// install path handles skill discovery. The runtime still writes the
// default update-policy config and registers a SessionStart hook in
// .claude/settings.json for npm-install users (skipped when the plugin
// marketplace version is already enabled).

import { runPostinstall } from "@theglitchking/claude-plugin-runtime";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const packageRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");

try {
  runPostinstall({
    packageName: "@theglitchking/aeon-loop",
    pluginName: "aeon-loop",
    configFile: "aeon-loop.json",
    skillsDir: null,
    packageRoot,
    hookCommand:
      "node ./node_modules/@theglitchking/aeon-loop/hooks/session-start.js",
  });
} catch (err) {
  console.warn(`[aeon-loop] postinstall failed: ${err?.message || err}`);
}
