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
            # output: ~x"./script/@output"l
          ]
        ]
      )

    list.hosts
  end

  def pretty_print(data) do
    [map] = data
    Scribe.print(map[:ports], data: [:id, :name, :product, :version, {:hostname, fn _ -> map[:hostname] end}, {:ip, fn _ -> map[:ip] end}])
  end
end
