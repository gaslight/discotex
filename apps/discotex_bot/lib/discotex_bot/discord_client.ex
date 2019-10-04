defmodule DiscotexBot.DiscordClient do
  @moduledoc """
  Chat client adapter for Discord
  """

  use Nostrum.Consumer

  require Logger

  alias DiscotexBot.Dispatch
  alias Nostrum.Api
  alias Nostrum.Cache.Me
  alias Nostrum.Struct.{Emoji, Message}

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def send_message(content, channel_id) do
    Api.create_message(channel_id, content)
  end

  def add_reaction(emoji_name, channel_id, message_id) do
    emoji = %Emoji{name: emoji_name}
    {:ok} = Api.create_reaction(channel_id, message_id, emoji)
  end

  def get_channel_message(channel_id, message_id) do
    Api.get_channel_message(channel_id, message_id)
  end

  def handle_event(event = {:MESSAGE_CREATE, message = %Message{}, _ws_state}) do
    Logger.info("Event: #{inspect(event)}")
    respond(Dispatch.handle_message_create(message, Me.get()))
  end

  def handle_event(event) do
    Logger.info("Unhandled event: #{inspect(event)}")
  end

  defp respond({:message_create, message, channel_id}) do
    send_message(message, channel_id)
  end

  defp respond({:reaction_add, emoji, channel_id, message_id}) do
    add_reaction(emoji, channel_id, message_id)
  end

  defp respond(:no_action), do: nil
end
