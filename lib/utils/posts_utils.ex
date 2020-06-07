defmodule PostManagementService.PostsUtils do

  def is_valid_token(token)do
    url = Application.get_env(:post_management_service, :um_url) <> "/validate-token"

    headers = [{"Content-type", "application/json"}]
    body = "{\"token\":\"" <> token <> "\"}"
    resp = HTTPotion.post!(url , [body: body, headers: headers])
    status = resp.status_code()
    case status === 200 do
      true ->
        true
      false ->
        false
    end
  end

end