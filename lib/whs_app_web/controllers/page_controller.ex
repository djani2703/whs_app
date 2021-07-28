defmodule WhsAppWeb.PageController do
  use WhsAppWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
