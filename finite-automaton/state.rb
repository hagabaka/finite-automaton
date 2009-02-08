require 'finite-automaton'

class FiniteAutomaton
  def add_state(tag)
    @states ||= {}
    @states[tag] ||= State.new(self, tag)
  end
  alias_method :[], :add_state
  alias_method :state, :add_state
end


class FiniteAutomaton::State
  attr_reader :tag

  def initialize(automaton, tag)
    @automaton = automaton
    @tag = tag
  end

  def identifier
    [@automaton, @tag]
  end

  def eql?(s)
    identifier == s.identifier
  end

  def hash
    identifier.hash
  end

  def goto_on(target, *characters)
    characters.each {|c| @automaton.add_transition(tag, c, target.tag)}
    target
  end

  def start!
    tap {@automaton.start_state = tag}
  end
  alias_method :-@, :start!

  def accept!
    tap {@automaton.accept_states << tag} 
  end

  def loop_on(*characters)
    goto_on(self, *characters)
  end
end
