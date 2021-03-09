defmodule Discotex.Account do
  @moduledoc """
  The Account context.
  """

  import Ecto.Query, warn: false
  alias Discotex.Account.User
  alias Discotex.Repo
  alias Ecto.UUID

  def subscribe do
    Registry.register(Registry.AccountEvents, :user_events, [])
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  def get_users_by_emails(emails) do
    User
    |> where([u], u.email in ^emails)
    |> Repo.all()
  end

  def invite_discord_user(discord_id, email) do
    with {:ok, %User{} = user} <- find_or_create_for_discord_invite(discord_id, email) do
      notify_subscribers(
        :user_events,
        {:discord_user_added,
         %{discord_id: user.discord_id, invitation_code: user.invitation_code}}
      )

      {:ok, user}
    end
  end

  defp find_or_create_for_discord_invite(discord_id, email) do
    case get_user_by_email(email) do
      nil ->
        create_user(%{
          discord_id: discord_id,
          email: email,
          invitation_code: UUID.generate()
        })

      user ->
        update_user(user, %{
          discord_id: discord_id,
          invitation_code: UUID.generate()
        })
    end
  end

  def find_or_create_from_github(github_user, invitation_code) do
    User
    |> where(github_id: ^github_user.github_id)
    |> Repo.one()
    |> case do
      nil ->
        case Repo.one(from u in User, where: u.invitation_code == ^invitation_code) do
          nil -> {:error, :no_invitation}
          user -> update_user(user, Map.put(github_user, :invitation_code, nil))
        end

      user ->
        {:ok, user}
    end
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(user = %User{}, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(user = %User{}) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(user = %User{}) do
    User.changeset(user, %{})
  end

  defp notify_subscribers(topic, message) do
    Registry.dispatch(Registry.AccountEvents, topic, fn entries ->
      for {pid, _} <- entries, do: send(pid, message)
    end)
  end
end
