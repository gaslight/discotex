defmodule DiscotexBot.TimesheetReminderTest do
  use Discotex.DataCase

  import Mox
  import Discotex.Factory

  alias DiscotexBot.Dispatch
  alias Nostrum.Struct.{Message, User}

  setup :verify_on_exit!

  @channel_id 1234
  test "responds with list of people missing timesheet info" do
    user1 = insert(:user)
    user2 = insert(:user)

    message = %Message{
      author: %User{id: 1},
      channel_id: @channel_id,
      content: "!timesheets"
    }

    Discotex.TeamApp.RubberDuckClient
    |> expect(:missing_timesheets, fn -> {:ok, mock_timesheet_data(user1, user2)} end)

    sent_messages = Dispatch.handle_message_create(message, nil)

    assert sent_messages ==
             [
               {:message_create, "Sent messages to #{user1.name}, #{user2.name}", @channel_id},
               {:dm_create, "Please fill out your timesheet", user1.discord_id},
               {:dm_create, "Please fill out your timesheet", user2.discord_id}
             ]
  end

  defp mock_timesheet_data(user1, user2) do
    [
      %{
        "name" => user1.name,
        "work_email" => user1.email
      },
      %{
        "name" => user2.name,
        "work_email" => user2.email
      }
    ]
  end
end
