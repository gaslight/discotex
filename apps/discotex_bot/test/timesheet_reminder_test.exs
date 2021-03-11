defmodule DiscotexBot.TimesheetReminderTest do
  use ExUnit.Case

  import Mox

  alias DiscotexBot.Dispatch
  alias Nostrum.Struct.{Message, User}

  setup :verify_on_exit!

  @channel_id 1234
  test "responds with list of people missing timesheet info" do
    message = %Message{
      author: %User{id: 1},
      channel_id: @channel_id,
      content: "!timesheets"
    }

    Discotex.TeamApp.RubberDuckClient
    |> expect(:missing_timesheets, fn -> {:ok, mock_timesheet_data()} end)

    sent_messages = Dispatch.handle_message_create(message, nil)

    assert hd(sent_messages) ==
             {:message_create, "Sent messages to Tim Mecklem, Steve Loar"}
  end

  defp mock_timesheet_data do
    [
      %{
        "name" => "Tim Mecklem",
        "work_email" => "tim@gaslight.co"
      },
      %{
        "name" => "Steve Loar",
        "work_email" => "steveloar@gaslight.co"
      }
    ]
  end
end
