-- Himalaya Maildir Module
-- Minimal implementation for draft storage in Maildir format

local M = {}

-- Dependencies
local logger = require('neotex.plugins.tools.himalaya.core.logger')
local notify = require('neotex.util.notifications')

-- Generate a unique Maildir filename with appropriate flags
-- @param flags table Array of single-character flags (e.g., {'D'} for draft)
-- @return string Maildir-compliant filename
function M.generate_filename(flags)
  -- Maildir filename format: <timestamp>.<process_id>_<unique>.<hostname>,<info>:<flags>
  local timestamp = os.time()
  local hrtime = vim.loop.hrtime()
  local pid = vim.loop.getpid()
  local hostname = vim.loop.os_gethostname() or 'localhost'
  
  -- Convert hrtime to milliseconds to avoid scientific notation
  -- hrtime is in nanoseconds, divide by 1,000,000 to get milliseconds
  local hrtime_ms = math.floor(hrtime / 1000000)
  
  -- Build info string (size=0, we'll update after write)
  local info = "S=0"
  
  -- Build flags string
  local flag_str = ""
  if flags and #flags > 0 then
    table.sort(flags)
    flag_str = table.concat(flags, "")
  end
  
  -- Construct filename compatible with mbsync format
  -- Using milliseconds timestamp and pid for uniqueness
  local filename = string.format(
    "%d.%d_%d.%s,%s:2,%s",
    timestamp,
    hrtime_ms,
    pid,
    hostname,
    info,
    flag_str
  )
  
  return filename
end

-- Parse a Maildir filename to extract metadata
-- @param filename string Maildir filename
-- @return table|nil Parsed metadata or nil if invalid
function M.parse_filename(filename)
  -- Match mbsync/Maildir pattern: timestamp.hrtime_unique.hostname,info:2,flags
  -- Examples: 
  --   mbsync: "1752088678.388349_6.nandi,U=1:2,S"
  --   standard: "1234567890.123_456.hostname,S=1024:2,RS"
  local pattern = "^(%d+)%.([^_]+)_([^%.]+)%.([^,]+),(.+)$"
  local timestamp, hrtime, unique, hostname, info_and_flags = filename:match(pattern)
  
  if not timestamp then
    -- Try simpler pattern: timestamp.unique.hostname[:2,flags]
    pattern = "^(%d+)%.([^%.]+)%.([^:,]+)(.*)$"
    timestamp, unique, hostname, info_and_flags = filename:match(pattern)
    if timestamp then
      hrtime = unique  -- Use unique as hrtime for backward compatibility
      info_and_flags = info_and_flags:gsub("^:", "")  -- Remove leading colon if present
      if info_and_flags == "" then
        info_and_flags = "2,"  -- Default to empty flags
      end
    else
      -- Try even simpler pattern: timestamp.unique[:2,flags]
      pattern = "^(%d+)%.([^:,]+)(.*)$"
      timestamp, unique, info_and_flags = filename:match(pattern)
      if timestamp then
        hrtime = unique
        hostname = "localhost"  -- Default hostname
        info_and_flags = info_and_flags:gsub("^:", "")  -- Remove leading colon if present
        if info_and_flags == "" then
          info_and_flags = "2,"  -- Default to empty flags
        end
      else
        return nil
      end
    end
  end
  
  -- Parse info and flags section - handle both ":2," and direct format
  local info, flags
  if info_and_flags:match("^(.+):2,(.*)$") then
    -- Standard format with :2, separator
    info, flags = info_and_flags:match("^(.+):2,(.*)$")
  else
    -- Simple format - assume everything before last char is info, last char is flags
    local last_comma = info_and_flags:find(",[^,]*$")
    if last_comma then
      info = info_and_flags:sub(1, last_comma - 1)
      flags = info_and_flags:sub(last_comma + 1)
    else
      -- No comma - treat as all info, no flags
      info = info_and_flags
      flags = ""
    end
  end
  
  -- Parse info section - handle both S=size and U=uid formats
  local size = 0
  local uid = nil
  if info then
    size = tonumber(info:match("S=(%d+)")) or 0
    uid = tonumber(info:match("U=(%d+)"))
  end
  
  -- Parse flags into table (both array and hash for compatibility)
  local flag_table = {}
  if flags and flags ~= "" then
    for i = 1, #flags do
      local flag = flags:sub(i, i)
      flag_table[flag] = true  -- Hash access
      table.insert(flag_table, flag)  -- Array access for vim.tbl_contains
    end
  end
  
  return {
    timestamp = tonumber(timestamp),
    hrtime = hrtime, -- Keep hrtime instead of pid for mbsync files
    unique = unique,
    hostname = hostname,
    size = size,
    uid = uid, -- Add UID for mbsync files
    flags = flag_table,
    filename = filename
  }
end

-- Read email headers from a file
-- @param filepath string Path to the email file
-- @return table|nil Headers table or nil on error
function M.read_headers(filepath)
  local file = io.open(filepath, "r")
  if not file then
    return nil
  end
  
  local headers = {}
  local current_header = nil
  local current_value = nil
  
  for line in file:lines() do
    -- Empty line marks end of headers
    if line == "" then
      -- Save last header if any
      if current_header then
        headers[current_header:lower()] = current_value
      end
      break
    end
    
    -- Check if this is a continuation line (starts with whitespace)
    if line:match("^%s") and current_header then
      -- Append to current header
      current_value = current_value .. " " .. line:match("^%s*(.*)$")
    else
      -- Save previous header if any
      if current_header then
        headers[current_header:lower()] = current_value
      end
      
      -- Parse new header
      local header, value = line:match("^([^:]+):%s*(.*)$")
      if header then
        current_header = header
        current_value = value
      else
        -- Invalid header line
        break
      end
    end
  end
  
  file:close()
  
  return headers
end

-- Atomically write content to a Maildir file
-- @param tmp_path string Path to tmp directory
-- @param target_path string Final path in new/ or cur/
-- @param content string Email content to write
-- @return boolean success
-- @return string|nil error message
function M.atomic_write(tmp_path, target_path, content)
  -- Generate temporary filename
  local tmp_filename = string.format("%d.%d.%s", 
    os.time(), 
    vim.loop.getpid(), 
    vim.loop.os_gethostname() or 'localhost'
  )
  local tmp_file = tmp_path .. "/" .. tmp_filename
  
  -- Write to tmp file
  local file = io.open(tmp_file, "w")
  if not file then
    return false, "Failed to create temporary file: " .. tmp_file
  end
  
  local ok, write_err = file:write(content)
  file:close()
  
  if not ok then
    vim.fn.delete(tmp_file)
    return false, "Failed to write content: " .. (write_err or "unknown error")
  end
  
  -- Atomically move to target
  local rename_ok = vim.loop.fs_rename(tmp_file, target_path)
  if not rename_ok then
    vim.fn.delete(tmp_file)
    return false, "Failed to move file to target: " .. target_path
  end
  
  logger.debug("Maildir atomic write successful", {
    tmp = tmp_file,
    target = target_path,
    size = #content
  })
  
  return true
end

-- List messages in a Maildir folder
-- @param maildir_path string Path to the Maildir folder
-- @param filter table|nil Optional filter for flags (e.g., {D = true} for drafts)
-- @return table Array of message info
function M.list_messages(maildir_path, filter)
  local messages = {}
  
  -- Check both cur/ and new/ subdirectories
  local subdirs = {'cur', 'new'}
  
  for _, subdir in ipairs(subdirs) do
    local dir_path = maildir_path .. '/' .. subdir
    
    -- Check if directory exists
    if vim.fn.isdirectory(dir_path) == 1 then
      -- List all files
      local files = vim.fn.readdir(dir_path)
      
      for _, filename in ipairs(files) do
        -- Skip non-maildir files (., .., etc)
        if not filename:match('^%.') then
          -- Parse the filename
          local metadata = M.parse_filename(filename)
          
          if metadata then
            -- Apply filter if provided
            local include = true
            if filter then
              for flag, required in pairs(filter) do
                if required and not metadata.flags[flag] then
                  include = false
                  break
                end
              end
            end
            
            if include then
              table.insert(messages, {
                path = dir_path .. '/' .. filename,
                filename = filename,
                timestamp = metadata.timestamp,
                size = metadata.size,
                flags = metadata.flags,
                subdir = subdir
              })
            end
          end
        end
      end
    end
  end
  
  return messages
end

-- Check if a directory is a valid Maildir
-- @param path string Path to check
-- @return boolean true if valid Maildir
function M.is_maildir(path)
  if vim.fn.isdirectory(path) == 0 then
    return false
  end
  
  -- Check for required subdirectories
  local required = {'cur', 'new', 'tmp'}
  for _, subdir in ipairs(required) do
    if vim.fn.isdirectory(path .. '/' .. subdir) == 0 then
      return false
    end
  end
  
  return true
end

-- Create a Maildir structure
-- @param path string Path where to create the Maildir
-- @return boolean success
-- @return string|nil error message
function M.create_maildir(path)
  -- Create main directory
  vim.fn.mkdir(path, 'p')
  
  -- Create subdirectories
  local subdirs = {'cur', 'new', 'tmp'}
  for _, subdir in ipairs(subdirs) do
    local subpath = path .. '/' .. subdir
    local ok = vim.fn.mkdir(subpath, 'p')
    if ok ~= 1 then
      return false, "Failed to create " .. subpath
    end
  end
  
  return true
end

-- Get the size of a file and update its filename if needed
-- @param filepath string Path to the email file
-- @return number size in bytes
function M.update_size(filepath)
  local stat = vim.loop.fs_stat(filepath)
  if not stat then
    return filepath  -- Return unchanged path if can't stat
  end
  
  local size = stat.size
  local dir = vim.fn.fnamemodify(filepath, ":h")
  local filename = vim.fn.fnamemodify(filepath, ":t")
  
  -- Parse current filename
  local metadata = M.parse_filename(filename)
  if not metadata then
    return filepath  -- Return unchanged path if can't parse
  end
  
  -- Update size in filename if different
  if metadata.size ~= size then
    -- Build new info string with updated size
    local new_info = string.format("S=%d", size)
    
    -- Build flags string
    local flag_str = ""
    for flag, _ in pairs(metadata.flags) do
      flag_str = flag_str .. flag
    end
    if flag_str ~= "" then
      local flags = {}
      for i = 1, #flag_str do
        table.insert(flags, flag_str:sub(i, i))
      end
      table.sort(flags)
      flag_str = table.concat(flags, "")
    end
    
    -- Construct new filename (use hrtime or pid based on what's available)
    local new_filename = string.format(
      "%d.%s_%s.%s,%s:2,%s",
      metadata.timestamp,
      metadata.hrtime or metadata.pid or "0",
      metadata.unique,
      metadata.hostname,
      new_info,
      flag_str
    )
    
    local new_filepath = dir .. "/" .. new_filename
    
    -- Rename file
    if vim.loop.fs_rename(filepath, new_filepath) then
      logger.debug("Updated Maildir filename size", {
        old = filename,
        new = new_filename,
        size = size
      })
      return new_filepath
    end
  end
  
  return filepath
end

-- Check if a path is a valid Maildir directory
-- @param path string Path to check
-- @return boolean is_valid
function M.is_maildir(path)
  -- A valid Maildir has cur/, new/, and tmp/ subdirectories
  local required_dirs = {"cur", "new", "tmp"}
  
  for _, dir in ipairs(required_dirs) do
    local subdir = path .. "/" .. dir
    local stat = vim.loop.fs_stat(subdir)
    if not stat or stat.type ~= "directory" then
      return false
    end
  end
  
  return true
end

-- Create a Maildir directory structure
-- @param path string Path where to create Maildir
-- @return boolean success
-- @return string|nil error message
function M.create_maildir(path)
  -- Create main directory
  vim.fn.mkdir(path, "p")
  
  -- Create subdirectories
  local subdirs = {"cur", "new", "tmp"}
  for _, subdir in ipairs(subdirs) do
    local subpath = path .. "/" .. subdir
    local ok = vim.fn.mkdir(subpath, "p")
    if ok ~= 1 and not vim.loop.fs_stat(subpath) then
      return false, "Failed to create " .. subdir .. " directory"
    end
  end
  
  logger.info("Created Maildir structure", { path = path })
  return true
end

-- List all messages in a Maildir folder
-- @param path string Path to Maildir folder
-- @param flags_filter table|nil Optional filter for flags (e.g., {D=true} for drafts)
-- @return table Array of message info
function M.list_messages(path, flags_filter)
  local messages = {}
  
  -- Check both new/ and cur/ directories
  for _, subdir in ipairs({"new", "cur"}) do
    local dir_path = path .. "/" .. subdir
    local handle = vim.loop.fs_scandir(dir_path)
    
    if handle then
      while true do
        local name, type = vim.loop.fs_scandir_next(handle)
        if not name then break end
        
        if type == "file" then
          local metadata = M.parse_filename(name)
          if metadata then
            -- Apply flags filter if provided
            local include = true
            if flags_filter then
              for flag, required in pairs(flags_filter) do
                if required and not metadata.flags[flag] then
                  include = false
                  break
                end
              end
            end
            
            if include then
              metadata.path = dir_path .. "/" .. name
              metadata.subdir = subdir
              table.insert(messages, metadata)
            end
          end
        end
      end
    end
  end
  
  -- Sort by timestamp (newest first)
  table.sort(messages, function(a, b)
    return a.timestamp > b.timestamp
  end)
  
  return messages
end

return M