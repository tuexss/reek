$:.unshift File.dirname(__FILE__)

require 'reek/smells/smell'

module Reek
  module Smells

    #
    # Feature Envy occurs when a code fragment references another object
    # more often than it references itself, or when several clients do
    # the same series of manipulations on a particular type of object.
    # 
    # A simple example would be the following method, which "belongs"
    # on the Item class and not on the Cart class:
    # 
    #  class Cart
    #    def price
    #      @item.price + @item.tax
    #    end
    #  end
    #
    # Feature Envy reduces the code's ability to communicate intent:
    # code that "belongs" on one class but which is located in another
    # can be hard to find, and may upset the "System of Names"
    # in the host class.
    # 
    # Feature Envy also affects the design's flexibility: A code fragment
    # that is in the wrong class creates couplings that may not be natural
    # within the application's domain, and creates a loss of cohesion
    # in the unwilling host class.
    # 
    # Currently +FeatureEnvy+ reports any method that refers to self less
    # often than it refers to (ie. send messages to) some other object.
    #
    class FeatureEnvy < Smell

      def recognise?(refs)
        @refs = refs
        !refs.self_is_max?
      end

      def detailed_report
        receiver = @refs.max_keys.map {|r| Printer.print(r)}.sort.join(' and ')
        "#{@context} uses #{receiver} more than self"
      end
    end

  end
end
