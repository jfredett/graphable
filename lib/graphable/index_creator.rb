module Graphable
  class IndexCreator
    extend Forwardable

    attr_reader :klass
    delegate [:name, :all, :index_name] => :@klass

    def initialize(klass, method)
      @klass = klass
      @method = method
    end

    def call
      return if Graphable.has_indexed?(@klass, @method)

      puts "Building index for #{name}"
      Graphable.neo.create_node_index(index_name, 'fulltext')

      all.to_a.each do |object|
        Graphable.neo.add_node_to_index(index_name, @method, object.send(@method), Graphable.index_cache[object])
      end

      Graphable.completed_index(@klass, @method)
    end
  end
end
