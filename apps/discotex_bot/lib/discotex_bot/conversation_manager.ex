defmodule DiscotexBot.ConversationManager do
  @moduledoc """
  Manager for extended conversations, rather than one-off responses
  """
  use GenServer

  require Logger

  alias Discotex.Account
  alias DiscotexWeb.Router.Helpers

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(_opts) do
    # subscribe to account events
    Account.subscribe()

    {:ok, %{}}
  end

  def handle_info(
        {:discord_user_added, %{discord_id: discord_id, invitation_code: invitation_code}},
        dms
      ) do
    case chat_client().create_dm(discord_id) do
      {:ok, channel_id} ->
        path =
          Helpers.auth_url(DiscotexWeb.Endpoint, :index, :github, invitation_code: invitation_code)

        chat_client().send_message("Hi! I'm a bot. You should register here: #{path}", channel_id)

      error ->
        Logger.error("Couldn't do the thing: #{inspect(error)}")
    end

    {:noreply, dms}
  end

  defp chat_client do
    case Application.get_env(:discotex_bot, DiscotexBot.ChatClient) do
      nil -> DiscotexBot.DiscordClient
      opts -> Keyword.get(opts, :adapter)
    end
  end
end
