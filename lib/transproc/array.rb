require 'transproc/hash'

module Transproc
  # Transformation functions for Array objects
  #
  # @example
  #   require 'transproc/array'
  #
  #   include Transproc::Helper
  #
  #   fn = t(:map_array, t(:symbolize_keys)) >> t(:wrap, :address, [:city, :zipcode])
  #
  #   fn.call(
  #     [
  #       { 'city' => 'Boston', 'zipcode' => '123' },
  #       { 'city' => 'NYC', 'zipcode' => '312' }
  #     ]
  #   )
  #   # => [{:address=>{:city=>"Boston", :zipcode=>"123"}}, {:address=>{:city=>"NYC", :zipcode=>"312"}}]
  #
  # @api public
  module ArrayTransformations
    extend Functions

    # Map array values using transformation function
    #
    # @example
    #
    #   fn = Transproc(:map_array, -> v { v.upcase })
    #
    #   fn.call ['foo', 'bar'] # => ["FOO", "BAR"]
    #
    # @param [Array] array The input array
    # @param [Proc] fn The transformation function
    #
    # @return [Array]
    #
    # @api public
    def map_array(array, fn)
      map_array!(Array[*array], fn)
    end

    # Same as `map_array` but mutates the array
    #
    # @see ArrayTransformations.map_array
    #
    # @api public
    def map_array!(array, fn)
      array.map! { |value| fn[value] }
    end

    # Wrap array values using HashTransformations.nest function
    #
    # @example
    #   fn = Transproc(:wrap, :address, [:city, :zipcode])
    #
    #   fn.call [{ city: 'NYC', zipcode: '123' }]
    #   # => [{ address: { city: 'NYC', zipcode: '123' } }]
    #
    # @param [Array] array The input array
    # @param [Object] key The nesting root key
    # @param [Object] keys The nesting value keys
    #
    # @return [Array]
    #
    # @api public
    def wrap(array, key, keys)
      map_array(array, Transproc(:nest, key, keys))
    end

    # Group array values using provided root key and value keys
    #
    # @example
    #   fn = Transproc(:group, :tags, [:tag_name])
    #
    #   fn.call [
    #     { task: 'Group it', tag: 'task' },
    #     { task: 'Group it', tag: 'important' }
    #   ]
    #   # => [{ task: 'Group it', tags: [{ tag: 'task' }, { tag: 'important' }]]
    #
    # @param [Array] array The input array
    # @param [Object] key The nesting root key
    # @param [Object] keys The nesting value keys
    #
    # @return [Array]
    #
    # @api public
    def group(array, key, keys)
      grouped = Hash.new { |h, k| h[k] = [] }
      array.each do |hash|
        hash = hash.dup
        child = {}
        keys.each { |k| child[k] = hash.delete(k) }
        grouped[hash] << child
      end
      grouped.map do |root, children|
        root.merge(key => children)
      end
    end

    # Combines two arrays by merging child items from right array using join keys
    #
    # @example
    #   fn = t(:combine, [[:tasks, name: :user]])
    #
    #   fn.call([[{ name: 'Jane' }], [{ user: 'Jane', title: 'One' }]])
    #   # => [{:name=>"Jane", :tasks=>[{:user=>"Jane", :title=>"One"}]}]
    #
    # @param [Array<Array>] array The input array
    # @param [Array<Hash>] mappings The mapping definitions array
    #
    # @return [Array<Hash>]
    #
    # @api public
    def combine(array, mappings)
      parent, groups = array

      parent.map { |item|
        child_hash = {}

        groups.each_with_index do |group, index|
          key, keys, group_mappings = mappings[index]

          children =
            if group_mappings
              combine(group, group_mappings)
            else
              group
            end

          child_hash[key] = children.select { |child|
            keys.all? { |l,r| item[l] == child[r] }
          }
        end

        item.merge(child_hash)
      }
    end

    # Converts the array of hashes to array of values, extracted by given key
    #
    # @example
    #   fn = t(:extract_key, :name)
    #   fn.call [
    #     { name: 'Alice', role: 'sender' },
    #     { name: 'Bob', role: 'receiver' },
    #     { role: 'listener' }
    #   ]
    #   # => ['Alice', 'Bob', nil]
    #
    # @param [Array<Hash>] array The input array of hashes
    # @param [Object] key The key to extract values by
    #
    # @return [Array]
    #
    # @api public
    def extract_key(array, key)
      extract_key!(Array[*array], key)
    end

    # Same as `extract_key` but mutates the array
    #
    # @see ArrayTransformations.extract_key
    #
    # @api public
    def extract_key!(array, key)
      map_array!(array, -> v { v[key] })
    end
  end
end
