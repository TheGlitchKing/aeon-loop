#!/usr/bin/env node

import { program } from "commander";
import { registerUpdateCommands } from "@theglitchking/claude-plugin-runtime";
import { createRequire } from "node:module";

const require_ = createRequire(import.meta.url);
const { version } = require_("../package.json");

program
  .name("aeon-loop")
  .description("Autonomous task execution with loop engine, orchestrated subagents, context persistence, and intelligent failure recovery.")
  .version(version);

registerUpdateCommands(program, {
  packageName: "@theglitchking/aeon-loop",
  pluginName: "aeon-loop",
  configFile: "aeon-loop.json",
});

// Deprecated v1 subcommands — print a migration pointer and exit 0 so
// existing automation doesn't silently break.
function deprecationNotice(name) {
  console.error(`\n⚠️  'aeon-loop ${name}' was removed in v2.0.0.\n`);
  console.error(`Install via the Claude Code plugin marketplace:`);
  console.error(`  /plugin marketplace add TheGlitchKing/aeon-loop`);
  console.error(`  /plugin install aeon-loop@aeon-loop-marketplace\n`);
  console.error(`Or at the project level via npm:`);
  console.error(`  npm install --save-dev @theglitchking/aeon-loop\n`);
  console.error(`See the v2.0.0 CHANGELOG for migration details:`);
  console.error(`  https://github.com/TheGlitchKing/aeon-loop/blob/main/CHANGELOG.md\n`);
}

// `status` is intentionally NOT listed here — the runtime already
// registers a `status` subcommand with different semantics (install
// version / policy / hook state, rather than v1's scope-install check).
for (const name of ["install", "uninstall"]) {
  program
    .command(name)
    .description(`[removed in v2.0.0] use the marketplace or npm install`)
    .option("--scope <scope>")
    .allowUnknownOption(true)
    .action(() => { deprecationNotice(name); process.exit(0); });
}

program.parse();
