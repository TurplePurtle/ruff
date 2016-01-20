defmodule Ruff.Plugs do
  import Plug.Conn
  alias Ruff.Repo
  alias Ruff.User
  alias Monocle.Maybe

  def current_user(conn, _) do
    user =
      Maybe.from_nil(get_session(conn, :current_user))
      |> Maybe.map(&Repo.get(User, &1))
      |> Maybe.get()
    assign(conn, :current_user, user)
  end
end
