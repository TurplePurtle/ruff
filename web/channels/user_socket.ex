defmodule Ruff.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "rooms:*", Ruff.RoomChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(params, socket) do
    user = case Phoenix.Token.verify(socket, "user_id", params["token"]) do
      {:ok, id} -> get_user(id)
      {:error, _} -> nil
    end
    random_hash = :crypto.strong_rand_bytes(8) |> Base.url_encode64
    client_id = "#{user && user.id}:#{random_hash}"
    socket = socket |> assign(:user, user) |> assign(:client_id, client_id)
    {:ok, socket}
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Ruff.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(%{assigns: %{user: %{id: id}}}), do: "user_sock:#{id}"
  def id(_), do: nil

  defp get_user(id) do
    Ruff.Repo.get(Ruff.User, id) |> Map.take([:id, :username])
  end
end
