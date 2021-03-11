defmodule DiscotexBot.Responders.TimesheetResponder do
  @moduledoc """
  Handles command to send timesheet reminders
  """
  alias Nostrum.Struct.Message

  @message_type ~r/^!timesheets$/

  def responds_to?(%{content: message}) do
    String.match?(message, @message_type)
  end

  def handle_message(message) do
    message |> do_reply()
  end

  defp do_reply(%Message{channel_id: channel_id}) do
    case Discotex.get_users_with_missing_timesheets() do
      [] ->
        {:dm_create, "No missing timesheets!", channel_id}

      users_missing_timesheets ->
        messages = build_reminder_messages(users_missing_timesheets)
        [{:dm_create, build_admin_message(users_missing_timesheets), channel_id} | messages]
    end
  end

  defp build_reminder_messages(users) do
    users
    |> Enum.map(&build_reminder_message/1)
  end

  defp build_reminder_message(user) do
    {:dm_create, "Please fill out your timesheet", user.discord_id}
  end

  defp build_admin_message(users) do
    name_list =
      users
      |> Enum.map(fn user -> user.name end)
      |> Enum.join(", ")

    "Sent messages to #{name_list}"
  end
end
