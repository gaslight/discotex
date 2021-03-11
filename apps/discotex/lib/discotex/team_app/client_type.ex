defmodule Discotex.TeamApp.ClientType do
  @moduledoc """
  behaviour definition for api calls to the team app
  """

  @callback missing_timesheets() :: {:ok, [map()]} | {:error, map()}
end
