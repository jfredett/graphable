#Graphable

Graphable is a ruby gem which builds static graphs in Neo4j from a secondary,
ActiveModel-ish data store.

## How to use it:

Say you have some models:


    #where ActiveMapper::Root is your ActiveModelly ORM of choice
    class User < ActiveMapper::Root
      
      has_many :followers, :class => User
      
      property :name
      property :join_date

    end

And you want to turn it into a graph periodically for cool reporting or
something. Then you can do:


    class User < ActiveMapper::Root
      include Graphable
      
      has_edge to: User, via: :followers, name: "followed_by"
      has_many :followers, :class => User
      
      indexes :name, :join_date

      property :name
      property :join_date
    end

Which will take your SQL db and turn it into a lovely Neo4j Graph! (With indexes
automatically on the :id field, and anything else you specify in the `indexes`
call. Don't worry if you specify something twice, it won't double index!

## Warning:

This is _very_ organic, I extracted the concept from another project, rewrote it
here in an afternoon, and here it is.
