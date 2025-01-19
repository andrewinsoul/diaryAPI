defmodule DiaryAPIWeb.ResponseCodes do
  @type response_code_map :: %{
          created: String.t(),
          duplicate: String.t(),
          invalid: String.t(),
          found: String.t(),
          ok: String.t(),
          not_found: String.t(),
          unauthorized: String.t(),
          unauthenticated: String.t()

          # created: String.t(),
          # "duplicate" => String.t(),
        }
  @spec response_codes_mapper() :: response_code_map
  def response_codes_mapper() do
    %{
      :created => "CREATED",
      :duplicate => "DUPLICATE",
      :invalid => "INVALID_INPUT",
      :found => "RESOURCE_FOUND",
      :updated => "UPDATED",
      :not_found => "NOT_FOUND",
      :ok => "OK",
      :unauthorized => "UNAUTHORIZED",
      :unauthenticated => "UNAUTHENTICATED"
    }
  end
end
