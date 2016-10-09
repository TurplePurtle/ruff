defmodule Ruff.PageController do
  use Ruff.Web, :controller

  def index(conn, _params) do
    redirect(conn, to: page_path(conn, :chat))
  end

  def chat(conn, _params) do
    render conn, "chat.html"
  end
end
