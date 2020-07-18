defmodule SubstackToGhost.CLI do
  @moduledoc """
  CLI Parser
  """

  def main(args) do
    args
    |> parse_args()
    |> run()
  end

  def parse_args([arg | _]) when is_binary(arg) do
    arg
  end

  def run(path), do: SubstackToGhost.build_ghost_json(path)
end
