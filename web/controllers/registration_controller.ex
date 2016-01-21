defmodule Ruff.RegistrationController do
  use Ruff.Web, :controller
  alias Ruff.User

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    case Ruff.Registration.create(changeset, Ruff.Repo) do
      {:ok, user} ->
        conn
        |> put_session(:current_user, user.id)
        |> redirect(to: "/")
      {:error, changeset} ->
        conn
        |> put_flash(:info, "Unable to create account")
        |> render("new.html", changeset: changeset)
    end
  end
end
