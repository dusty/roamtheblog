class TimestampObserver < Mongomatic::Observer
  def before_insert(instance, opts)
    instance[:created_at] = Time.now.utc
  end
  def before_insert_or_update(instance, opts)
    instance[:updated_at] = Time.now.utc
  end
end

module TimestampPlugin
  def self.included(base)
    base.send(:include, Mongomatic::Observable)
    base.send(:observer, :TimestampObserver)
  end
end

module AccessorPlugin
  def self.included(base)
    base.send(:extend, ClassMethods)
  end
  module ClassMethods
    def matic_accessor(*attributes)
      matic_reader(*attributes)
      matic_writer(*attributes)
    end
    def matic_reader(*attributes)
      attributes.each do |attribute|
        define_method(:"#{attribute}") do
          self[attribute]
        end
      end
    end
    def matic_writer(*attributes)
      attributes.each do |attribute|
        define_method(:"#{attribute}=") do |value|
          self[attribute] = value
        end
      end
    end
  end
end

module Roam
  class Model < Mongomatic::Base
    include TimestampPlugin
    include AccessorPlugin
    matic_accessor :created_at, :updated_at
    def id
      self[:_id]
    end
    def self.count
      collection.count
    end
  end
end