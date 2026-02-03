#!/usr/bin/env node

const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  blue: '\x1b[34m',
  yellow: '\x1b[33m',
  cyan: '\x1b[36m',
  magenta: '\x1b[35m'
};

console.log(`
${colors.cyan}╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║              aeon-loop installed successfully!                 ║
║               (includes bundled aeon-flux)                     ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝${colors.reset}

${colors.green}✓${colors.reset} Package installed: ${colors.blue}@theglitchking/aeon-loop${colors.reset}
${colors.green}✓${colors.reset} Bundled plugin: ${colors.magenta}aeon-flux${colors.reset} (included)

${colors.yellow}Next Steps:${colors.reset}

  1. Run the installer to set up the plugins:
     ${colors.cyan}aeon-loop install --scope user${colors.reset}

     ${colors.blue}Scopes:${colors.reset}
       user    - Install globally (~/.claude/) for all projects
       project - Install locally (./.claude/) for this project only

  2. Check installation status:
     ${colors.cyan}aeon-loop status${colors.reset}

  3. After installation, use these Claude Code commands:
     ${colors.cyan}/aeon-flux${colors.reset}   - Start unified workflow (discovery → PRD → plan → execute)
     ${colors.cyan}/loop${colors.reset}        - Start autonomous loop
     ${colors.cyan}/abort${colors.reset}       - Stop all operations
     ${colors.cyan}/focus <item>${colors.reset} - Mark for attention preservation

${colors.yellow}What's Included:${colors.reset}
  ${colors.blue}aeon-loop${colors.reset}  - Autonomous task execution engine
  ${colors.magenta}aeon-flux${colors.reset}  - Bash Loop mode (action over explanation)

${colors.yellow}Quick Start:${colors.reset}
  ${colors.cyan}aeon-loop help${colors.reset}

${colors.yellow}Documentation:${colors.reset}
  ${colors.blue}https://github.com/TheGlitchKing/aeon-loop${colors.reset}

`);
