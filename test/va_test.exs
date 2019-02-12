defmodule VaTest do
  use ExUnit.Case
  doctest Va

  test "temp test" do
     IO.inspect(Va.pretty_print(Va.create_hosts("nmap.xml")))
  end
end
