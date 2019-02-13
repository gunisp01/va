defmodule Va do
  import SweetXml

  def create_hosts(filepath) do
    list =
      File.read!(filepath)
      |> xmap(
        hosts: [
          ~x"//host"l,
          ip: ~x"./address/@addr"s,
          hostname: ~x"./hostnames/hostname/@name"s,
          ports: [
            ~x"//port"l,
            port: ~x"./@portid"i,
            product: ~x"./service/@product"s,
            name: ~x"./service/@name"s,
            version: ~x"./service/@version"s,
            # script: ~x"./script/@id"l,
            output: ~x"./script/@output"l,
            state: ~x"./state/@state"s

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
    data.ports
    |> Enum.filter(fn %{output: output} -> output == [] end)
    |> Enum.map(fn x -> Map.delete(x, :output) end)
    |> Scribe.print()

    IO.puts("Vulnerabilities")
    data = Enum.filter(data.ports, fn %{output: output} -> output != [] end)
    Scribe.print(data, data: [:port, :name, :product, :state, :version])

    [m] = data
    %{output: output} = m

    List.to_string(tl(output))
    |> String.split("\n")
    |> Enum.drop(3)
    |> List.to_string
    |> String.split("\t")
    |> Enum.filter(fn x -> x != "" end)
    |> Enum.chunk_every(3)
    |> Enum.map(fn [cve, cvs, link] -> %{cve: cve, cvs: String.to_float(cvs), link: link} end)
    |> Scribe.print()
  end
end
