defmodule GcNLPTest do
  use ExUnit.Case
  doctest GcNLP

  test "sentiment analysis" do
    r = GcNLP.analyze_sentiment "There is a lot of new features coming in Elixir 1.4"
    # %{"documentSentiment" => %{"magnitude" => 0.1, "polarity" => 1}, "language" => "en"}
    assert Map.has_key?(r, "documentSentiment")
  end
  
end
