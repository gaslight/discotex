defmodule DiscotexBot.Responders.SimpleResponder do
  @moduledoc """
  A module to handle simple regex call/response interactions
  """

  # remove Discord Struct references
  alias DiscotexBot.Responders.{PollResponder, RandomResponder, SimpleResponder}
  alias Nostrum.Struct.{Emoji, Message, User}

  @discotex_id 550_303_830_684_860_428
  @message_types [
    {~r/\bayy lmao\b/i, :ayy_lmao},
    {~r/\bchoir can\b/i, :choir_can},
    {~r/\bhi\b/i, :hi},
    {~r/\bbees\b/i, :bees},
    {~r/\bcommands\b/i, :commands},
    {~r/\bdance,? Haley\b/i, :dance_haley},
    {~r/\bdance,? gir\b/i, :dance_gir},
    {~r/\bdance party\b/i, :dance_party},
    {~r/\bdrop the bass\b/i, :drop_the_bass},
    {~r/\bheavy breathing\b/i, :heavy_breathing},
    {~r/\bno ragrets\b/i, :no_ragrets},
    {~r/\bnot saying it.*aliens\b/i, :aliens},
    {~r/\bshred the gnar\b/i, :shred_the_gnar},
    {~r/\bthanks obama\b/i, :thanks_obama},
    {~r/\bthis is fine\b/i, :this_is_fine},
    {~r/\bvisible confusion\b/i, :visible_confusion},
    {~r/\bwhere's the pizza\b/i, :where_is_the_pizza},
    {~r/^you're welcome$/i, :welcome}
  ]

  @message_responders [
    PollResponder,
    SimpleResponder,
    RandomResponder
  ]

  def responds_to?(message) do
    case map_message(message) do
      {:unknown, _} -> false
      _ -> true
    end
  end

  def handle_message(message) do
    message |> map_message() |> do_reply()
  end

  def message_types, do: @message_types

  defp do_reply({:aliens, message = %Message{}}) do
    {:message_create, "https://imgflip.com/i/src90", message.channel_id}
  end

  defp do_reply({:ayy_lmao, message = %Message{}}) do
    {:message_create, "https://gph.is/1Fc3HJw", message.channel_id}
  end

  defp do_reply({:bees, message}) do
    {:message_create, "http://i.imgur.com/qrLEV.gif", message.channel_id}
  end

  defp do_reply({:choir_can, message = %Message{}}) do
    {:message_create,
     "https://loldamn.com/wp-content/uploads/2017/01/Beer-can-choir-holiday-decoration.jpg",
     message.channel_id}
  end

  defp do_reply({:commands, %Message{channel_id: _channel_id, mentions: nil}}), do: :no_action

  defp do_reply({:commands, %Message{channel_id: channel_id, mentions: mentions}}) do
    if mentions_discotex?(mentions) do
      {:message_create, list_of_commands(), channel_id}
    else
      :no_action
    end
  end

  defp do_reply({:dance_haley, message}) do
    {:message_create, "http://i.imgur.com/92H3YUk.gif", message.channel_id}
  end

  defp do_reply({:dance_gir, message}) do
    {:message_create, "https://tenor.com/view/dancing-gir-dog-invader-zim-gif-9005622",
     message.channel_id}
  end

  defp do_reply({:dance_party, %Message{channel_id: channel_id, guild_id: guild_id}}) do
    {:message_create, all_dancing_emoji_message(guild_id), channel_id}
  end

  defp do_reply({:drop_the_bass, message = %Message{}}) do
    {:message_create, "http://i.imgur.com/yy4QHgx.gif", message.channel_id}
  end

  defp do_reply({:heavy_breathing, message = %Message{}}) do
    {:message_create, "https://giphy.com/gifs/heavy-breathing-FZuRP6WaW5qg", message.channel_id}
  end

  defp do_reply({:hi, message = %Message{author: user = %User{}}}) do
    {:message_create, "Hi, #{user}", message.channel_id}
  end

  defp do_reply({:shred_the_gnar, message = %Message{}}) do
    {:message_create, "https://gph.is/2lNnE57", message.channel_id}
  end

  defp do_reply({:no_ragrets, message = %Message{}}) do
    {:message_create, "http://i.ytimg.com/vi/pSW2FDXuFe4/maxresdefault.jpg", message.channel_id}
  end

  defp do_reply({:thanks_obama, message = %Message{}}) do
    {:message_create,
     "https://i.pinimg.com/originals/67/4f/4d/674f4d37697dbb0a269c43adc2929f9d.jpg",
     message.channel_id}
  end

  defp do_reply({:this_is_fine, message}) do
    {:message_create, "https://giphy.com/gifs/form-z9AUvhAEiXOqA", message.channel_id}
  end

  defp do_reply({:visible_confusion, message}) do
    {:message_create, "https://gph.is/2Qmy2Or", message.channel_id}
  end

  defp do_reply({:welcome, message}) do
    {:message_create, "https://giphy.com/gifs/hqg-tXTqLBYNf0N7W", message.channel_id}
  end

  defp do_reply({:where_is_the_pizza, message}) do
    {:message_create, "http://media.giphy.com/media/TWOlDspB628Rq/giphy.gif", message.channel_id}
  end

  defp all_dancing_emoji_message(guild_id) do
    guild_id
    |> DiscotexBot.list_guild_emojis()
    |> Enum.filter(& &1.animated)
    |> Enum.map(&Emoji.api_name/1)
    |> Enum.map(&"<:#{&1}>")
    |> Enum.join(" ")
  end

  defp command_messages(message_types) do
    Enum.map(message_types, &(&1 |> elem(0) |> stringify_regex_expression()))
  end

  defp list_of_commands do
    @message_responders
    |> Enum.map(fn responder -> command_messages(responder.message_types) end)
    |> List.flatten()
    |> Enum.reject(&is_nil(&1))
    |> Enum.join("\n")
  end

  defp mentions_discotex?(mentions) do
    Enum.any?(mentions, &(&1.id == @discotex_id))
  end

  defp stringify_regex_expression(%{source: source}), do: String.replace(source, "\\b", "")
  defp stringify_regex_expression(_), do: nil

  defp map_message(message = %Message{content: content}) do
    {_, type} =
      Enum.find(@message_types, {nil, :unknown}, fn {reg, _type} ->
        String.match?(content, reg)
      end)

    {type, message}
  end
end
