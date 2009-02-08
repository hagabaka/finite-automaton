require 'finite-automaton'

class FiniteAutomaton
  def merged_edges
    result = {}
    @transitions.inject([]) do
      |collected, ((source, character), targets)|
      collected + targets.map do |target|
        [source, character, target]
      end
    end.to_set.classify do |(source, character, target)|
      [source, target]
    end.each_pair do |(source, target), transitions|
      result[[source, target]] = transitions.map do |(_, character, _)|
        character
      end
    end
    result
  end
  private :merged_edges

  def to_dot
    require 'stringio'
    StringIO.new.tap do |output|
      output.puts 'digraph finite_automaton {'
      output.puts 'rankdir=LR;'
      output.puts 'size="8,5"'

      output.puts '0 [style=invis];'
      output.puts %Q/node [shape=doublecircle]; #{@accept_states.map {|t| %Q/"#{t}"/}.join(' ')};/
      output.puts 'node [shape=circle];'
      output.puts %Q/0 -> "#{start_state}";/
      merged_edges.each_pair do |(source, target), characters|
        output.puts %Q/"#{source}" -> "#{target}" [label="#{characters.join(', ')}"];/
      end

      output.puts '}'
    end.string
  end

  def to_graph_easy
    require 'stringio'
    StringIO.new.tap do |output|
      output.puts '[ 0 ] { shape: invisible; }'
      @accept_states.each do |state|
        output.puts "[ #{state} ] { border: double; }"
      end
      output.puts "[ 0 ] --> [ #{@start_state} ]"
      merged_edges.each_pair do |(source, target), characters|
        output.puts "[ #{source} ] -- #{characters.join(', ')} --> [ #{target} ]"
      end
    end.string
  end
end
