require 'active_support'
Dir["./lib/graphable/*.rb"].each do |f| require f end


module Graphable
  extend ActiveSupport::Concern

  included do
    Graphable.register NodeCreator.new(self)
    indexes :id
  end

  def self.register(registrant)
    registry << registrant
  end

  def self.neo
    Neography::Rest.new(ENV["NEO4J_URL"] || "http://localhost:7474")  
  end

  def self.registry
    @registry ||= []
  end

  def self.build!
    puts "Building Graph"
    registry.select { |f| f.is_a? NodeCreator  }.map(&:call)
    registry.select { |f| f.is_a? IndexCreator }.map(&:call)
    registry.select { |f| f.is_a? EdgeCreator  }.map(&:call)
    nil
  end

  def self.index_cache
    @index_cache ||= {}
  end

  def self.completed_indicies
    @completed_indicies ||= {}
  end

  def self.completed_index(klass, method)
    completed_indicies[[klass, method]] = true
  end

  def self.has_indexed?(klass, method)
    completed_indicies[[klass,method]]
  end



  module InstanceMethods
    def to_node
      attributes.to_hash.tap do |hash|
        hash.each { |k, _| hash.delete(k) if k.to_s =~ /_id$/ } #remove FKs
        hash[:type] = self.class.name
      end
    end
  end

  module ClassMethods
    def index_name
      "#{name.downcase.pluralize}_index"
    end

    def indexes(*methods)
       methods.each do |method|
         Graphable.register IndexCreator.new(self, method) 
       end
    end

    def has_edge(hash = {}, &block)
      source_klass = self
      target_klass = hash[:to]
      hash[:block] = block
      if hash.has_key?(:through)
        Graphable.register EdgeCreator.through(source_klass, target_klass, hash.delete(:through), hash)
      elsif hash.has_key?(:via)
        Graphable.register EdgeCreator.via(source_klass, target_klass, hash.delete(:via), hash)
      else
        raise "Invalid Edge type, must be :through or :via"
      end
    end
  end

end
