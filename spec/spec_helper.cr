require "../src/tsort"
require "spec"

class Hash(K, V) # V = Array(K)
  include TSort(K)

  def tsort_each_node(&block : K -> _)
    each_key do |key|
      yield key
    end
  end

  def tsort_each_child(node, &b: K -> _)
    fetch(node).each do |value|
      yield value
    end
  end
end

class Array
  include TSort(Int32)

  def tsort_each_node(&block)
    each_index do |index|
      yield index
    end
  end

  def tsort_each_child(node, &block)
    at(node).each do |value|
      yield value
    end
  end
end
