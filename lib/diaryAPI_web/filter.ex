import Ecto.Query

defmodule DiaryAPIWeb.Filter do
  def order_filter(model, params) do
    model
    |> order_by(^filter_order_by(params["order_by"]))
    |> where(^filter_where(params))
  end

  def filter(model, params) do
    model
    |> where(^filter_where(params))
  end

  def count_util(model, params, pk_col) do
    filter(model, params) |> select([p], count(field(p, ^pk_col)))
  end

  def paginate(model, params, limit, offset) do
    filter(model, params) |> select([p], p) |> limit(^limit) |> offset(^offset)
  end

  def filter_order_by(desc: col_name), do: [desc: dynamic([p], field(p, ^col_name))]

  def filter_order_by(asc: col_name),
    do: [asc: dynamic([p], field(p, ^col_name))]

  def filter_order_by(_),
    do: []

  def filter_where(params) do
    Enum.reduce(params, dynamic(true), fn
      {"user_id", value}, dynamic ->
        dynamic([p], ^dynamic and p.user_id == ^value)

      {"description", value}, dynamic ->
        dynamic(
          [p],
          ^dynamic and
            (ilike(p.description, ^"%#{value}%") or ilike(p.name, ^"%#{value}%"))
        )

      {"is_private", value}, dynamic ->
        dynamic(
          [p],
          ^dynamic and p.is_private == ^value
        )

      {"name", value}, dynamic ->
        dynamic(
          [p],
          ^dynamic and (ilike(p.description, ^"%#{value}%") or ilike(p.name, ^"%#{value}%"))
        )

      _, dynamic ->
        # Not a where parameter
        dynamic
    end)
  end

  def filter_where_and(params) do
    Enum.reduce(params, dynamic(true), fn
      {"description", value}, dynamic ->
        dynamic([p], ^dynamic and ilike(p.description, ^"%#{value}%"))

      {"name", value}, dynamic ->
        dynamic([p], ^dynamic and ilike(p.name, ^"%#{value}%"))

      _, dynamic ->
        # Not a where parameter
        dynamic
    end)
  end

  def filter_out_soft_delete_col(query) do
    query |> where([q], is_nil(q.deleted_at))
  end
end
