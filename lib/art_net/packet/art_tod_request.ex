defmodule ArtNet.Packet.ArtTodRequest do
  @moduledoc """
  Requests a Table of Devices for RDM discovery.

  Controllers use this packet to ask a node for discovered RDM UIDs on one or
  more ports.
  """

  use ArtNet.Packet.Schema

  alias ArtNet.Packet.EnumTable

  defpacket op_code: {:op_tod_request, 0x8000} do
    field(:filler1, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:filler2, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")

    field(:spare, {:binary, 7},
      default: <<0::size(56)>>,
      description: "Reserved bytes, transmitted as zero."
    )

    field(:net, {:integer, 8},
      default: 0,
      description: "Bits 8-14 of the 15-bit Port-Address."
    )

    field(:command, {:enum_table, EnumTable.TodRequestCommand},
      default: :tod_full,
      description: "Table-of-devices request command."
    )

    field(:address_count, {:integer, 8},
      description: "Number of valid addresses in the address list."
    )

    field(:address, [{:integer, 8}],
      length: 32,
      description: "Low bytes of requested Port-Addresses."
    )
  end

  @impl ArtNet.Packet.Schema
  def validate(%{address_count: address_count}) when address_count <= 32, do: :ok
  def validate(_), do: {:error, "Address count must be 32 or less"}
end
