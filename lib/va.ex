defmodule Va do
  import SweetXml

  def create_hosts(filepath) do
    list =
      File.read!(filepath)
      |> xmap(
        hosts: [
          ~x"//host"l,
          ip: ~x"./address/@addr",
          hostname: ~x"./hostnames/hostname/@name",
          ports: [
            ~x"//port"l,
            id: ~x"./@portid",
            product: ~x"./service/@product",
            name: ~x"./service/@name",
            version: ~x"./service/@version",
            # script: ~x"./script/@id"l,
            output: ~x"./script/@output"l
          ]
        ]
      )

    list.hosts
  end

  def pretty_print(hosts) do
    [data] = hosts

    IO.puts("Hosts")
    Scribe.print(data, data: [:hostname, :ip])

    IO.puts("Open Ports")
    Enum.filter(data.ports, fn %{output: output} -> output == [] end) |> Enum.map(fn x -> Map.delete(x, :output) end) |> Scribe.print()

  end
end
