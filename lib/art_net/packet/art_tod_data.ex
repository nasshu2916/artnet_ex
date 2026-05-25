defmodule ArtNet.Packet.ArtTodData do
  @moduledoc """
  Sends a Table of Devices for RDM discovery.

  Nodes use this packet to return discovered RDM UIDs and discovery response
  status to a controller.
  """

  use ArtNet.Packet.Schema

  alias ArtNet.Packet.EnumTable

  defpacket do
    field(:rdm_version, {:integer, 8}, default: 1, description: "RDM protocol version.")
    field(:port, {:integer, 8}, description: "Physical port number for the table of devices.")

    field(:spare, {:binary, 6},
      default: <<0::size(48)>>,
      description: "Reserved bytes, transmitted as zero."
    )

    field(:bind_index, {:integer, 8},
      default: 1,
      description: "Bind index of the node reporting the table."
    )

    field(:net, {:integer, 8},
      default: 0,
      description: "Bits 8-14 of the 15-bit Port-Address."
    )

    field(:command_response, {:enum_table, EnumTable.TodDataCommandResponse},
      default: :tod_full,
      description: "Table-of-devices response type."
    )

    field(:address, {:integer, 8}, description: "Low byte of the Port-Address.")
    field(:uid_total, {:integer, 16}, description: "Total number of UIDs in the full table.")

    field(:block_count, {:integer, 8},
      default: 0,
      description: "Block number for segmented tables."
    )

    field(:uid_count, {:integer, 8}, description: "Number of UIDs carried in this packet.")
    field(:tod, [{:binary, 6}], description: "List of discovered RDM UIDs.")
  end

  @impl ArtNet.Packet.Schema
  def validate(%{uid_count: uid_count, tod: tod}) when uid_count == length(tod), do: :ok
  def validate(_), do: {:error, "ToD length does not match the uid_count field"}
end
