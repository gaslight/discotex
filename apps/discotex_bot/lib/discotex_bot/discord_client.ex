defmodule DiscotexBot.DiscordClient do
  @moduledoc """
  Chat client adapter for Discord
  """

  use Nostrum.Consumer

  require Logger

  alias DiscotexBot.Dispatch
  alias Nostrum.Api
  alias Nostrum.Cache.Me
  alias Nostrum.Struct.{Channel, Emoji, Message}

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def create_dm(user_id) do
    case Api.create_dm(user_id) do
      {:ok, %Channel{id: channel_id}} ->
        {:ok, channel_id}

      error ->
        Logger.warn("Received API error response: #{inspect(error)}")
        error
    end
  end

  def send_message(content, channel_id) do
    handle_api_response(Api.create_message(channel_id, content))
  end

  def add_reaction("<:" <> custom_emoji_string, channel_id, message_id) do
    [name, id] =
      custom_emoji_string
      |> String.trim_trailing(">")
      |> String.split(":")

    emoji = %Emoji{name: name, id: String.to_integer(id)}
    handle_api_response(Api.create_reaction(channel_id, message_id, emoji))
  end

  def add_reaction(emoji_name, channel_id, message_id) do
    emoji = %Emoji{name: emoji_name}
    handle_api_response(Api.create_reaction(channel_id, message_id, emoji))
  end

  def get_channel_message(channel_id, message_id) do
    handle_api_response(Api.get_channel_message(channel_id, message_id))
  end

  def list_guild_emojis(guild_id) do
    response =
      guild_id
      |> Api.list_guild_emojis()
      |> handle_api_response()

    case response do
      {:ok, emoji_list} -> emoji_list
      _ -> []
    end
  end

  def handle_event(event = {:MESSAGE_CREATE, message = %Message{}, _ws_state}) do
    Logger.info("Event: #{inspect(event)}")
    respond(Dispatch.handle_message_create(message, Me.get()))
  end

  def handle_event(event) do
    Logger.info("Unhandled event: #{inspect(event)}")
  end

  defp respond(commands) when is_list(commands) do
    Enum.each(commands, &respond/1)
  end

  defp respond({:message_create, message, channel_id}) do
    send_message(message, channel_id)
  end

  defp respond({:dm_create, message, user_id}) do
    with {:ok, channel_id} <- create_dm(user_id) do
      send_message(message, channel_id)
    end
  end

  defp respond({:reaction_add, emoji_list, channel_id, message_id}) when is_list(emoji_list) do
    for emoji <- emoji_list do
      :timer.sleep(100)
      add_reaction(emoji, channel_id, message_id)
    end
  end

  defp respond({:reaction_add, emoji, channel_id, message_id}) do
    add_reaction(emoji, channel_id, message_id)
  end

  defp respond(:no_action), do: nil

  defp handle_api_response(response) do
    case response do
      {:ok} ->
        {:ok}

      {:ok, message} ->
        {:ok, message}

      error ->
        Logger.warn("Received API error response: #{inspect(error)}")
        error
    end
  end
end
