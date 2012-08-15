require 'forwardable'

module Graphable
  class NodeCreator
    extend Forwardable

    attr_reader :klass
    delegate [:name] => :@klass

    def initialize(klass)
      @klass = klass
    end

    def call 
      puts "Building nodes for #{name}"
      Graphable.objects_of(@klass).each_slice(250) do |slice|
        nodes = Graphable.neo.batch(*slice.map do |obj| 
          [:create_node, obj.to_node]
        end)
        slice.zip(nodes).each do |object, node|
          Graphable.index_cache[object] = node["body"]
        end
      end
    end
  end
end
