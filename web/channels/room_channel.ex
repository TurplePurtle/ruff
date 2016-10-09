defmodule Ruff.RoomChannel do
  require Logger
  use Phoenix.Channel
  alias Ruff.ChannelMonitor, as: CM

  #
  # Join a room
  #

  def join("rooms:lobby", _message, socket) do
    Logger.info "Client connected: #{socket.assigns.client_id}"
    channel_state = CM.add_user("lobby", socket.assigns.client_id, socket.assigns.user)
    channel_state =
      if channel_state.leader == nil && socket.assigns.user != nil do
        CM.set_leader("lobby", socket.assigns.client_id)
      else
        channel_state
      end
    send self, {:after_join, channel_state}
    {:ok, socket}
  end

  def join("rooms:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  #
  # Disconnecting
  #

  def terminate(_reason, socket) do
    Logger.info "Client disconnected: #{socket.assigns.client_id}"
    channel_state = CM.remove_user("lobby", socket.assigns.client_id)
    channel_state =
      if channel_state.leader == socket.assigns.client_id do
        CM.set_leader("lobby", nil)
      else
        channel_state
      end
    broadcast! socket, "channel_update", channel_state
    :ok
  end

  #
  # Handle incoming messages
  #

  # chat messages
  def handle_in("new_msg", %{"body" => body}, %{assigns: %{user: user}} = socket)
  when user != nil do
    msg = %{body: body} |> set_user_fields(user)
    broadcast! socket, "new_msg", msg
    {:noreply, socket}
  end

  # video messages
  def handle_in("video_state", payload, %{assigns: %{user: user, client_id: client_id}} = socket)
  when user != nil do
    if client_id == CM.get_leader("lobby") do
      msg = payload |> set_user_fields(user) |> Map.merge(%{client_id: socket.assigns.client_id})
      broadcast! socket, "video_state", msg
    end
    {:noreply, socket}
  end

  # become leader
  def handle_in("take_leader", _payload, %{assigns: %{user: user, client_id: client_id}} = socket)
  when user != nil do
    channel_state = CM.set_leader("lobby", client_id)
    broadcast! socket, "channel_update", channel_state
    {:noreply, socket}
  end

  def handle_in(_, _, socket), do: {:noreply, socket}

  def handle_info({:after_join, channel_state}, socket) do
    broadcast! socket, "channel_update", channel_state
    {:noreply, socket}
  end

  #
  # Handle outgoing messages
  #

  intercept ["new_msg", "video_state"]

  def handle_out("new_msg", payload, socket) do
    push socket, "new_msg", payload
    {:noreply, socket}
  end

  def handle_out("video_state", payload, socket) do
    if socket.assigns.client_id != payload.client_id do
      push socket, "video_state", payload
    end
    {:noreply, socket}
  end

  #
  # Helpers
  #

  defp set_user_fields(msg, nil), do: msg
  defp set_user_fields(msg, user) do
    Map.merge(msg, %{userId: user.id, username: user.username})
  end
end
