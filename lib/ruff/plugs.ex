defmodule Ruff.Plugs do
  import Plug.Conn
  alias Ruff.Repo
  alias Ruff.User
  import Monocle.Maybe, only: [map_nil: 2]

  def current_user(conn, _) do
    user = get_session(conn, :current_user) |> map_nil(&Repo.get(User, &1))
    assign(conn, :current_user, user)
  end
end
