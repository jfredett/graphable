require 'forwardable'

module Graphable
  class NodeCreator
    extend Forwardable

    attr_reader :klass
    delegate [:name, :all] => :@klass

    def initialize(klass)
      @klass = klass
    end

    def call 
      puts "Building nodes for #{name}"
      all.each_slice(100) do |slice|
        slice.each do |object|
          Graphable.index_cache[object] = Neography::Node.create(object.to_node) 
        end
      end
    end
  end
end
