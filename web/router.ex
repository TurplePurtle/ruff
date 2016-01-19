defmodule Ruff.Router do
  use Ruff.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Ruff.Plugs.CurrentUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Ruff do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/chat", PageController, :chat
    resources "/signup", RegistrationController, only: [:new, :create]
    resources "/login", SessionController, only: [:new, :create]
    delete "/login", SessionController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", Ruff do
  #   pipe_through :api
  # end
end
