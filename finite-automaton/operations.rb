class FiniteAutomaton
  def deterministic?
    @transitions.keys.all? do |(from, character)|
      character != EPSILON || @transitions[character].empty?
    end and
    @states.all? do |state|
      @alphabet.all? do |character|
        @transitions[[state, character]].length == 1
      end
    end
  end

  def deterministify
  end

  def canonicalize
    deterministify.minimize
  end

  def complement
  end
  alias_method :~, :complement

  def union(a)
  end
  alias_method :|, :union

  def intersection(a)
    complement.union(a.complement).complement
  end
  alias_method :&, :intersection

  def concatenation(a)
  end
  alias_method :+, :concatenation
  alias_method :concat, :concatenation
end

