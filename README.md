# ArtNet

An Elixir library for decoding and encoding ArtNet packets.

Art-Net is a protocol for transmitting DMX data over IP networks. It is used in the entertainment industry to control lighting equipment such as dimmers, moving lights, and LED fixtures.

Art-Net 4 specification from Artistic Licence: [art-net.pdf](https://artisticlicence.com/WebSiteMaster/User%20Guides/art-net.pdf)


> [!NOTE]
> This library provides encode/decode functionality. It does not provide network transfer functionality.

## Installation


```elixir
def deps do
  [
    {:art_net, "~> 0.1.0"}
  ]
end
```


