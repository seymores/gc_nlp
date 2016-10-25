defmodule GcNLP do
  @moduledoc """
  Provides wrapper functions for Google Cloud Natural Language API.
  See [full doc here](https://cloud.google.com/natural-language/reference/rest/v1beta1/documents)
  """
  require Logger
  alias Goth.Token

  @base_url     "https://language.googleapis.com/v1beta1/"
  @cache_ttl    Application.get_env(:gc_nlp, :cache_ttl)
  @token_ttl    Application.get_env(:gc_nlp, :token_ttl)
  @request_opts [connect_timeout: 1000000, recv_timeout: 1000000, timeout: 1000000]

  @doc """
  Finds named entities (currently finds proper names) in the text, entity types, salience, mentions for each entity, and other properties. See [doc](https://cloud.google.com/natural-language/reference/rest/v1beta1/documents/analyzeEntities)

  ## Example

      iex> GcNLP.analyze_sentiment "There is a lot of new features coming in Elixir 1.4"
      %{"documentSentiment" => %{"magnitude" => 0.1, "polarity" => 1}, "language" => "en"}

  """
  def analyze_sentiment(text) do
    make_request("documents:analyzeSentiment", text)
  end

  @doc """
  Finds named entities (currently finds proper names) in the text, entity types, salience, mentions for each entity, and other properties. See [doc](https://cloud.google.com/natural-language/reference/rest/v1beta1/documents/analyzeEntities)

  ## Example

      iex> GcNLP.analyze_entities "There is a lot of new features coming in Elixir 1.4"
      %{"entities" => [%{"mentions" => [%{"text" => %{"beginOffset" => 41, "content" => "Elixir 1.4"}}], "metadata" => %{}, "name" => "Elixir 1.4", "salience" => 0.16144496, "type" => "OTHER"}], "language" => "en"}

  """
  def analyze_entities(text) do
    make_request("documents:analyzeEntities", text)
  end

  @doc """
  Advanced API that analyzes the document and provides a full set of text annotations, including semantic, syntactic, and sentiment information. See [doc](https://cloud.google.com/natural-language/reference/rest/v1beta1/documents/annotateText)

  ## Example

      iex> GcNLP.annotate_text "There is a lot of new features coming in Elixir 1.4"
      %{"documentSentiment" => %{"magnitude" => 0.1, "polarity" => 1},
                   "entities" => [%{"mentions" => [%{"text" => %{"beginOffset" => 41,
                           "content" => "Elixir 1.4"}}], "metadata" => %{},
                      "name" => "Elixir 1.4", "salience" => 0.16144496,
                      "type" => "OTHER"}], "language" => "en",
                   "sentences" => [%{"text" => %{"beginOffset" => 0,
                        "content" => "There is a lot of new features coming in Elixir 1.4"}}],
                   "tokens" => [%{"dependencyEdge" => %{"headTokenIndex" => 1,
                        "label" => "EXPL"}, "lemma" => "There",
                      "partOfSpeech" => %{"tag" => "DET"},
                      "text" => %{"beginOffset" => 0, "content" => "There"}},
                    %{"dependencyEdge" => %{"headTokenIndex" => 1, "label" => "ROOT"},
                      "lemma" => "be", "partOfSpeech" => %{"tag" => "VERB"},
                      "text" => %{"beginOffset" => 6, "content" => "is"}},
                    %{"dependencyEdge" => %{"headTokenIndex" => 3, "label" => "DET"},
                      "lemma" => "a", "partOfSpeech" => %{"tag" => "DET"},
                      "text" => %{"beginOffset" => 9, "content" => "a"}},
                    %{"dependencyEdge" => %{"headTokenIndex" => 1,
                        "label" => "NSUBJ"}, "lemma" => "lot",
                      "partOfSpeech" => %{"tag" => "NOUN"},
                      "text" => %{"beginOffset" => 11, "content" => "lot"}},
                    %{"dependencyEdge" => %{"headTokenIndex" => 3, "label" => "PREP"},
                      "lemma" => "of", "partOfSpeech" => %{"tag" => "ADP"},
                      "text" => %{"beginOffset" => 15, "content" => "of"}},
                    %{"dependencyEdge" => %{"headTokenIndex" => 6, "label" => "AMOD"},
                      "lemma" => "new", "partOfSpeech" => %{"tag" => "ADJ"},
                      "text" => %{"beginOffset" => 18, "content" => "new"}},
                    %{"dependencyEdge" => %{"headTokenIndex" => 4, "label" => "POBJ"},
                      "lemma" => "feature", "partOfSpeech" => %{"tag" => "NOUN"},
                      "text" => %{"beginOffset" => 22, "content" => "features"}},
                    %{"dependencyEdge" => %{"headTokenIndex" => 6, "label" => "VMOD"},
                      "lemma" => "come", "partOfSpeech" => %{"tag" => "VERB"},
                      "text" => %{"beginOffset" => 31, "content" => "coming"}},
                    %{"dependencyEdge" => %{"headTokenIndex" => 7, "label" => "PREP"},
                      "lemma" => "in", "partOfSpeech" => %{"tag" => "ADP"},
                      "text" => %{"beginOffset" => 38, "content" => "in"}},
                    %{"dependencyEdge" => %{"headTokenIndex" => 8, "label" => "POBJ"},
                      "lemma" => "Elixir", "partOfSpeech" => %{"tag" => "NOUN"},
                      "text" => %{"beginOffset" => 41, "content" => "Elixir"}},
                    %{"dependencyEdge" => %{"headTokenIndex" => 9, "label" => "NUM"},
                      "lemma" => "1.4", "partOfSpeech" => %{"tag" => "NUM"},
                      "text" => %{"beginOffset" => 48, "content" => "1.4"}}]}
  """
  def annotate_text(text) do
    make_request("documents:annotateText", text, [
      features: %{
        "extractSyntax": true,
        "extractEntities": true,
        "extractDocumentSentiment": true,
      }
    ])
  end

  defp make_request(type, content, options \\ []) do
    content_type = Keyword.get(options, :content_type, "plain_text")
    feature_set  = Keyword.get(options, :features)

    url = @base_url <> type

    hash_key = get_hash_key(url, content)

    try_cache(hash_key, @cache_ttl, fn(_key) ->
      token = get_token

      headers = %{
        "Authorization" => "Bearer #{token.token}",
        "Content-type" => "application/json"
      }

      payload = %{
        "document": %{
          "type": content_type,
          "content": content
        },
        "encodingType": "UTF8"
      }

      body = if feature_set != nil do
        payload
        |> Map.put(:features, feature_set)
        |> Poison.encode!
      else
        Poison.encode!(payload)
      end

      Logger.debug(url)

      case HTTPoison.post(url, body, headers, @request_opts) do
        {:ok, response} -> {:commit, Poison.decode!(response.body)}
        _ -> {:ignore,nil}
      end
    end)
  end

  defp get_hash_key(url, content) do
    :md5
    |> :crypto.hash_init
    |> :crypto.hash_update(url)
    |> :crypto.hash_update(content)
    |> :crypto.hash_final
  end

  defp get_token do
    try_cache("gauth_token", @token_ttl, &generate_token/1)
  end

  defp generate_token(_key) do
    scope = "https://www.googleapis.com/auth/cloud-platform"
    case Token.for_scope(scope) do
      {:ok, token} -> {:commit, token}
      _ -> {:ignore, nil}
    end
  end

  defp try_cache(key, ttl, action) do
    Cachex.execute(GcNLP, fn(state) ->
      {status, value} = Cachex.get(state, key, [fallback: action])

      if status == :loaded do
        Cachex.expire!(state, key, ttl)
      end

      value
    end)
  end

end
