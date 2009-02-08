require 'set'

class FiniteAutomaton
  EPSILON = Object.new.tap do |o|
    def o.to_s
      "\xce\xb5"
    end
  end

  attr_accessor :start_state
  attr_reader :accept_states
  attr_reader :alphabet

  def initialize(start_state='s')
    @start_state = start_state
    @transitions = Hash.new do |transitions, (state, character)|
      Set.new.tap do |empty_set|
        transitions[[state, character]] = empty_set
      end
    end
    @accept_states = Set.new
    @alphabet = Set.new
  end

  def add_transition(from, character, to)
    @alphabet << character
    @transitions[[from, character]] << to
  end

  def closure(character, *states)
    c = states.inject(Set.new) do |r, state|
      r | @transitions[[state, character]]
    end
    if character == EPSILON
      c | Set[*states]
    else
      # c unioned with the EPSILON-closure of each state in c
      c | closure(EPSILON, *c)
    end
  end

  def accept?(input)
    not (
      input.inject(closure(EPSILON, @start_state)) do |reachable, character|
        closure(character, *reachable)
      end & @accept_states
    ).empty?
  end
  alias_method :accepts?, :accept?
end

