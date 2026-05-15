# ArtNet

An Elixir library for decoding and encoding ArtNet packets.

Art-Net is a protocol for transmitting DMX data over IP networks. It is used in the entertainment industry to control lighting equipment such as dimmers, moving lights, and LED fixtures.

Art-Net 4 specification from Artistic Licence: [art-net.pdf](https://artisticlicence.com/WebSiteMaster/User%20Guides/art-net.pdf)

> [!NOTE]
> This library provides encode/decode functionality. It does not provide network transfer functionality.

## ArtNet Packet Structure

The Art-Net packet structure is as follows:

```
  0      7 8      9 10    11 12     15
  +--------+--------+--------+--------+
  |  ID    | OpCode | ProtVer|  Data  |
  +--------+--------+--------+--------+
  |            Data                   |
  +--------+--------+--------+--------+
```

### Header

- **ID** (8 bytes): The ASCII string "Art-Net\0".
- **OpCode** (2 bytes): The operation code (OpCode) identifies the packet type, such as `0x5000` for an `ArtDmx` packet, and is transmitted in little-endian byte order.
- **ProtVer** (2 byte): The protocol version number. The current version is 14. Note that this field is not present in all OpCodes.

### Data

The data section contains the payload of the packet. The structure of the data section depends on the OpCode.

## ArtNet Packet

The `ArtNet.Packet` module provides functions for encoding and decoding Art-Net packets.

The `ArtNet.Packet.Schema` module defines the schema for the Art-Net packet by using the `defpacket` macro. The schema is used to encode and decode the packet.

### ArtDmx

The `ArtDmx` packet is used to transmit DMX data over Art-Net. It is used to control lighting fixtures.

### ArtPoll

The `ArtPoll` packet is used to discover Art-Net nodes on the network.

### ArtPollReply

The `ArtPollReply` packet is used to respond to an `ArtPoll` packet.

## Packet Definitions

The `ArtNet.Packet.Schema` module provides packet definitions macro. The packet definitions are used to encode and decode the packet. The packet definitions are defined using the `defpacket` macro.

```elixir
defmodule ArtNet.Packet.ArtDmx do
  use ArtNet.Packet.Schema

  defpacket do
    field(:sequence, {:integer, 8}, default: 0)
    field(:physical, {:integer, 8}, default: 0)
    field(:sub_universe, {:integer, 8}, default: 0)
    field(:net, {:integer, 8}, default: 0)
    field(:length, {:integer, 16})
    field(:data, [{:integer, 8}])
  end
end
```

The `defpacket` macro defines a packet schema with the specified OpCode. The schema defines the fields of the packet. The fields are defined using the `field` macro.

The `field` macro defines a field in the packet schema. The field macro takes the field name, the field type, and optional parameters such as the default value.

The field type is a tuple with the type and the size of the field. The supported field types are `:integer`, `:string`, and `:binary` and `EnumTable` and `BitField`.

The `ArtNet.Packet.Schema` module provides functions for encoding and decoding packets. The `encode/1` function encodes the packet, and the `decode/1` function decodes the packet.

### EnumTable

The `EnumTable` field type is used to define a field that maps integer values to enum values.

The `ArtNet.Packet.EnumTable` module provides packet definitions macro. The packet definitions are used to encode and decode the packet. The packet definitions are defined using the `defenumtable` macro.

```elixir
defmodule ArtNet.Packet.EnumTable.Priority do
  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 8],
    dp_all: 0x00,
    dp_low: 0x40,
    dp_med: 0x80,
    dp_high: 0xC0
  )
end
```

The `defenumtable` macro defines the bit size of an enumeration table and the enumeration table. The enumeration table defines atom and value pairs for the field. These pairs are used to encode and decode.

### BitField

The `BitField` field type is used to define a field that maps an integer, boolean, or EnumTable type to a bit field.

The `ArtNet.Packet.BitField` module provides packet definitions macro. The packet definitions are used to encode and decode the packet. The packet definitions are defined using the `defbitfield` macro.

```elixir
defmodule ArtNet.Packet.BitField.TalkToMe do
  use ArtNet.Packet.BitField

  defbitfield bit_size: 8 do
    field(:reply_on_change, :boolean, offset: 1)
    field(:diagnostics, :boolean)
    field(:diag_unicast, :boolean)
    field(:vlc, :boolean)
  end
end
```

The `defbitfield` macro defines the bit size of a bit field and the fields of the bit field. The fields are defined using the `field` macro.

The `field` macro defines a field in the bit field. The field macro takes the field name, the field type, and optional parameters such as the offset.

The field type is a tuple with the type and the size of the field. The supported field types are `:integer`, `:boolean`, and `EnumTable`. The `EnumTable` field type is used to define a field that maps integer values to enum values. Offset Option is used to define the bit offset of the field.

### Packet Validation

The `ArtNet.Packet.Schema` module provides functions for validating packets. The `validate/1` function validates the packet schema.

If you need to define your own validation, add the `validate/1` function. It is evaluated at decode/encode time in addition to the schema validation.

The `validate/1` function returns `:ok` if the packet is valid and `{:error, reason}` if the packet is invalid.

## Examples

For a simple example of using this library, see the LiveBook [example notebook](livebook/artnet_sample.livemd).

### Packet Encode

The `ArtNet.encode/1` function encodes an Art-Net packet.

```elixir
packet = %ArtNet.Packet.ArtDmx{
  sequence: 0,
  physical: 0,
  sub_universe: 0,
  net: 0,
  length: 512,
  data: Enum.map(1..512, fn _ -> 0 end)
}

{:ok, _binary} = ArtNet.encode(packet)
```

The `ArtNet.encode!/1` function encodes an Art-Net packet and raises an error if the encoding fails.

### Packet Decode

The `ArtNet.decode/1` function decodes an Art-Net packet.

```elixir
data = Enum.map(1..512, fn _ -> 0xFF end)
binary = <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x50, 0x00, 0x0E, 0x01, 0x00, 0x00, 0x00, 0x02, 0x00>> <> Enum.into(data, <<>>, & <<&1>>)
{:ok, 
  %ArtNet.Packet.ArtDmx{
    sequence: 1,
    physical: 0,
    sub_universe: 0,
    net: 0,
    length: 512,
    data: ^data
  }} = ArtNet.decode(binary)
```

The `ArtNet.decode!/1` function decodes an Art-Net packet and raises an error if the decoding fails.

## Benchmark

Encode/decode benchmarks are provided in [`bench/encode_decode.exs`](bench/encode_decode.exs).

```sh
mix run bench/encode_decode.exs
```

The benchmark measures `ArtNet.encode/1` and `ArtNet.decode/1` with `ArtPoll` and various `ArtDmx` payload sizes.

## Art-Net Protocol Support

The following table lists Art-Net OpCodes and the current support status in this library.
The OpCode list is based on the Art-Net 4 Protocol Release V1.4 specification.

Status: ✅ supported, ❌ not supported.

| OpCode | Packet | Description | Status |
| --- | --- | --- | --- |
| `0x2000` | `ArtPoll` | Discover Art-Net nodes. | ✅ |
| `0x2100` | `ArtPollReply` | Respond to an `ArtPoll` packet with device status information. | ✅ |
| `0x2300` | `ArtDiagData` | Send diagnostics and data logging information. | ✅ |
| `0x2400` | `ArtCommand` | Send text-based parameter commands. | ✅ |
| `0x2700` | `ArtDataRequest` | Request data such as product URLs. | ✅ |
| `0x2800` | `ArtDataReply` | Reply to an `ArtDataRequest` packet. | ✅ |
| `0x5000` | `ArtDmx` / `ArtOutput` | Transmit zero start code DMX512 data for a single universe. | ✅ |
| `0x5100` | `ArtNzs` | Transmit non-zero start code DMX512 data, except RDM, for a single universe. | ✅ |
| `0x5200` | `ArtSync` | Force synchronous transfer of `ArtDmx` packets to node outputs. | ✅ |
| `0x6000` | `ArtAddress` | Send remote programming information for a node. | ✅ |
| `0x7000` | `ArtInput` | Enable or disable DMX inputs. | ✅ |
| `0x8000` | `ArtTodRequest` | Request a Table of Devices for RDM discovery. | ✅ |
| `0x8100` | `ArtTodData` | Send a Table of Devices for RDM discovery. | ✅ |
| `0x8200` | `ArtTodControl` | Send RDM discovery control messages. | ✅ |
| `0x8300` | `ArtRdm` | Send non-discovery RDM messages. | ✅ |
| `0x8400` | `ArtRdmSub` | Send compressed RDM sub-device data. | ✅ |
| `0x9000` | `ArtMedia` | Send media-server data to a controller. | ❌ |
| `0x9100` | `ArtMediaPatch` | Send media patch data to a media server. | ❌ |
| `0x9200` | `ArtMediaControl` | Send media control data to a media server. | ❌ |
| `0x9300` | `ArtMediaControlReply` | Reply with media control data from a media server. | ❌ |
| `0x9700` | `ArtTimeCode` | Transport time code over the network. | ✅ |
| `0x9800` | `ArtTimeSync` | Synchronize real-time date and clock data. | ✅ |
| `0x9900` | `ArtTrigger` | Send trigger macros. | ✅ |
| `0x9a00` | `ArtDirectory` | Request a node's file list. | ❌ |
| `0x9b00` | `ArtDirectoryReply` | Reply to `ArtDirectory` with a file list. | ❌ |
| `0xa010` | `ArtVideoSetup` | Send video screen setup information for extended video features. | ❌ |
| `0xa020` | `ArtVideoPalette` | Send color palette setup information for extended video features. | ❌ |
| `0xa040` | `ArtVideoData` | Send display data for extended video features. | ❌ |
| `0xf000` | `ArtMacMaster` | Deprecated packet. | ❌ |
| `0xf100` | `ArtMacSlave` | Deprecated packet. | ❌ |
| `0xf200` | `ArtFirmwareMaster` | Upload firmware or firmware extensions to a node. | ❌ |
| `0xf300` | `ArtFirmwareReply` | Acknowledge receipt of firmware or file-transfer packets. | ❌ |
| `0xf400` | `ArtFileTnMaster` | Upload a user file to a node. | ❌ |
| `0xf500` | `ArtFileFnMaster` | Download a user file from a node. | ❌ |
| `0xf600` | `ArtFileFnReply` | Acknowledge file download packets. | ❌ |
| `0xf800` | `ArtIpProg` | Reprogram a node IP address and subnet mask. | ✅ |
| `0xf900` | `ArtIpProgReply` | Acknowledge receipt of an `ArtIpProg` packet. | ✅ |

## Installation

```elixir
def deps do
  [
    {:art_net, "~> 0.1.0", github: "nasshu2916/artnet_ex", branch: "main"}
  ]
end
```
