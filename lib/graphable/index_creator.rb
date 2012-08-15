module Graphable
  class IndexCreator
    extend Forwardable

    attr_reader :klass
    delegate [:name, :graph_index_name] => :@klass

    def initialize(klass, method)
      @klass = klass
      @method = method
    end

    def call
      return if Graphable.has_indexed?(@klass, @method)

      puts "Building #{@method} index for #{name}"
      Graphable.neo.create_node_index(graph_index_name, 'exact') # fulltext

      Graphable.objects_of(@klass).each_slice(250) do |slice|
        Graphable.neo.batch(*slice.map do |obj|
          [:add_node_to_index, graph_index_name, @method, obj.send(@method), Graphable.index_cache[obj]] 
        end)
      end

      Graphable.completed_index(@klass, @method)
    end
  end
end
