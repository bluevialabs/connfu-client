module Connfu
  
  ##
  # This class is used to send Message instances between transport (listener) and dispatcher layers
  class Events

    ##
    # Initializer
    def initialize
      @queue = Queue.new
    end

    ##
    # Returns a message from the queue. It waits until there's at least one message in the queue and acts
    # as a FIFO queue.
    #
    # ==== Returns
    # Connfu::Message instance
    def get
      @queue.pop
    end

    ##
    # Inserts a message in the queue
    #
    # ==== Parameters
    # * +event+ Connfu::Message instance
    def put(event)
      @queue << event
    end
  end
end