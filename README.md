#Graphable

Graphable is a ruby gem which builds static graphs in Neo4j from a secondary,
ActiveModel-ish data store.

## Overview:

Say you have some models:


    #where ActiveMapper::Root is your ActiveModelly ORM of choice
    class User < ActiveMapper::Root
      
      has_many :followers, :class => User
      attr_accessor :name, :join_date

    end

And you want to turn them into a graph periodically for cool reporting or
something. Then you can do:


    class User < ActiveMapper::Root

      has_many :followers, :class => User
      attr_accessor :name, :join_date

      include Graphable
      graph_with :all
      graph_indexes :id, :name, :join_date
      has_edge to: User, via: :followers, name: "followed_by"
      
    end

Which will take your SQL db and turn it into a lovely Neo4j Graph! (With indexes
automatically on the :id field, and anything else you specify in the `graph_indexes`
call. Don't worry if you specify something twice, it won't double index!

## In-Depth:

Graphable defines four class methods and one instance method on your models:

    Class.graph_index_name

This function returns the name of the Neo4j index Graphable will create for your model. By default, it will be `"classes_index"`, but you can override it if you'd like. 

    instance.to_node

`to_node` transforms your object into a hash of properties for Neo4j. By default, it will return the ActiveRecord `attributes` hash with all foreign keys and all nil values deleted. Similar to `graph_index_name`, you need to override it if you want to change its default behavior (e.g. if you only want 'user.name' to be added to the graph). 

    Class.graph_indexes(*methods)

You can pass this function a list of instance method names, and it will add `key = method_name` and `value = instance.send(method_name)` to the class index, for each instance. Graphable by default will always index on `id`, so you don't have to specify that one.

    Class.graph_with(method)

This determines which objects Graphable will insert into Neo4j. By default, it will be set to `"all"`, but if your ORM works differently, or if you want to exclude some objects from the graph (e.g. `graph_with "unbanned"` for `class User`), call this method.

    Class.has_edge(opts)

This is the cool method. It defines what relationships going out from each instance node will be added to Neo4j -- there are no defaults, so you need to call this for every association you care about. There are two ways you can invoke this method:

The first is with `:via`. Example:

    class User < ActMap::Rüt
    
      has_many :followers, :class => User
      
      include Graphable
      has_edge :to => User, :via => :followers, :name => "followed_by"

    end

Graphable will call `user.followers`, expect to get back an array of users, and it will create a `"followed_by"` relationship from the user to all the other users returned by `followers`.

The second is with `:through`:

    class User < AM::R

      has_many :pokeballs
      has_many :pokemon, :through => :pokeballs, :class => Pokemon

      include Graphable
      has_edge :to => Pokemon, :through => :pokeballs, :target_method => :pokemon, :name => "has_caught"

    end

Graphable will call `user.pokeballs`, and then for each element `pokeball` returned, will call `pokeball.pokemon` to get the object. It will then create a `"has_caught"` relationship between the user node and the node for the pokemon.

## Plans:

* Add tests to gem
* Scope class methods (to reduce likelihood of collisions with methods outside graphable / in other included libraries)

## Warning:

This is ~~_very_~~ _pretty_ organic, ~~I~~ we extracted the concept from another project, rewrote it
here in ~~an afternoon~~ a few days, and here it is.
