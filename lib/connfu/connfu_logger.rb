require 'logger'

module Connfu
  ##
  # This module defines a mixin to be used in any class that needs to log messages.
  #
  module ConnfuLogger

    ##
    # Nice way to include the Module methods when including it in a class/module
    #
    # ==== Parameters
    # * +base+ class that includes the mixin
    def self.included(base)
      base.extend(ClassMethods)
    end

    ##
    # This internal module acts as a wrapper to include the class/module level methods
    module ClassMethods

      ##
      # logger setter
      #
      # ==== Parameters
      # * +value+ should be:
      #   * a valid IO object (STDOUT, string representing a valid filename, File object)
      #   * a ::Logger instance
      #
      # ==== Return
      # new ::Logger object created
      def logger=(value)
        # _logger must be static var and not class var to be shared between objects/classes
        if value.is_a?(String) or value.is_a?(IO)
          @@_logger = Logger.new(value)
        else
          @@_logger = value
        end
      end

      ##
      # logger getter
      #
      # ==== Return
      # ::Logger object
      def logger
        @@_logger ||= create_logger
      end

      ##
      # Change logger level
      #
      # ==== Parameters
      # * +level+ valid Logger level constant (::Logger::DEBUG, etc)
      def log_level=(level)
        logger.level = level
      end

      ##
      # Creates a new Logger object and defines the level and format
      #
      # ==== Parameters
      # * +output+ valid IO object
      # ==== Return
      # Logger object
      def create_logger(output = nil)
        output.nil? and output = STDOUT
        logger = Logger.new(output)
        logger.level = Logger::ERROR
        #logger.formatter = proc { |severity, datetime, progname, msg|
        #  "#{severity} on #{datetime} at #{progname}: #{msg}\n"
        #}
        logger.datetime_format = "%Y-%m-%d %H:%M:%S"
        logger
      end
    end

    ##
    # Instance method that wraps the class method
    # 
    # ==== Return
    # * see ClassMethods.logger
    def logger
      self.class.logger
    end

  end
end