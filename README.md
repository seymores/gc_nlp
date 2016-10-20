# GcNLP

Elixir wrapper for Google Cloud Natural Language API. See [Cloud Natural Language API](https://cloud.google.com/natural-language/)

## Installation

The package can be installed as:

  1. Add `gc_nlp` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:gc_nlp, "~> 0.1.0"}]
    end
    ```

  2. Ensure `gc_nlp` is started before your application:

    ```elixir
    def application do
      [applications: [:gc_nlp]]
    end
    ```
## Using GcNLP

