defmodule GcNLPTest do
  use ExUnit.Case

  test "sentiment analysis" do
    r = GcNLP.analyze_sentiment "There is a lot of new features coming in Elixir 1.4"
    # %{"documentSentiment" => %{"magnitude" => 0.1, "polarity" => 1}, "language" => "en"}
    assert Map.has_key?(r, "documentSentiment")
  end

  test "request caching" do
    # reset cache before test
    Cachex.reset!(GcNLP)

    # uncached
    {t1, r1} = :timer.tc(fn ->
      GcNLP.analyze_sentiment "There is a lot of new features coming in Elixir 1.4"
    end)

    # cached
    {t2, r2} = :timer.tc(fn ->
      GcNLP.analyze_sentiment "There is a lot of new features coming in Elixir 1.4"
    end)

    # both results are the same
    assert(r1 == r2)

    # the request is far slower than cached
    assert(t1 > 500000)
    assert(t2 < 100)
  end

end
