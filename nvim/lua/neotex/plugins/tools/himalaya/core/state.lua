-- State management module
-- Centralized state tracking for the Himalaya plugin
-- Version 2: Added versioning, migration support, and validation

local M = {}

-- Default state schema
local default_state = {
  -- Sync state
  sync = {
    status = "idle", -- idle, running, error
    last_sync = nil,
    last_error = nil,
    start_time = nil,
    current_channel = nil,
  },
  
  -- OAuth state
  oauth = {
    last_refresh = 0,
    refresh_in_progress = false,
    last_check = 0,
  },
  
  -- UI state
  ui = {
    sidebar_open = false,
    reader_open = false,
    current_folder = "INBOX",
    current_email_id = nil,
    selected_emails = {},
    -- UI view state (from ui/state.lua)
    current_account = nil,
    current_page = 1,
    page_size = 25,
    total_emails = 0,
    selected_email = nil,
    sidebar_width = 50,
    sidebar_position = 'left',
    last_query = nil,
    last_search_results = nil,
    window_positions = {},
    session_timestamp = nil,
  },
  
  -- Selection state (separate from persisted state)
  selection = {
    selected_emails = {}, -- Set of email IDs
    selection_mode = false, -- Toggle for selection mode
  },
  
  -- Email cache
  cache = {
    folders = {},
    emails = {},
    last_update = {},
  },
  
  -- Process state
  processes = {
    sync_job_id = nil,
    reader_job_id = nil,
  },
  
  -- Folder statistics
  folders = {
    counts = {}, -- Structure: account -> folder -> count
    last_updated = {}, -- Structure: account -> folder -> timestamp
  },
  
  -- Draft state
  draft = {
    -- Active drafts
    drafts = {}, -- Map of buffer_id -> draft_data
    
    -- Draft metadata
    metadata = {
      total_count = 0,
      last_sync = nil,
      sync_in_progress = false,
    },
    
    -- Recovery data
    recovery = {
      unsaved_buffers = {}, -- Buffers with unsaved changes
      last_recovery = nil,
      pending_syncs = {}, -- Queue of drafts waiting to sync
    },
  },
}

-- Current state (initialized with defaults)
M.state = vim.tbl_deep_extend("force", {}, default_state)

-- Validate state structure
function M.validate_state(state)
  -- Validate structure types
  local required_tables = {
    "sync", "oauth", "ui", "selection", 
    "cache", "processes", "folders", "draft"
  }
  
  for _, key in ipairs(required_tables) do
    if state[key] and type(state[key]) ~= "table" then
      return false, string.format("Invalid type for %s: expected table, got %s", key, type(state[key]))
    end
  end
  
  return true
end

-- Cleanup stale entries
function M.cleanup_stale_entries()
  local now = os.time()
  local stale_threshold = 7 * 24 * 60 * 60 -- 7 days
  
  -- Clean old email cache
  if M.state.cache and M.state.cache.emails then
    for id, email in pairs(M.state.cache.emails) do
      if email.cached_at and (now - email.cached_at) > stale_threshold then
        M.state.cache.emails[id] = nil
      end
    end
  end
  
  -- Clean old folder update timestamps
  if M.state.folders and M.state.folders.last_updated then
    for account, folders in pairs(M.state.folders.last_updated) do
      for folder, timestamp in pairs(folders) do
        if (now - timestamp) > stale_threshold then
          M.state.folders.last_updated[account][folder] = nil
        end
      end
    end
  end
end

-- Get a state value by path (e.g., "sync.status")
function M.get(path, default)
  local value = M.state
  for part in path:gmatch("[^.]+") do
    if type(value) ~= "table" then
      return default
    end
    value = value[part]
  end
  return value ~= nil and value or default
end

-- Set a state value by path
function M.set(path, value)
  local state = M.state
  local parts = {}
  for part in path:gmatch("[^.]+") do
    table.insert(parts, part)
  end
  
  -- Navigate to parent
  for i = 1, #parts - 1 do
    local part = parts[i]
    if type(state[part]) ~= "table" then
      state[part] = {}
    end
    state = state[part]
  end
  
  -- Set the value
  state[parts[#parts]] = value
end

-- Update multiple state values at once
function M.update(updates)
  for path, value in pairs(updates) do
    M.set(path, value)
  end
end

-- Clear a state section
function M.clear(path)
  M.set(path, {})
end

-- Reset all state
function M.reset()
  M.state = vim.tbl_deep_extend("force", {}, default_state)
end

-- Reset to defaults (for error recovery)
function M.reset_to_defaults()
  local logger = require("neotex.plugins.tools.himalaya.core.logger")
  logger.warn("Resetting state to defaults due to corruption")
  
  M.reset()
  return true
end

-- Initialize state with validation
function M.init(existing_state)
  if existing_state then
    -- Validate existing state
    local valid, error_msg = M.validate_state(existing_state)
    if not valid then
      local logger = require("neotex.plugins.tools.himalaya.core.logger")
      logger.error("State validation failed: " .. error_msg)
      M.reset()
      return
    end
    
    M.state = existing_state
  else
    M.reset()
  end
  
  -- Cleanup stale entries on init
  M.cleanup_stale_entries()
end

-- Sync-specific helpers
function M.is_syncing()
  return M.get("sync.status") == "running"
end

function M.set_sync_running(channel)
  M.update({
    ["sync.status"] = "running",
    ["sync.start_time"] = os.time(),
    ["sync.current_channel"] = channel,
  })
end

function M.set_sync_complete(success, error_msg)
  M.update({
    ["sync.status"] = success and "idle" or "error",
    ["sync.last_sync"] = os.time(),
    ["sync.last_error"] = error_msg,
    ["sync.current_channel"] = nil,
  })
end

-- UI-specific helpers
function M.set_current_folder(folder)
  -- Don't allow nil or empty folder
  if not folder or folder == '' then
    folder = 'INBOX'
  end
  M.set("ui.current_folder", folder)
end

function M.get_current_folder()
  local folder = M.get("ui.current_folder", "INBOX")
  -- Ensure we never return nil or empty string
  if not folder or folder == '' then
    folder = 'INBOX'
  end
  return folder
end

function M.set_current_email(email_id)
  M.set("ui.current_email_id", email_id)
end

function M.get_current_email()
  return M.get("ui.current_email_id")
end

-- UI view state helpers (from ui/state.lua)
function M.set_current_account(account)
  M.set("ui.current_account", account)
end

function M.get_current_account()
  return M.get("ui.current_account")
end

function M.get_current_page()
  return M.get("ui.current_page", 1)
end

function M.set_current_page(page)
  M.set("ui.current_page", page)
end

function M.get_page_size()
  return M.get("ui.page_size", 25)
end

function M.set_total_emails(count)
  M.set("ui.total_emails", count)
end

function M.get_total_emails()
  return M.get("ui.total_emails", 0)
end

function M.set_selected_email(email_id)
  M.set("ui.selected_email", email_id)
end

function M.get_selected_email()
  return M.get("ui.selected_email")
end

function M.set_sidebar_width(width)
  M.set("ui.sidebar_width", width)
end

function M.get_sidebar_width()
  return M.get("ui.sidebar_width", 50)
end

function M.set_sidebar_position(position)
  if position == 'left' or position == 'right' then
    M.set("ui.sidebar_position", position)
    return true
  end
  return false
end

function M.get_sidebar_position()
  return M.get("ui.sidebar_position", 'left')
end

function M.set_last_query(query)
  M.set("ui.last_query", query)
end

function M.get_last_query()
  return M.get("ui.last_query")
end

function M.set_search_results(results)
  M.set("ui.last_search_results", results)
end

function M.get_search_results()
  return M.get("ui.last_search_results")
end

function M.set_window_position(email_id, position)
  local positions = M.get("ui.window_positions", {})
  positions[email_id] = position
  M.set("ui.window_positions", positions)
end

function M.get_window_position(email_id)
  local positions = M.get("ui.window_positions", {})
  return positions[email_id]
end

function M.clear_window_positions()
  M.set("ui.window_positions", {})
end

-- Cache helpers
function M.cache_emails(folder, emails)
  M.set("cache.emails." .. folder, emails)
  M.set("cache.last_update." .. folder, os.time())
end

function M.get_cached_emails(folder)
  return M.get("cache.emails." .. folder, {})
end

function M.is_cache_fresh(folder, max_age)
  max_age = max_age or 300 -- 5 minutes default
  local last_update = M.get("cache.last_update." .. folder, 0)
  return (os.time() - last_update) < max_age
end

-- Selection state management functions

-- Toggle selection mode
function M.toggle_selection_mode()
  local current = M.get("selection.selection_mode", false)
  M.set("selection.selection_mode", not current)
  return M.get("selection.selection_mode")
end

-- Check if email is selected
function M.is_email_selected(email_id)
  local selected = M.get("selection.selected_emails", {})
  return selected[email_id] ~= nil
end

-- Toggle email selection
function M.toggle_email_selection(email_id, email_data)
  local selected = M.get("selection.selected_emails", {})
  if selected[email_id] then
    selected[email_id] = nil
  else
    selected[email_id] = email_data
  end
  M.set("selection.selected_emails", selected)
end

-- Clear all selections
function M.clear_selection()
  M.set("selection.selected_emails", {})
end

-- Get all selected emails
function M.get_selected_emails()
  local selected_map = M.get("selection.selected_emails", {})
  local selected = {}
  for id, email in pairs(selected_map) do
    table.insert(selected, email)
  end
  return selected
end

-- Get selection count
function M.get_selection_count()
  local selected = M.get("selection.selected_emails", {})
  local count = 0
  for _ in pairs(selected) do
    count = count + 1
  end
  return count
end

-- Check if in selection mode
function M.is_selection_mode()
  return M.get("selection.selection_mode", false)
end

-- Folder count management functions

-- Set email count for a specific folder
function M.set_folder_count(account, folder, count)
  if not account or not folder then return end
  
  -- Ensure count is a number
  count = tonumber(count) or 0
  
  local logger = require('neotex.plugins.tools.himalaya.core.logger')
  logger.debug(string.format('set_folder_count called: account=%s, folder=%s, count=%d', 
    account, folder, count))
  
  -- Initialize structure if needed
  local counts = M.get("folders.counts", {})
  if not counts[account] then
    counts[account] = {}
  end
  
  counts[account][folder] = count
  M.set("folders.counts", counts)
  
  -- Update timestamp
  local timestamps = M.get("folders.last_updated", {})
  if not timestamps[account] then
    timestamps[account] = {}
  end
  local old_timestamp = timestamps[account][folder]
  timestamps[account][folder] = os.time()
  M.set("folders.last_updated", timestamps)
  
  logger.debug(string.format('Updated timestamp for %s/%s: old=%s, new=%d', 
    account, folder, tostring(old_timestamp), timestamps[account][folder]))
  
  -- Trigger immediate UI update if this is the current folder
  local current_account = M.get("ui.current_account")
  local current_folder = M.get("ui.current_folder")
  if account == current_account and folder == current_folder then
    -- Import here to avoid circular dependencies
    local ok, manager = pcall(require, 'neotex.plugins.tools.himalaya.sync.manager')
    if ok and manager.notify_ui_update then
      manager.notify_ui_update()
    end
  end
end

-- Get email count for a specific folder
function M.get_folder_count(account, folder)
  if not account or not folder then return nil end
  
  local counts = M.get("folders.counts", {})
  if counts[account] and counts[account][folder] then
    return counts[account][folder]
  end
  return nil
end

-- Get all folder counts for an account
function M.get_all_folder_counts(account)
  if not account then return {} end
  
  local counts = M.get("folders.counts", {})
  return counts[account] or {}
end

-- Get folder count age in seconds
function M.get_folder_count_age(account, folder)
  if not account or not folder then return nil end
  
  local timestamps = M.get("folders.last_updated", {})
  if timestamps[account] and timestamps[account][folder] then
    return os.time() - timestamps[account][folder]
  end
  return nil
end

-- Session persistence

-- State file path
local function get_state_file()
  local data_dir = vim.fn.stdpath('data') .. '/himalaya'
  vim.fn.mkdir(data_dir, 'p')
  return data_dir .. '/state.json'
end

-- Save state to disk
function M.save()
  local state_file = get_state_file()
  
  -- Add timestamp
  M.set("ui.session_timestamp", os.time())
  
  -- Create a subset of state to persist (UI state, folder counts, and draft metadata)
  local persist_state = {
    ui = M.state.ui,
    folders = M.state.folders,
    draft = {
      metadata = M.state.draft.metadata,
      recovery = M.state.draft.recovery,
      -- Store draft metadata, not full content
      drafts = (function()
        local draft_array = {}
        local drafts_table = M.state.draft.drafts or {}
        
        -- Only iterate over non-numeric keys to avoid mixed key issues
        for key, draft in pairs(drafts_table) do
          if type(key) == "string" and type(draft) == "table" then
            table.insert(draft_array, {
              id = draft.id,
              local_id = draft.local_id,
              remote_id = draft.remote_id,
              subject = draft.metadata and draft.metadata.subject or nil,
              to = draft.metadata and draft.metadata.to or nil,
              modified = draft.modified,
              synced = draft.synced,
              local_path = draft.local_path,
              account = draft.account,
            })
          end
        end
        return draft_array
      end)()
    }
  }
  
  local encoded = vim.fn.json_encode(persist_state)
  
  local file = io.open(state_file, 'w')
  if file then
    file:write(encoded)
    file:close()
    return true
  else
    local notify = require('neotex.util.notifications')
    notify.himalaya('Failed to save Himalaya state', notify.categories.WARNING)
    return false
  end
end

-- Load state from disk
function M.load()
  local state_file = get_state_file()
  
  if vim.fn.filereadable(state_file) == 1 then
    local content = vim.fn.readfile(state_file)
    if #content > 0 then
      local ok, decoded = pcall(vim.fn.json_decode, content[1])
      if ok and type(decoded) == 'table' then
        -- Merge UI state, folder counts, and draft state
        if decoded.ui then
          M.state.ui = vim.tbl_extend('force', M.state.ui, decoded.ui)
        end
        if decoded.folders then
          M.state.folders = vim.tbl_extend('force', M.state.folders, decoded.folders)
        end
        if decoded.draft then
          M.state.draft = vim.tbl_extend('force', M.state.draft, decoded.draft)
        end
        return true
      else
        local notify = require('neotex.util.notifications')
        notify.himalaya('Failed to parse Himalaya state file', notify.categories.WARNING)
      end
    end
  end
  
  return false
end

-- Get session age in minutes
function M.get_session_age()
  local timestamp = M.get("ui.session_timestamp")
  if timestamp then
    return math.floor((os.time() - timestamp) / 60)
  end
  return nil
end

-- Check if state is fresh (less than 24 hours old)
function M.is_state_fresh()
  local age = M.get_session_age()
  return age and age < (24 * 60) -- 24 hours in minutes
end

-- Auto-save functionality
local auto_save_timer = nil

-- Start auto-save timer (saves every 5 minutes)
function M.start_auto_save(interval_minutes)
  interval_minutes = interval_minutes or 5
  local interval_ms = interval_minutes * 60 * 1000
  
  if auto_save_timer then
    auto_save_timer:stop()
    auto_save_timer:close()
  end
  
  auto_save_timer = vim.loop.new_timer()
  auto_save_timer:start(interval_ms, interval_ms, vim.schedule_wrap(function()
    M.save()
  end))
end

-- Stop auto-save timer
function M.stop_auto_save()
  if auto_save_timer then
    auto_save_timer:stop()
    auto_save_timer:close()
    auto_save_timer = nil
  end
end

-- Initialize state management
function M.init()
  -- Load existing state
  M.load()
  
  -- Start auto-save
  M.start_auto_save()
  
  -- Setup cleanup autocmd
  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = vim.api.nvim_create_augroup('HimalayaState', { clear = true }),
    callback = function()
      M.stop_auto_save()
      M.save()
    end,
    desc = 'Save Himalaya state on exit'
  })
end

-- Sync state with sidebar
function M.sync_with_sidebar()
  local ok, sidebar = pcall(require, 'neotex.plugins.tools.himalaya.ui.sidebar')
  if not ok then return end
  
  -- Update sidebar width from state
  local state_width = M.get("ui.sidebar_width")
  if state_width and state_width ~= sidebar.get_width() then
    sidebar.set_width(state_width)
  end
  
  -- Update sidebar position from state
  local state_position = M.get("ui.sidebar_position")
  if state_position and state_position ~= sidebar.config.position then
    sidebar.set_position(state_position)
  end
end

-- Check if initialized (for UI compatibility)
function M.is_initialized()
  return M.state ~= nil
end

-- Export state for debugging
function M.export_state()
  return vim.deepcopy(M.state)
end

-- Import state (for testing/debugging)
function M.import_state(new_state)
  if type(new_state) == 'table' then
    M.state = vim.tbl_extend('force', M.state, new_state)
    return true
  end
  return false
end

-- Debug helper
function M.dump()
  return vim.inspect(M.state)
end

-- Draft-specific state helpers

--- Get draft data by buffer ID
--- @param buffer_id number The buffer ID to look up
--- @return table|nil draft The draft data or nil if not found
function M.get_draft_by_buffer(buffer_id)
  return M.get("draft.drafts." .. tostring(buffer_id))
end

--- Store draft data for a buffer and update metadata
--- @param buffer_id number The buffer ID to associate with the draft
--- @param draft_data table The draft data containing:
---   - local_id: string Unique local identifier
---   - remote_id: string|nil Remote server ID (if synced)
---   - account: string Email account name
---   - metadata: table Subject, to, from, etc.
---   - modified: boolean Whether draft has unsaved changes
---   - synced: boolean Whether draft is synced with server
function M.set_draft(buffer_id, draft_data)
  M.set("draft.drafts." .. tostring(buffer_id), draft_data)
  M.set("draft.metadata.total_count", M.get_draft_count())
end

--- Remove draft data from state and update count
--- @param buffer_id number The buffer ID of the draft to remove
function M.remove_draft(buffer_id)
  M.set("draft.drafts." .. tostring(buffer_id), nil)
  M.set("draft.metadata.total_count", M.get_draft_count())
end

--- Get total number of active drafts
--- @return number count The number of drafts in state
function M.get_draft_count()
  local count = 0
  for _ in pairs(M.get("draft.drafts", {})) do
    count = count + 1
  end
  return count
end

--- Check if any draft sync operation is in progress
--- @return boolean syncing True if sync is in progress
function M.is_draft_syncing()
  return M.get("draft.metadata.sync_in_progress", false)
end

--- Update draft sync status and timestamp
--- @param in_progress boolean Whether sync is in progress
function M.set_draft_sync_status(in_progress)
  M.set("draft.metadata.sync_in_progress", in_progress)
  if not in_progress then
    M.set("draft.metadata.last_sync", os.time())
  end
end

--- Get all drafts with unsaved changes
--- @return table unsaved Map of buffer_id -> draft_info for unsaved drafts
function M.get_unsaved_drafts()
  return M.get("draft.recovery.unsaved_buffers", {})
end

--- Track a draft with unsaved changes for recovery
--- @param buffer_id number The buffer ID with unsaved changes
--- @param draft_info table Basic info about the draft:
---   - local_id: string Draft identifier
---   - subject: string Draft subject line
---   - timestamp: number When marked as unsaved
function M.add_unsaved_draft(buffer_id, draft_info)
  local unsaved = M.get("draft.recovery.unsaved_buffers", {})
  unsaved[tostring(buffer_id)] = draft_info
  M.set("draft.recovery.unsaved_buffers", unsaved)
end

--- Remove draft from unsaved tracking (after successful sync)
--- @param buffer_id number The buffer ID to remove from tracking
function M.remove_unsaved_draft(buffer_id)
  local unsaved = M.get("draft.recovery.unsaved_buffers", {})
  unsaved[tostring(buffer_id)] = nil
  M.set("draft.recovery.unsaved_buffers", unsaved)
end

--- Get queue of drafts waiting to be synced
--- @return table pending Array of draft info waiting for sync
function M.get_pending_syncs()
  return M.get("draft.recovery.pending_syncs", {})
end

--- Add draft to sync queue for batch processing
--- @param draft_info table Draft information to queue:
---   - local_id: string Draft identifier
---   - account: string Email account
---   - subject: string Draft subject
function M.add_pending_sync(draft_info)
  local pending = M.get("draft.recovery.pending_syncs", {})
  table.insert(pending, draft_info)
  M.set("draft.recovery.pending_syncs", pending)
end

--- Clear all pending sync operations
function M.clear_pending_syncs()
  M.set("draft.recovery.pending_syncs", {})
end

--- Update last recovery timestamp
function M.set_last_recovery()
  M.set("draft.recovery.last_recovery", os.time())
end

--- Get all active drafts from state
--- @return table drafts Map of buffer_id -> draft_data
function M.get_all_drafts()
  return M.get("draft.drafts", {})
end

return M