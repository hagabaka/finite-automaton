require 'finite-automaton'
require 'finite-automaton/state'

class FiniteAutomaton::State
  def on(*characters)
    FiniteAutomaton::StateCharacters.new(self, characters)
  end
  alias_method :-, :on

  alias_method :<<, :loop_on

  alias_method :-@, :start!

  alias_method :+@, :accept!
end

class FiniteAutomaton::StateCharacters
  attr_accessor :state, :characters
  def initialize(state, characters)
    @state = state
    @characters = characters
  end

  def goto(target)
    @state.goto_on(target, *@characters)
    target
  end

  def >(arg)
    case arg
    when FiniteAutomaton::StateCharacters
      goto arg.state
    else
      goto arg
    end
    arg
  end
end

