defmodule XHTTP1.RequestTest do
  use ExUnit.Case, async: true
  alias XHTTP1.Request

  describe "encode/5" do
    test "with header" do
      request =
        Request.encode("GET", "/", "example.com", [{"foo", "bar"}], nil)
        |> IO.iodata_to_binary()

      assert request ==
               request_string("""
               GET / HTTP/1.1
               host: example.com
               user-agent: xhttp/0.1.0
               foo: bar

               """)
    end

    test "with body" do
      request =
        Request.encode("GET", "/", "example.com", [], "BODY")
        |> IO.iodata_to_binary()

      assert request ==
               request_string("""
               GET / HTTP/1.1
               host: example.com
               user-agent: xhttp/0.1.0
               content-length: 4

               BODY\
               """)
    end

    test "with overridden content-length" do
      request =
        Request.encode("GET", "/", "example.com", [{"content-length", "10"}], "BODY")
        |> IO.iodata_to_binary()

      assert request ==
               request_string("""
               GET / HTTP/1.1
               host: example.com
               user-agent: xhttp/0.1.0
               content-length: 10

               BODY\
               """)
    end

    test "invalid request target" do
      assert catch_throw(Request.encode("GET", "/ /", "example.com", [], nil)) ==
               {:xhttp, :invalid_request_target}
    end

    test "invalid header name" do
      assert catch_throw(Request.encode("GET", "/", "example.com", [{"f oo", "bar"}], nil)) ==
               {:xhttp, {:invalid_header_name, "f oo"}}
    end

    test "invalid header value" do
      assert catch_throw(Request.encode("GET", "/", "example.com", [{"foo", "bar\r\n"}], nil)) ==
               {:xhttp, {:invalid_header_value, "foo", "bar\r\n"}}
    end
  end

  defp request_string(string) do
    String.replace(string, "\n", "\r\n")
  end
end
