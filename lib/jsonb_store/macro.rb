require "jsonb_store/version"
require 'ostruct'
require 'json'
module JsonbStore
  module Macro
    module ClassMethods
      def jsonb_store(name, &block)
        tree = Field.new(name)
        tree.instance_exec(&block)
        attribute name, :jsonb, default: tree.to_hash[name]
        attribute "#{name}_schema", :jsonb, default: tree.to_hash[name]
      end

      class Field
        attr_accessor :name, :value, :parent, :children
        def initialize(name=nil, value=nil, parent=nil) 
          @name = name
          @value = value
          @children = []
          @parent = parent
        end 

        def field(name, options = {}, &block)
          value = options.fetch(:default, nil)
          child = Field.new(name, value, self)
          @children.push(child)
          child.instance_exec(&block) if block
        end

        def has_children?
          @children.count > 0
        end
  
        def to_hash 
          root = Hash.new
          build_hash(root, self)
          root
        end
 
        def to_json
          to_hash.to_json
        end
  
        def build_hash(hash, a_field)
          if a_field.has_children?
            child_hash = Hash.new
            hash[a_field.name] = child_hash
            a_field.children.each do |child|
              if child.has_children?
                build_hash(child_hash, child) 
              else
                child_hash[child.name] = child.value
              end
            end
          else 
            hash[a_field.name] = a_field.value
          end
        end
  
      end 
    end
  end
end
