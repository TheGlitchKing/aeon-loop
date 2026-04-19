#!/usr/bin/env node
// aeon-loop update-check SessionStart hook (npm install path).
// The marketplace install path uses its own SessionStart hook chain at
// plugins/aeon-loop/hooks/ — this file is only invoked when a project
// has aeon-loop installed as an npm dep and .claude/settings.json
// references it.

import { runSessionStart } from "@theglitchking/claude-plugin-runtime";

await runSessionStart({
  packageName: "@theglitchking/aeon-loop",
  pluginName: "aeon-loop",
  configFile: "aeon-loop.json",
});
