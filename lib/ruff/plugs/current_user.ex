defmodule Ruff.Plugs.CurrentUser do
  import Plug.Conn
  alias Ruff.Repo
  alias Ruff.User

  def init(default), do: default

  def call(conn, _default) do
    case get_session(conn, :current_user) do
      nil -> conn |> assign(:current_user, nil)
      id  -> conn |> assign(:current_user, Repo.get(User, id))
    end
  end
end
