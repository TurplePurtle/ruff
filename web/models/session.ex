defmodule Ruff.Session do
  import Ecto.Query, only: [from: 2]

  def login(params, repo) do
    username = String.downcase(params["username"])
    query = from u in Ruff.User,
      where: fragment("lower(?)", u.username) == ^username
    case Ruff.Repo.one(query) do
      %{crypted_password: hash} = user ->
        case authenticate(params["password"], hash) do
          true -> {:ok, user}
          _    -> :error
        end
      _ -> :error
    end
  end

  defp authenticate(password, hash) do
    Comeonin.Bcrypt.checkpw(password, hash)
  end
end
