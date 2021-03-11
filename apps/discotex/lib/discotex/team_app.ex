defmodule Discotex.TeamApp do
  @moduledoc false

  def client do
    case Application.get_env(:discotex, __MODULE__) do
      nil -> Discotex.TeamApp.Client
      opts -> Keyword.get(opts, :adapter)
    end
  end
end
