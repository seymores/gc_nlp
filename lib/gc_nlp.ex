defmodule GcNLP do
  @moduledoc """
  Provides wrapper functions for Google Cloud Natural Language API.
  See https://cloud.google.com/natural-language/reference/rest/v1beta1/documents
  """
  require Logger
  alias Goth.Token

  @base_url "https://language.googleapis.com/v1beta1/"

  def analyze_sentiment(text, type \\ "plain_text") do
    make_request("documents:analyzeSentiment", text)
  end

  def analyze_entities(text) do
    make_request("documents:analyzeEntities", text)
  end

  def analyze_syntax(text) do
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
    HTTPoison.post(url, body, headers, [connect_timeout: 1000000, recv_timeout: 1000000, timeout: 1000000])

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
    HTTPoison.post(url, body, headers, [connect_timeout: 1000000, recv_timeout: 1000000, timeout: 1000000])
  end

  defp get_token do
    scope = "https://www.googleapis.com/auth/cloud-platform"
    case Token.for_scope(scope) do
      {:ok, token} -> token
      _ -> nil
    end
  end

end
