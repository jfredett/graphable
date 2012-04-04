require 'forwardable'

module Graphable
  class EdgeCreator
    extend Forwardable 

    def self.through(*args)
      # for has_many :through relations
      ThroughEdgeCreator.new(*args) 
    end

    def self.via(*args)
      #for habtm/has_many relations
      ViaEdgeCreator.new(*args)
    end

    def initialize(source, target, method, opts)
      @source = source
      @target = target
      @method = method
      @name = opts[:name] || method
      @metadata_proc = opts[:block]
      @target_name = opts[:target_method]
    end

    protected 

    def load_node(n)
      Graphable.index_cache[n]
    end

    def build_relationship(source_node, target_node, metadata = {})
      # dodges an issue with neography, nil-values can't be sent up. that's
      # okay, since trying to access a field which doesn't exist should be nil
      # anyway.
      metadata.reject! { |_,v| v.nil? } 

      Neography::Relationship.create(@name, source_node, target_node, metadata) 
    end

    def sources
      @source.all
    end

    def target_name
      @target_name ||= @target.name.pluralize.downcase.to_sym
    end
  end

  class ThroughEdgeCreator < EdgeCreator
    def call 
      puts "Building edges for #{@source.name} -> #{@target.name}"
      sources.each_slice(100) do |slice|
        slice.each do |source|
          source_node = load_node(source)

          intermediates_for(source).each do |intermediate_target|
            metadata = @metadata_proc.call(intermediate_target) if @metadata_proc
            metadata = intermediate_target.send(:edge_metadata) if intermediate_target.respond_to?(:edge_metadata)

            target_node = load_node(intermediate_target.send(target_name)) rescue binding.pry

            build_relationship(source_node, target_node, metadata || {})
          end
        end
      end
    end

    def targets_for(source)
      res = intermediates_for(source).map(&target_name)
      res = res.to_a if res.respond_to?(:to_a)
      if res.respond_to?(:each) then res else [res] end
    end

    def intermediates_for(source)
      source.send(@method)
    end
  end

  class ViaEdgeCreator < EdgeCreator
    def call 
      puts "Building edges for #{@source.name} -> #{@target.name}"
      sources.each do |source|
        source_node = load_node(source)

        targets_for(source).each do |target|
          metadata = @metadata_proc.call(target) if @metadata_proc

          target_node = load_node(target) rescue binding.pry
          build_relationship(source_node, target_node, metadata || {})
        end
      end
    end

    def targets_for(source)
      res = source.send(@method)
      res = res.to_a if res.respond_to?(:to_a)
      if res.respond_to?(:each) then res else [res] end
    end
  end

end
