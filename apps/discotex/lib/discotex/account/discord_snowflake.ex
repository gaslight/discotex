defmodule Discotex.DiscordSnowflake do
  @moduledoc """
  A discord unique identifier, 64 bit unsigned integer
  """
  use Ecto.Type
  def type, do: :bigint

  @type t :: integer()

  def cast(snowflake) when is_integer(snowflake) do
    {:ok, snowflake}
  end

  def cast(_), do: :error

  def load(snowflake) when is_integer(snowflake) do
    {:ok, snowflake}
  end

  def dump(snowflake) when is_integer(snowflake), do: {:ok, snowflake}
  def dump(_), do: :error
end
