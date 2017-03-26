module TSort(T)
  class Cyclic < ::Exception
  end

  def tsort : Array(T)
    tsort_each
  end

  def tsort_each(&block : T -> _) : Nil
    each_strongly_connected_component do |component|
      if component.size == 1
        block.call(component.first)
      else
        raise Cyclic.new("topological sort failed: #{component.inspect}")
      end
    end
  end

  # FIXME: This probably should return an `Iterable`, which `#tsort` turns into
  # an array.
  def tsort_each : Array(T)
    components = [] of T
    tsort_each { |component| components << component }
    components
  end

  def strongly_connected_components
    each_strongly_connected_component
  end

  abstract def tsort_each_node(&b : T -> _)
  abstract def tsort_each_child(node : T, &b : T -> _)

  def each_strongly_connected_component(&block : Array(T) -> _) : Nil
    id_map = {} of T => UInt32?
    stack  = [] of T

    tsort_each_node do |node|
      unless id_map.has_key?(node)
        each_strongly_connected_component_from(node, id_map, stack) do |child|
          block.call(child)
        end
      end
    end
  end

  private def each_strongly_connected_component : Array(Array(T))
    components = [] of Array(T)
    each_strongly_connected_component { |component| components << component }
    components
  end

  private def each_strongly_connected_component_from(node, id_map, stack, &block : Array(T) -> _) : UInt32
    minimum_id = node_id = id_map[node] = id_map.size.to_u32
    stack_length = stack.size
    stack << node

    tsort_each_child(node) do |child|
      if id_map.has_key?(child)
        child_id = id_map[child]
        minimum_id = child_id if child_id && child_id < minimum_id
      else
        sub_minimum_id =
          each_strongly_connected_component_from(child, id_map, stack) do |child|
            block.call(child)
          end
        minimum_id = sub_minimum_id if sub_minimum_id < minimum_id
      end
    end

    if node_id == minimum_id
      component = stack[stack_length..-1]
      stack.delete_at(stack_length..-1)
      component.each { |n| id_map[n] = nil }
      block.call(component)
    end

    minimum_id
  end
end
