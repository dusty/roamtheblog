require 'matic_accessor'
require 'matic_timestamp'

module Roam
  module Models
    def self.included(base)
      base.send(:include, Mongomatic::Plugins::Timestamps)
      base.send(:include, Mongomatic::Plugins::Accessors)
      base.send(:matic_accessor, :created_at, :updated_at)
      base.send(:extend, ClassMethods)
      base.send(:include, InstanceMethods)
    end
    module ClassMethods
      def count
        collection.count
      end
    end
    module InstanceMethods
      def id
        self[:_id]
      end
    end
  end
end