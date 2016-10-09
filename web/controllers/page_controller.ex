defmodule Ruff.PageController do
  use Ruff.Web, :controller

  def index(conn, _params) do
    dest = if conn.assigns.current_user do
      page_path(conn, :chat)
    else
      registration_path(conn, :new)
    end
    redirect(conn, to: dest)
  end

  def chat(conn, _params) do
    render conn, "chat.html"
  end
end
