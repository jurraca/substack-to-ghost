defmodule SubstackToGhost do
  @moduledoc """
  Script that takes in a Substack export folder, and produces a Ghost JSON-compliant output ready for import.
  """

  def build_ghost_json(path) do
    path
    |> read_export_folder()
    |> Enum.map(fn item -> {extract_title(item), item} end)
    |> Enum.map(fn {title, html_path} -> build_card(title, html_path) end)
    |> build_mobiledoc()
    |> Jason.encode!()
  end

  @doc """
  Get the HTML files from the Substack export folder.
  Returns a list of html files from that folder.
  """
  def read_export_folder(path) do
    abs = path |> Path.expand()

    abs
    |> File.ls!()
    |> Enum.filter(fn file_name -> is_html?(file_name) end)
    |> Enum.map(fn file_name -> concat_path(abs, file_name) end)
  end

  def build_mobiledoc(cards) do
    %{
      version: '0.3.1',
      markups: [],
      atoms: [],
      cards: cards,
      sections: []
    }
  end

  @doc """
  substack format: 426518.the-second-renaissance.html
  get text, replace dash with space, capitalize
  """
  def read_html(absolute_path) do
    absolute_path
    |> Path.expand()
    |> File.read!()
  end

  def build_card(title, html_path) do
    ["html", %{"cardName" => title, "html" => read_html(html_path)}]
  end

  defp extract_title(file_name) do
    Regex.run(~r/[[:digit:]]\.(?<title>.*)\.html$/, file_name, capture: :all_names)
    |> Enum.at(0)
    |> String.replace("-", " ")
    |> String.capitalize()
  end

  defp is_html?(file_name) do
    "text/html" == MIME.from_path(file_name)
  end

  defp concat_path(path, file_name) do
    path <> "/" <> file_name
  end
end
