defmodule DiaryAPIWeb.ResponseCodes do
  @type response_code_map :: %{
          created: String.t(),
          duplicate: String.t(),
          invalid: String.t(),
          deleted: String.t(),
          server_error: String.t(),
          found: String.t(),
          forbidden: String.t(),
          updated: String.t(),
          not_found: String.t(),
          ok: String.t(),
          unauthorized: String.t(),
          unauthenticated: String.t()
        }
  @spec response_codes_mapper() :: response_code_map
  def response_codes_mapper() do
    %{
      :created => "CREATED",
      :duplicate => "DUPLICATE",
      :invalid => "INVALID_INPUT",
      :deleted => "DELETED",
      :server_error => "INTERNAL SERVER ERROR",
      :found => "RESOURCE_FOUND",
      :forbidden => "FORBIDDEN",
      :updated => "UPDATED",
      :not_found => "NOT_FOUND",
      :ok => "OK",
      :unauthorized => "UNAUTHORIZED",
      :unauthenticated => "UNAUTHENTICATED"
    }
  end
end
