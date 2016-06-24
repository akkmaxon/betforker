module Forker
  class Event
    attr_reader :addresses

    def initialize(addresses)
      @addresses = addresses
    end
  end
end
