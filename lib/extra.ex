defmodule GcNLP.Extra do
  @moduledoc """
  *WARNING* Experimental
  Advance NLP goodies here.
  """

  @doc """
  Return the annoated text labels only.
  See [doc](https://cloud.google.com/natural-language/reference/rest/v1beta1/documents/annotateText#Label)

  """
  def filter_labels(text) do
    result = GcNLP.annotate_text(text, true, false, false)
    for t <- result["tokens"] do
      dep_edge = t["dependencyEdge"]
      label = dep_edge["label"]
      pos = t["partOfSpeech"]
      tag = pos["tag"]
      lemma = t["lemma"]
      text = t["text"]
      word = text["content"]
      %{label: label, tag: tag, word: word, lemma: word}
    end
  end

  # def filter_

end


# Where do I start with this?
# ["ADVMOD", "AUX", "NSUBJ", "ROOT", "PREP", "POBJ", "P"]
#
# I love fish but why they are always so fishy?
# ["NSUBJ", "ROOT", "DOBJ", "CC", "ADVMOD", "NSUBJ", "CONJ", "ADVMOD", "ADVMOD", "ACOMP", "P"]
#
# This is the best place to be now?
# ["NSUBJ", "ROOT", "DET", "AMOD", "ATTR", "AUX", "VMOD", "ADVMOD", "P"]
#
# How is the food?
# ["ADVMOD", "ROOT", "DET", "NSUBJ", "P"]
#
# This cant be right
# ["NSUBJ", "AUX", "NEG", "ROOT", "ACOMP"]
#
# Best is the thing ever?
# ["NSUBJ", "ROOT", "DET", "ATTR", "ADVMOD", "P"]
#
# This is a big fish.
# ["NSUBJ", "ROOT", "DET", "AMOD", "ATTR", "P"]
