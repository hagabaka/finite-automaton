# = A DSL for constructing a FiniteAutomaton
#
# == Example
#
#   a = FiniteAutomaton.new
#   - a[1] - 'x' > +a[2].-('x', 'y') > +a[3].<<('x', 'y') - 'y' > a[1]
#
#   a.visualize
#              y
#          +------------------------+
#          v                        |
#        +---+  x   #===#  x, y   #==========#
#    --> | 1 | ---> H 2 H ------> H    3     H
#        +---+      #===#         #==========#
#                                   ^ x, y |
#                                   +------+
#
# == Syntax
#
# <code>-(state)</code>::
#   mark the state as the starting state
# <code>+(state)</code>::
#   mark the state as an accepting state
# <code>state1 - character > state2</code>::
#   when character is entered at state1, go to state2
# <code>state << character</code>::
#   the state loops on the character
#
# It's possible to use a list of characters, but as the example shows,
# you need to use <code>state.-(...)</code> or <code>state.<<(...)</code>
# to avoid parser errors
#
# (Do not use an array of characters thinking they will add multiple
# transitions; that will add one transition treating the array as one
# "character". It is intended that any object, including an array, can
# be a transition character.)

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

  [:+@, :-@].each do |m|
    define_method(m) do
      @state.send(m)
      self
    end
  end
end

