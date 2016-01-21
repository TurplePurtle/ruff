defmodule Ruff.RoomChannel do
  use Phoenix.Channel

  def join("rooms:lobby", _message, socket) do
    {:ok, socket}
  end
  def join("rooms:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    case socket.assigns do
      %{user: nil} -> nil
      %{user: user} ->
        msg = %{
          user_id: user.id,
          username: user.username,
          body: body,
        }
        broadcast! socket, "new_msg", msg
    end
    {:noreply, socket}
  end

  def handle_out("new_msg", payload, socket) do
    push socket, "new_msg", payload
    {:noreply, socket}
  end
end
