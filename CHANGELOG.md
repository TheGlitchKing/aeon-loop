# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.1] - 2026-02-07

### Fixed
- Fixed PreToolUse hook errors for Read and Grep operations
  - Changed hook matcher from specific tool list to wildcard "*"
  - Added tool type filtering in pre-tool-use.sh script
  - Read-only tools (Read, Grep) now bypass abort checks immediately
  - State-modifying tools (Bash, Edit, Write, Task, NotebookEdit) still check abort signal correctly
  - Eliminates spurious "PreToolUse:Read hook error" and "PreToolUse:Grep hook error" messages

## [1.1.0] - 2026-02-03

### Added
- NPM distribution under `@theglitchking/aeon-loop` scope
- CLI wrapper (`aeon-loop`) for easy command-line access
- NPM installation method: `npm install -g @theglitchking/aeon-loop`
- New commands:
  - `aeon-loop install` - Install aeon-loop and bundled aeon-flux
  - `aeon-loop uninstall` - Uninstall the plugins
  - `aeon-loop status` - Check installation status
  - `aeon-loop help` - Show help and usage information
- Postinstall messaging with quick start instructions
- Enhanced README with NPM installation section
- Explicit bundling note: aeon-flux is included with aeon-loop

### Changed
- Package now available via NPM in addition to Claude marketplace
- Improved installation workflow with multi-channel distribution
- Simplified plugin copying mechanism (no bash dependency)

### Maintained
- All existing functionality from v1.0.0 preserved
- Claude marketplace installation method unchanged
- aeon-flux remains bundled as part of aeon-loop
- No breaking changes for existing users

### Bundled
- **aeon-flux** - Bash Loop operating mode (included in this package)

## [1.0.0] - 2026-01-14

### Added
- Initial release of aeon-loop plugin
- Autonomous task execution with loop engine
- Integration of features from ralph-loop, aeon-flux, mind-glaive, and persistent planning
- Unified workflow via `/aeon-flux` command:
  - Phase 0: Optional codebase exploration
  - Phase 1: Discovery with clarifying questions
  - Phase 2: PRD (Product Requirements Document) generation
  - Phase 3: Implementation planning
  - Phase 4: Execution mode with autonomous iteration
- Loop commands:
  - `/loop` - Start autonomous loop
  - `/abort` - Stop all operations
  - `/pause` - Pause loop execution
  - `/resume` - Resume paused loop
  - `/status` - Show loop status
- Context persistence across iterations
- Subagent coordination and orchestration
- Pattern learning and attention preservation
- Persistent planning with markdown files in `.planning/` directory
- Claude Code marketplace distribution
- Bundled aeon-flux for "action over explanation" philosophy

[1.1.1]: https://github.com/TheGlitchKing/aeon-loop/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/TheGlitchKing/aeon-loop/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/TheGlitchKing/aeon-loop/releases/tag/v1.0.0
