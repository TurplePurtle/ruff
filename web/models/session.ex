defmodule Ruff.Session do
  alias Ruff.User

  def login(params, repo) do
    case repo.get_by(User, username: String.downcase(params["username"])) do
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
