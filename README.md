# LogRoll

A simple logging library for Lua with support for log levels, and printing to
STDIO or files.

## Usage

Log to standard out:

     require 'logroll'
     log = logroll.print_logger()
     log.error("Testing...")  -- => [ERROR - 2012_08_10_11:42:06] - Testing...
     log.warn("Testing...")   -- => [WARN - 2012_08_10_11:42:08] - Testing...
     log.info("Testing...")   -- => [INFO - 2012_08_10_11:42:15] - Testing...

     log.debug("Testing...")  -- => <nothing>
     log.level = logroll.DEBUG
     log.debug("Testing...")  -- => [DEBUG - 2012_08_10_11:42:25] - Testing...

or to a file:

    require 'logroll'
    flog = logroll.file_logger('logs/testing.log')
    flog.debug("Testing file write.")

or to both:

    require 'logroll'
    flog = logroll.file_logger('logs/testing.log')
    plog = logroll.print_logger()
    log = logroll.combine(flog, plog)
    log.debug("Testing file write.")

Alternatively, you can add a global logger accessible directly from the logroll module:

    require 'logroll'
    logroll.set_global_logger(logroll.print_logger()) -- This is identical to the default.

Then in some other module:

    require 'logroll'
    logroll.debug("Testing...") -- => Outputs to print_logger above.

This global log can be combined with local log instances:

    require 'logroll'

    log = logroll.file_logger('logs/my_module.log')
    log.info("Testing...") -- => Outputs to file.

    log = logroll.combine(log, logroll)
    log.info("Testing...") -- => Outputs to file and to globally defined log.
