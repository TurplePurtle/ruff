defmodule Ruff.User do
  use Ruff.Web, :model

  schema "users" do
    field :username, :string
    field :crypted_password, :string
    field :password, :string, virtual: true

    timestamps
  end

  @required_fields ~w(username password)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:username)
    |> validate_format(:username, ~r/^[A-Za-z0-9_\-]{3,}$/)
    |> validate_length(:password, min: 6)
  end
end
