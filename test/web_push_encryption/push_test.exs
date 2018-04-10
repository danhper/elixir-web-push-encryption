defmodule WebPushEncryption.PushTest do
  use ExUnit.Case

  alias WebPushEncryption.Push

  setup_all do
    {:ok, _pid} = HTTPoisonSandbox.start_link(:ok)
    :ok
  end

  setup do
    HTTPoisonSandbox.reset_requests!()
    :ok
  end

  test "normal endpoint with auth_token" do
    Push.send_web_push(Fixtures.example_input(), Fixtures.valid_subscription())
    assert Enum.count(HTTPoisonSandbox.requests()) == 1
  end

  test "gcm endpoint without auth_token" do
    assert_raise ArgumentError, fn ->
      Push.send_web_push(Fixtures.example_input(), Fixtures.valid_gcm_subscription())
    end
  end

  test "gcm endpoint with auth_token" do
    Push.send_web_push(Fixtures.example_input(), Fixtures.valid_gcm_subscription(), "auth_token")
    assert Enum.count(HTTPoisonSandbox.requests()) == 1
  end
end
