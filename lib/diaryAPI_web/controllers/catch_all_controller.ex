defmodule DiaryAPIWeb.CatchAllController do
  use DiaryAPIWeb, :controller

  def match_invalid_routes(conn, _params) do
    router_module = DiaryAPIWeb.Router
    routes = Phoenix.Router.routes(router_module)
    # route_info = Enum.filter(routes, &route_info_fn/1)

    conn
    |> put_status(404)
    |> json(%{
      "message" => "Endpoint not found, check list of available routes",
      "routes" => routes |> Enum.map(&route_info_fn/1) |> Enum.filter(&(&1 != nil))
    })
  end

  defp route_info_fn(route_data) do
    if route_data.verb != :* do
      %{
        method: route_data.verb |> Atom.to_string() |> String.upcase(),
        path: route_data.path
      }
    end
  end
end
