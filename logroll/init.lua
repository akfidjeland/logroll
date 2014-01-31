require 'paths'
require 'os'
require 'io'
require 'string'

require 'fn'
require 'pprint'

logroll = {}

local DEFAULT_LEVEL = 'INFO'
local LOG_LEVELS = {'DEBUG', 'INFO', 'WARN', 'ERROR'}

for i, label in ipairs(LOG_LEVELS) do
    logroll[label] = i
end
logroll.levels = LOG_LEVELS


local function default_formatter(level, ...)
    local msg = nil

    if #{...} > 1 then
        msg = string.format(({...})[1], unpack(fn.rest({...})))
    else
        msg = pprint.pretty_string(({...})[1])
    end

    return string.format("[%s - %s] - %s\n", LOG_LEVELS[level], os.date("%Y_%m_%d_%X"), msg)
end


local function default_writer(logger, level, ...)
    if level >= logger.level then
        logger.file:write(logger.formatter(level, unpack({...})))
    end
end


local function make_logger(file, options)
    local logger = {options   = options,
                    file      = file,
                    formatter = options.formatter or default_formatter,
                    writer    = options.writer or default_writer,
                    level     = options.level or logroll[DEFAULT_LEVEL],
                }

    return fn.reduce(function(lg, level)
        lg[string.lower(level)] = fn.partial(logger.writer, logger, logroll[level])
        return lg
    end,
    logger, LOG_LEVELS)
end

-- A no-op logger
function logroll.null_logger()
    local noop = function(...) end
    local options = {formatter = noop, writer = noop}
    return make_logger(nil, options)
end

-- A simple logger to print to STDIO.
function logroll.print_logger(options)
    local options = options or {}
    return make_logger(io.stdout, options)
end


-- A logger that prints to a file.
function logroll.file_logger(path, options)
    local options = options or {}

    if options.file_timestamp then
        -- append timestamp to create unique log file
        path = path .. '-'..os.date("%Y_%m_%d_%X")
    end

    os.execute('mkdir -p "' .. paths.dirname(path) .. '"')

    return make_logger(io.open(path, 'w'), options)
end


-- A logger that combines several other loggers
function logroll.combine(...)

    local joint = {
        subloggers = {...}
    }

    for _,level in ipairs(LOG_LEVELS) do
        local fname = string.lower(level)
        joint[fname] = function(...)
            for _,lg in ipairs(joint.subloggers) do
                lg[fname](...)
            end
        end
    end

    return joint
end

-- Setup logging functions accessible globally through logroll
function logroll.set_global_logger(logger)
    for _,level in ipairs(LOG_LEVELS) do
        local fname = string.lower(level)
        logroll[fname] = logger[fname]
    end
end

-- Default to a print logger
logroll.set_global_logger(logroll.print_logger())

