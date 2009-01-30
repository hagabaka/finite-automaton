require 'set'

class FiniteAutomaton
  EPSILON = nil

  attr_reader :start_state
  attr_reader :accept_states
  attr_reader :alphabet

  def initialize(start_state)
    @start_state = start_state
    @transitions = Hash.new do |transitions, (state, character)|
      Set.new.tap do |empty_set|
        transitions[[state, character]] = empty_set unless character == EPSILON
      end
    end
    @accept_states = Set.new
    @alphabet = Set.new
    @states = Set.new
    add_state(@start_state)
  end

  def add_state(state)
    @states << state
  end

  def add_transition(from, character, to)
    [from, to].each {|state| add_state(state)}
    @alphabet << character
    @transitions[[from, character]] << to
  end

  def closure(state, character)
    c = @transitions[[state, character]]
    if character == EPSILON
      c | Set[state]
    else
      c
    end
  end

  def accept?(input)
    not (
      input.inject(closure(@start_state, EPSILON)) do |reachable, character|
        reachable.map do |state|
          closure(state, character)
        end.flatten.to_set.map do |state|
          closure(state, EPSILON)
        end.to_set.flatten
      end.flatten & @accept_states
    ).empty?
  end
  alias_method :accepts?, :accept?

  def deterministic?
    @transitions.keys.all? do |(from, character)|
      character != EPSILON
    end and
    @states.all? do |state|
      @alphabet.all? do |character|
        @transitions[[state, character]].length == 1
      end
    end
  end

  def to_deterministic
  end

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

  def to_dot
    require 'stringio'
    StringIO.new.tap do |output|
      output.puts 'digraph finite_automaton {'
      output.puts 'rankdir=LR;'
      output.puts 'size="8,5"'

      output.puts '0 [style=invis];'
      output.puts %Q/node [shape=doublecircle]; #{@accept_states.to_a.map {|t| %Q/"#{t}"/}.join(' ')};/
      output.puts 'node [shape=circle];'
      output.puts "0 -> #{start_state};"
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

