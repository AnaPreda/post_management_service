defmodule PostManagementServiceTest do
  use ExUnit.Case
  doctest PostManagementService

  test "greets the world" do
    assert PostManagementService.hello() == :world
  end
end
