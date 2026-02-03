#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const PLUGIN_SOURCE = path.join(__dirname, '..', 'plugins', 'aeon-loop');

// Colors for output
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  blue: '\x1b[34m',
  yellow: '\x1b[33m',
  red: '\x1b[31m',
  cyan: '\x1b[36m'
};

function showHelp() {
  console.log(`
${colors.blue}aeon-loop CLI${colors.reset}

${colors.green}Usage:${colors.reset}
  aeon-loop install [--scope user|project]
  aeon-loop uninstall [--scope user|project]
  aeon-loop status
  aeon-loop help

${colors.green}Commands:${colors.reset}
  install     Install aeon-loop and bundled aeon-flux plugins
  uninstall   Uninstall aeon-loop plugins
  status      Show installation status
  help        Show this help message

${colors.green}Install Options:${colors.reset}
  --scope {user|project}    Install scope (default: user)
                            user     - Install globally (~/.claude/)
                            project  - Install in current project (.claude/)

${colors.green}Examples:${colors.reset}
  aeon-loop install --scope user
  aeon-loop install --scope project
  aeon-loop uninstall --scope user
  aeon-loop status

${colors.green}After Installation:${colors.reset}
  Run these commands in Claude Code:
    /aeon-flux          - Start unified workflow
    /loop               - Start autonomous loop
    /abort              - Stop all operations
    /focus <item>       - Mark for attention preservation

${colors.yellow}Note:${colors.reset} This package includes both aeon-loop and aeon-flux plugins bundled together.
  `);
}

function copyRecursive(src, dest) {
  const stats = fs.statSync(src);

  if (stats.isDirectory()) {
    if (!fs.existsSync(dest)) {
      fs.mkdirSync(dest, { recursive: true });
    }
    fs.readdirSync(src).forEach(file => {
      copyRecursive(path.join(src, file), path.join(dest, file));
    });
  } else {
    fs.copyFileSync(src, dest);
  }
}

function checkInstallation(scope) {
  const installDir = scope === 'user'
    ? path.join(process.env.HOME || process.env.USERPROFILE, '.claude')
    : '.claude';

  const aeonLoopPath = path.join(installDir, 'plugins', 'aeon-loop');
  const aeonFluxPath = path.join(installDir, 'plugins', 'aeon-flux');

  return {
    loop: fs.existsSync(path.join(aeonLoopPath, 'CLAUDE.md')),
    flux: fs.existsSync(aeonFluxPath)
  };
}

function showStatus() {
  console.log(`\n${colors.blue}aeon-loop Installation Status${colors.reset}\n`);

  const userInstall = checkInstallation('user');
  const projectInstall = checkInstallation('project');

  console.log(`User Scope (~/.claude/):`);
  console.log(`  aeon-loop:  ${userInstall.loop ? colors.green + '✓ Installed' : colors.yellow + '✗ Not installed'}${colors.reset}`);
  console.log(`  aeon-flux:  ${userInstall.flux ? colors.green + '✓ Bundled' : colors.yellow + '✗ Not installed'}${colors.reset}`);

  console.log(`\nProject Scope (./.claude/):`);
  console.log(`  aeon-loop:  ${projectInstall.loop ? colors.green + '✓ Installed' : colors.yellow + '✗ Not installed'}${colors.reset}`);
  console.log(`  aeon-flux:  ${projectInstall.flux ? colors.green + '✓ Bundled' : colors.yellow + '✗ Not installed'}${colors.reset}`);

  if (!userInstall.loop && !projectInstall.loop) {
    console.log(`\n${colors.yellow}Run: aeon-loop install${colors.reset}`);
  }
  console.log();
}

function runInstall(args) {
  const scope = args.includes('--scope') ? args[args.indexOf('--scope') + 1] : 'user';

  const installDir = scope === 'user'
    ? path.join(process.env.HOME || process.env.USERPROFILE, '.claude')
    : '.claude';

  console.log(`${colors.blue}Installing aeon-loop...${colors.reset}`);
  console.log(`  Scope: ${scope} (${installDir})`);
  console.log(`  Includes: aeon-loop + aeon-flux (bundled)\n`);

  try {
    // Create plugins directory
    const pluginsDir = path.join(installDir, 'plugins');
    if (!fs.existsSync(pluginsDir)) {
      fs.mkdirSync(pluginsDir, { recursive: true });
    }

    // Copy aeon-loop plugin
    const aeonLoopDest = path.join(pluginsDir, 'aeon-loop');
    console.log(`${colors.blue}Copying aeon-loop plugin...${colors.reset}`);
    copyRecursive(PLUGIN_SOURCE, aeonLoopDest);
    console.log(`${colors.green}✓ aeon-loop installed${colors.reset}`);

    // aeon-flux is already bundled inside aeon-loop/skills/aeon-flux
    console.log(`${colors.green}✓ aeon-flux bundled (included with aeon-loop)${colors.reset}`);

    // Update .gitignore if project scope
    if (scope === 'project') {
      const gitignorePath = '.gitignore';
      if (fs.existsSync(gitignorePath)) {
        const content = fs.readFileSync(gitignorePath, 'utf8');
        if (!content.includes('.claude/')) {
          fs.appendFileSync(gitignorePath, '\n.claude/\n');
          console.log(`${colors.green}✓ .gitignore updated${colors.reset}`);
        }
      } else {
        fs.writeFileSync(gitignorePath, '.claude/\n');
        console.log(`${colors.green}✓ .gitignore created${colors.reset}`);
      }
    }

    console.log(`\n${colors.green}✅ Installation Complete!${colors.reset}\n`);
    console.log(`${colors.yellow}Next Steps:${colors.reset}`);
    console.log(`  1. Open Claude Code in your project`);
    console.log(`  2. Run: ${colors.cyan}/aeon-flux${colors.reset}`);
    console.log(`  3. Follow the guided workflow\n`);

  } catch (error) {
    console.error(`${colors.red}❌ Installation failed: ${error.message}${colors.reset}`);
    process.exit(1);
  }
}

function runUninstall(args) {
  const scope = args.includes('--scope') ? args[args.indexOf('--scope') + 1] : 'user';

  const installDir = scope === 'user'
    ? path.join(process.env.HOME || process.env.USERPROFILE, '.claude')
    : '.claude';

  console.log(`${colors.blue}Uninstalling aeon-loop...${colors.reset}`);
  console.log(`  Scope: ${scope} (${installDir})\n`);

  try {
    const aeonLoopPath = path.join(installDir, 'plugins', 'aeon-loop');

    if (fs.existsSync(aeonLoopPath)) {
      fs.rmSync(aeonLoopPath, { recursive: true, force: true });
      console.log(`${colors.green}✓ aeon-loop removed${colors.reset}`);
      console.log(`${colors.green}✓ aeon-flux removed (was bundled)${colors.reset}`);
    } else {
      console.log(`${colors.yellow}⚠ aeon-loop not found${colors.reset}`);
    }

    console.log(`\n${colors.green}✅ Uninstallation Complete!${colors.reset}\n`);

  } catch (error) {
    console.error(`${colors.red}❌ Uninstallation failed: ${error.message}${colors.reset}`);
    process.exit(1);
  }
}

// Main
const args = process.argv.slice(2);
const command = args[0];

switch (command) {
  case 'install':
    runInstall(args.slice(1));
    break;

  case 'uninstall':
    runUninstall(args.slice(1));
    break;

  case 'status':
    showStatus();
    break;

  case 'help':
  case '--help':
  case '-h':
  case undefined:
    showHelp();
    break;

  default:
    console.error(`${colors.red}Unknown command: ${command}${colors.reset}`);
    console.log(`Run 'aeon-loop help' for usage information`);
    process.exit(1);
}
