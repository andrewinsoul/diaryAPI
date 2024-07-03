defmodule DiaryAPIWeb.ParentJSON do
  @doc """
  Renders a single user.
  """

  def show(%{data: data, code: code}), do: success_resp(data, code)

  defp success_resp(data, code) do
    Map.put_new(%{code: code, success: true}, :data, data)
    |> Map.replace(:code, code || "OK")
  end

  defp failure_resp(error, code) do
    Map.put_new(%{code: nil, success: false}, :errors, error)
    |> Map.replace(:code, code || "NOT OK")
  end

  def show_error(%{error: error, code: code}), do: failure_resp(error, code)
end
