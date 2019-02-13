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
            port: ~x"./@portid",
            product: ~x"./service/@product",
            name: ~x"./service/@name",
            version: ~x"./service/@version",
            # script: ~x"./script/@id"l,
            output: ~x"./script/@output"l,
            state: ~x"./state/@state"

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
    |> Scribe.print()

    IO.puts("Vulnerabilities")
    data = Enum.filter(data.ports, fn %{output: output} -> output != [] end)
    Scribe.print(data, data: [:port, :name, :product, :state, :version])

    [m] = data
    %{output: output} = m

    List.to_string(tl(output))
    |> String.split("\n")
    |> List.delete_at(0)
    |> List.delete_at(0)
    |> List.delete_at(0)
    |> List.to_string
    |> String.split("\t")
    |> Enum.filter(fn x -> x != "" end)
    |> Enum.chunk_every(3)
    |> Enum.map(fn [cve, cvs, link] -> %{cve: cve, cvs: cvs, link: link} end)
    |> Scribe.print()
  end
end
