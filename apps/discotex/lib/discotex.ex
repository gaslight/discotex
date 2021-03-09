defmodule Discotex do
  @moduledoc """
  Discotex keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias Discotex.Account
  alias Discotex.TeamApp.Client

  def get_users_with_missing_timesheets() do
    Client.missing_timesheets()
    |> Enum.map(fn person -> person["work_email"] end)
    |> Account.get_users_by_emails()
  end
end
