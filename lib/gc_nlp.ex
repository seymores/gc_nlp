defmodule GcNLP do
  @moduledoc """
  Provides wrapper functions for Google Cloud Natural Language API.
  See [full doc here](https://cloud.google.com/natural-language/reference/rest/v1beta1/documents)
  """
  require Logger
  alias Goth.Token

  @base_url "https://language.googleapis.com/v1beta1/"

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
    url = @base_url <> "documents:annotateText"
    token = get_token
    headers = %{"Authorization" => "Bearer #{token.token}", "Content-type" => "application/json"}
    body = Poison.encode!(%{
    "document": %{
      "type": "plain_text",
      "content": text
    },
    "features": %{
      "extractSyntax": true,
      "extractEntities": true,
      "extractDocumentSentiment": true,
    },
    "encodingType": "UTF8"
    })
    Logger.debug url
    case HTTPoison.post(url, body, headers, [connect_timeout: 1000000, recv_timeout: 1000000, timeout: 1000000]) do
      {:ok, response} -> response.body |> Poison.decode!
      _ -> nil
    end
  end

  defp make_request(type, content, content_type \\ "plain_text") do
    url = @base_url <> type
    token = get_token
    headers = %{"Authorization" => "Bearer #{token.token}", "Content-type" => "application/json"}
    body = Poison.encode!(%{
      "document": %{
        "type": content_type,
        "content": content
      },
      "encodingType": "UTF8"
    })
    Logger.debug url
    case HTTPoison.post(url, body, headers, [connect_timeout: 1000000, recv_timeout: 1000000, timeout: 1000000]) do
      {:ok, response} -> response.body |> Poison.decode!
      _ -> nil
    end
  end

  defp get_token do
    scope = "https://www.googleapis.com/auth/cloud-platform"
    case Token.for_scope(scope) do
      {:ok, token} -> token
      _ -> nil
    end
  end

end
