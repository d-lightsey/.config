# Himalaya Plugin Migration Guide

## Overview

This document provides a comprehensive guide for migrating the Himalaya email plugin from its current embedded state within the NeoVim configuration to a standalone GitHub repository that can be installed using standard lazy.nvim plugin management.

## Current Plugin State

### Architecture Summary
The Himalaya plugin is currently a sophisticated email client integration with the following key components:

**Core Modules:**
- **State Management**: Centralized state with persistence (`core/state.lua`)
- **Draft System**: Advanced draft management with auto-sync (`core/draft_manager_v2.lua`)
- **Email Operations**: Full CRUD operations via himalaya CLI (`core/api.lua`, `utils.lua`)
- **UI System**: Rich UI with sidebar, composer, and preview (`ui/`)
- **Sync Engine**: Async synchronization with retry logic (`core/sync_engine.lua`)
- **Configuration**: Comprehensive config system with validation (`core/config.lua`)

**Integration Features:**
- **Event System**: Reactive architecture with 26+ event types (`orchestration/events.lua`)
- **Notification System**: Unified notifications with smart categorization
- **Window Management**: Stack-based window tracking (`ui/window_stack.lua`)
- **Health Checks**: Comprehensive diagnostic system (`setup/health.lua`)
- **Commands**: 50+ user commands with auto-completion (`core/commands/`)

### Current Dependencies

#### External Dependencies (NeoVim Config)
```lua
-- Critical dependency that needs to be included in standalone plugin
require('neotex.util.notifications')  -- Used in 47+ files
```

#### Optional Dependencies
```lua
-- Already properly declared as optional
require('nvim-telescope/telescope.nvim')  -- Optional integration
```

#### System Dependencies
- `himalaya` CLI tool (email backend)
- `mbsync` (optional, for local sync)
- OAuth2 refresh scripts (included in plugin)

## Migration Plan

### Phase 1: Repository Setup

#### 1.1 Create GitHub Repository
```bash
# Create new repository
gh repo create yourusername/himalaya.nvim --public --description "Advanced email client for Neovim using himalaya CLI"

# Clone repository
git clone git@github.com:yourusername/himalaya.nvim.git
cd himalaya.nvim
```

#### 1.2 Repository Structure
```
himalaya.nvim/
├── README.md                 # Main documentation
├── doc/                      # Vim help documentation
│   ├── himalaya.txt          # Main help file
│   └── himalaya-api.txt      # API reference
├── lua/
│   └── himalaya/             # Main plugin code (root level)
│       ├── init.lua          # Plugin entry point
│       ├── config.lua        # Configuration system
│       ├── health.lua        # Health check integration
│       ├── core/             # Core functionality
│       ├── ui/               # User interface
│       ├── sync/             # Synchronization
│       ├── features/         # Feature modules
│       └── utils/            # Utility functions
├── after/
│   └── syntax/
│       └── mail.vim          # Email syntax highlighting
├── scripts/                  # Helper scripts
│   ├── oauth/                # OAuth refresh scripts
│   └── setup/                # Setup utilities
├── spec/                     # Test specifications
└── tests/                    # Test files (if using busted)
```

### Phase 2: Code Migration

#### 2.1 Update Module Paths
The primary task is updating all `require` statements from:
```lua
-- Current embedded paths
require('neotex.plugins.tools.himalaya.core.config')
require('neotex.plugins.tools.himalaya.ui.sidebar_v2')
```

To standard plugin paths:
```lua
-- New standalone plugin paths
require('himalaya.core.config')
require('himalaya.ui.sidebar_v2')
```

#### 2.2 Handle Notification Dependency
The most critical dependency is the notification system. Two approaches:

**Option A: Bundle Notification System**
```lua
-- Create lua/himalaya/vendor/notifications.lua
-- Copy and adapt neotex.util.notifications functionality
local M = {}

M.config = {
  enabled = true,
  debug_mode = false,
  -- Simplified config for standalone plugin
}

M.categories = {
  ERROR = { level = vim.log.levels.ERROR, always_show = true },
  USER_ACTION = { level = vim.log.levels.INFO, always_show = true },
  STATUS = { level = vim.log.levels.INFO, debug_only = true },
  -- ... rest of categories
}

function M.himalaya(message, category, context)
  -- Simplified notification logic
  if category.always_show or M.config.debug_mode then
    vim.notify(message, category.level)
  end
end

return M
```

**Option B: Make Notifications Optional**
```lua
-- In each file that uses notifications
local notify = {}
local ok, neotex_notify = pcall(require, 'neotex.util.notifications')
if ok then
  notify = neotex_notify
else
  -- Fallback to basic vim.notify
  notify.himalaya = function(msg, category) 
    vim.notify(msg, category.level or vim.log.levels.INFO)
  end
  notify.categories = {
    ERROR = { level = vim.log.levels.ERROR },
    USER_ACTION = { level = vim.log.levels.INFO },
    -- ... basic categories
  }
end
```

#### 2.3 Plugin Entry Point
Create `lua/himalaya/init.lua`:
```lua
-- himalaya.nvim - Advanced email client for Neovim
-- Repository: https://github.com/yourusername/himalaya.nvim

local M = {}

-- Plugin metadata
M._VERSION = "1.0.0"
M._NAME = "himalaya.nvim"

-- Plugin state
M._loaded = false

--- Setup the Himalaya plugin
--- @param opts table|nil Configuration options
function M.setup(opts)
  if M._loaded then
    return
  end

  -- Initialize core configuration
  local config = require('himalaya.config')
  config.setup(opts)

  -- Initialize state with migration support
  local state = require('himalaya.core.state')
  state.init()

  -- Initialize email cache
  local email_cache = require('himalaya.core.email_cache')
  email_cache.init(config.config.cache)

  -- Initialize OAuth module
  local oauth = require('himalaya.sync.oauth')
  oauth.setup()

  -- Initialize draft system
  local draft_manager = require('himalaya.core.draft_manager_v2')
  local local_storage = require('himalaya.core.local_storage')
  local sync_engine = require('himalaya.core.sync_engine')
  
  draft_manager.setup(config)
  local_storage.setup(config)
  sync_engine.setup(config)
  
  -- Setup draft notifications
  local draft_notifications = require('himalaya.core.draft_notifications')
  draft_notifications.setup()
  
  -- Recover drafts from previous session
  vim.defer_fn(function()
    draft_manager.recover_session()
  end, 100)
  
  -- Initialize UI system
  local ui = require('himalaya.ui')
  ui.setup()
  
  -- Setup highlight groups
  local highlights = require('himalaya.ui.highlights')
  highlights.setup()
  
  -- Setup enhanced sidebar features
  local sidebar_v2 = require('himalaya.ui.sidebar_v2')
  sidebar_v2.setup()

  -- Initialize event system
  local integration = require('himalaya.orchestration.integration')
  integration.setup_default_handlers()
  integration.setup()

  -- Initialize scheduler
  local scheduler = require('himalaya.core.scheduler')
  scheduler.setup()

  -- Set up commands
  local commands = require('himalaya.core.commands')
  commands.register_all()
  
  -- Initialize debug commands
  local debug_commands = require('himalaya.core.debug_commands')
  debug_commands.setup()
  
  -- Initialize performance monitoring
  local performance = require('himalaya.core.performance')
  performance.setup()

  -- Start auto-sync timer
  local manager = require('himalaya.sync.manager')
  manager.start_auto_sync()

  -- Run health check on startup if configured
  if config.config.setup.check_health_on_startup then
    vim.defer_fn(function()
      local health = require('himalaya.health')
      local result = health.check()
      if not result.ok then
        local notifications = require('himalaya.ui.notifications')
        notifications.show_setup_hints()
      end
    end, 1000)
  end

  -- Check if setup wizard should run
  if config.config.setup.auto_run then
    local wizard = require('himalaya.setup.wizard')
    if not wizard.is_setup_complete() then
      vim.defer_fn(function()
        vim.notify('Himalaya not configured. Run :HimalayaSetup to begin.', vim.log.levels.INFO)
      end, 2000)
    end
  end

  M._loaded = true
end

-- Export health check for :checkhealth himalaya
M.health = require('himalaya.health')

-- Export utilities for advanced users
M.utils = require('himalaya.utils')

-- Export configuration access
M.get_config = function() 
  return require('himalaya.config') 
end

return M
```

#### 2.4 Health Check Integration
Create `lua/himalaya/health.lua`:
```lua
-- Health check integration for :checkhealth himalaya
local M = {}

function M.check()
  local health = vim.health or require('health')
  
  health.start('Himalaya Email Plugin')
  
  -- Check himalaya CLI availability
  if vim.fn.executable('himalaya') == 1 then
    health.ok('himalaya CLI found')
  else
    health.error('himalaya CLI not found', {
      'Install himalaya: https://github.com/soywod/himalaya',
      'Ensure himalaya is in your PATH'
    })
  end
  
  -- Check configuration
  local config_ok, config = pcall(require, 'himalaya.config')
  if config_ok and config.config then
    health.ok('Configuration loaded successfully')
    
    -- Check accounts
    local accounts = config.config.accounts or {}
    local account_count = 0
    for _ in pairs(accounts) do
      account_count = account_count + 1
    end
    
    if account_count > 0 then
      health.ok(string.format('%d account(s) configured', account_count))
    else
      health.warn('No accounts configured', {
        'Run :HimalayaSetup to configure accounts'
      })
    end
  else
    health.error('Failed to load configuration')
  end
  
  -- Delegate to existing health modules
  local draft_health = require('himalaya.core.health.draft')
  draft_health.check()
end

return M
```

### Phase 3: Plugin Specification

#### 3.1 Standard Plugin Installation
Users will install with:
```lua
-- In lazy.nvim plugin specification
{
  'yourusername/himalaya.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim', -- Optional
  },
  event = 'VeryLazy',
  opts = {
    -- User configuration options
    accounts = {
      gmail = {
        email = "user@gmail.com",
        -- ... other settings
      }
    }
  },
  config = function(_, opts)
    require('himalaya').setup(opts)
  end,
}
```

#### 3.2 Alternative Configuration File
Create `lua/config/himalaya.lua` in user's NeoVim config:
```lua
-- User's NeoVim config: lua/config/himalaya.lua
return {
  'yourusername/himalaya.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
  },
  event = 'VeryLazy',
  config = function()
    require('himalaya').setup({
      -- Account configuration
      accounts = {
        gmail = {
          email = "user@gmail.com",
          maildir_path = "~/Mail/Gmail/",
          oauth = {
            client_id_env = "GMAIL_CLIENT_ID",
            client_secret_env = "GMAIL_CLIENT_SECRET",
          },
        },
      },
      
      -- UI configuration
      ui = {
        sidebar = {
          width = 30,
          position = 'left',
        },
        preview = {
          height = 15,
        },
      },
      
      -- Draft system configuration
      draft = {
        auto_save = true,
        sync_on_save = true,
        recovery = {
          enabled = true,
        },
      },
      
      -- Sync configuration
      sync = {
        auto_sync = true,
        sync_interval = 300, -- 5 minutes
      },
    })
  end,
}
```

### Phase 4: Documentation Migration

#### 4.1 README.md Structure
```markdown
# himalaya.nvim

Advanced email client for Neovim using the [himalaya](https://github.com/soywod/himalaya) CLI.

## Features

- 📧 **Full Email Management**: Read, compose, send, and organize emails
- 📝 **Advanced Draft System**: Auto-save, sync, and recovery
- 🎨 **Rich UI**: Sidebar, composer, and preview windows
- 🔄 **Smart Sync**: Async synchronization with retry logic
- 🎯 **Event-Driven**: Reactive architecture with 26+ event types
- 🛠️ **Extensible**: Comprehensive API and configuration options
- 🏥 **Health Checks**: Built-in diagnostics and troubleshooting

## Requirements

- NeoVim 0.8+
- [himalaya CLI](https://github.com/soywod/himalaya) installed and configured
- Optional: [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) for enhanced search

## Installation

### Using lazy.nvim

```lua
{
  'yourusername/himalaya.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim', -- Optional
  },
  event = 'VeryLazy',
  config = function()
    require('himalaya').setup({
      accounts = {
        gmail = {
          email = "your-email@gmail.com",
          -- ... see configuration section
        }
      }
    })
  end,
}
```

## Configuration

[Detailed configuration documentation]

## Usage

[Usage examples and commands]

## API Reference

[Complete API documentation]
```

#### 4.2 Vim Help Documentation
Create `doc/himalaya.txt`:
```
*himalaya.txt*           Advanced email client for Neovim using himalaya CLI

Author: Your Name <your-email@example.com>
License: MIT
Homepage: https://github.com/yourusername/himalaya.nvim

==============================================================================
CONTENTS                                                     *himalaya-contents*

1. Introduction ........................... |himalaya-introduction|
2. Installation ........................... |himalaya-installation|
3. Configuration .......................... |himalaya-configuration|
4. Commands ............................... |himalaya-commands|
5. API Reference .......................... |himalaya-api|
6. Troubleshooting ........................ |himalaya-troubleshooting|

==============================================================================
INTRODUCTION                                             *himalaya-introduction*

Himalaya.nvim provides a comprehensive email client experience within Neovim,
built on top of the powerful himalaya CLI tool.

[Continue with detailed help documentation]
```

### Phase 5: Testing Migration

#### 5.1 Migration Script
Create `scripts/migrate.lua`:
```lua
#!/usr/bin/env lua

-- Migration script to update require paths
local function update_file(filepath)
  local file = io.open(filepath, "r")
  if not file then
    return false
  end
  
  local content = file:read("*all")
  file:close()
  
  -- Update require paths
  content = content:gsub(
    "require%('neotex%.plugins%.tools%.himalaya%.([^']+)'%)",
    "require('himalaya.%1')"
  )
  
  -- Update notification requires
  content = content:gsub(
    "require%('neotex%.util%.notifications'%)",
    "require('himalaya.vendor.notifications')"
  )
  
  file = io.open(filepath, "w")
  if not file then
    return false
  end
  
  file:write(content)
  file:close()
  
  return true
end

-- Process all Lua files
local function migrate_directory(dir)
  local handle = io.popen("find " .. dir .. " -name '*.lua'")
  if not handle then
    return
  end
  
  for filepath in handle:lines() do
    if update_file(filepath) then
      print("Updated: " .. filepath)
    else
      print("Failed: " .. filepath)
    end
  end
  
  handle:close()
end

-- Run migration
migrate_directory("lua/himalaya/")
print("Migration complete!")
```

#### 5.2 Testing in Development
Before publishing, test the migration:

1. **Create test configuration**:
```lua
-- Test in development nvim config
{
  dir = "/path/to/himalaya.nvim", -- Local development path
  name = "himalaya.nvim",
  config = function()
    require('himalaya').setup({
      -- Test configuration
    })
  end,
}
```

2. **Run health checks**:
```vim
:checkhealth himalaya
```

3. **Test all commands**:
```vim
:HimalayaSetup
:HimalayaOpenSidebar
:HimalayaStatus
```

### Phase 6: Publishing

#### 6.1 Repository Preparation
```bash
# Tag first release
git tag -a v1.0.0 -m "Initial release"
git push origin v1.0.0

# Create GitHub release
gh release create v1.0.0 --title "v1.0.0 - Initial Release" --notes "First stable release of himalaya.nvim"
```

#### 6.2 Plugin Registration
- Submit to [awesome-neovim](https://github.com/rockerBOO/awesome-neovim)
- Create entry in [neovimcraft.com](https://neovimcraft.com)
- Announce in relevant communities

### Phase 7: User Migration

#### 7.1 Update User Configuration
Replace current embedded configuration:
```lua
-- OLD: Remove this from user config
-- No longer needed - plugin is now external

-- NEW: Add standard plugin installation
{
  'yourusername/himalaya.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
  },
  event = 'VeryLazy',
  config = function()
    require('himalaya').setup({
      -- Move existing configuration here
    })
  end,
}
```

#### 7.2 Clean Up Embedded Version
```lua
-- In neotex bootstrap.lua - remove tools loading:
-- OLD:
if tools_ok and type(tools_plugins) == "table" then
  vim.list_extend(plugins, tools_plugins)
end

-- Remove himalaya directory from:
-- lua/neotex/plugins/tools/himalaya/
```

## Benefits of Migration

### For Users
- **Standard Installation**: Use familiar lazy.nvim plugin management
- **Easier Updates**: Automatic updates via plugin manager
- **Better Documentation**: Proper vim help integration
- **Reduced Config Size**: Smaller NeoVim configuration
- **Wider Compatibility**: Works with any NeoVim setup

### For Development
- **Focused Repository**: Dedicated repo for email functionality
- **Better Testing**: CI/CD pipeline for automated testing
- **Community Contributions**: Easier for others to contribute
- **Version Management**: Proper semantic versioning
- **Issue Tracking**: GitHub issues for bug reports and features

### For Maintenance
- **Cleaner Separation**: Clear boundary between personal config and plugin
- **Independent Releases**: Plugin updates don't require config changes
- **Better Documentation**: Centralized docs and help system
- **Easier Debugging**: Users can report issues with specific versions

## Migration Checklist

### Pre-Migration
- [ ] Backup current configuration
- [ ] Document current customizations
- [ ] Test all functionality works correctly
- [ ] Create GitHub repository
- [ ] Set up basic repository structure

### Migration Process
- [ ] Copy all plugin files to new repository
- [ ] Update all require paths (automated via script)
- [ ] Handle notification system dependency
- [ ] Create proper plugin entry point
- [ ] Write comprehensive documentation
- [ ] Create vim help files
- [ ] Set up health check integration

### Testing Phase
- [ ] Test installation from local directory
- [ ] Verify all commands work correctly
- [ ] Test health checks
- [ ] Validate configuration system
- [ ] Test with clean NeoVim installation

### Publishing
- [ ] Create initial git tag and release
- [ ] Publish to GitHub
- [ ] Submit to plugin directories
- [ ] Update personal configuration to use external plugin
- [ ] Remove embedded version from personal config

### Post-Migration
- [ ] Monitor for issues
- [ ] Update documentation based on user feedback
- [ ] Set up CI/CD for automated testing
- [ ] Create contribution guidelines

## Conclusion

Migrating the Himalaya plugin to a standalone repository will improve maintainability, user experience, and community adoption. The comprehensive feature set and robust architecture make it an excellent candidate for a standalone Neovim plugin.

The migration process is straightforward but requires careful attention to dependency management and path updates. The resulting plugin will be a powerful addition to the Neovim ecosystem, providing professional-grade email functionality within the editor.