defmodule EvaluatorTest do
  use ExUnit.Case
  import LineSigil
  doctest Evaluator

  test "the truth" do
    assert 1 + 1 == 2
  end
end
