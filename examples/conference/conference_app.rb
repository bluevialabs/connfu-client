$:.unshift File.join(File.dirname(__FILE__), '.')

require 'conference'

# This class is a mockup of a conference rooms application
# In real, it should access an external storage system (i.e. database) to retrieve
# information about Conference objects
class ConferenceApp

  class << self

    def find_by_conference_number(number)
      Conference.new(number)
    end

    def find_by_twitter_user(username)
      Conference.new(username)
    end

    def find(number)
      Conference.new(number)
    end

  end
end