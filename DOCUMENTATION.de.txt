R4OS Protocol Example
=====================

Dieses Projekt ist der einfache Startpunkt fuer neue R4P-Protokollmodule in
Zig. Es nutzt die aktuelle R4DEV-Oberflaeche aus `Code/System/SDK/r4os`.

Gezeigt wird:
- R4P-init/shutdown/query/dispatch-Entries ueber
  `r4os.r4dev.protocolEntriesAsm`
- `r4os.r4dev.ProtocolApi` und `r4os.r4dev.ProtocolContext`
- Registrierung der Rolle `misc.example`
- Statusmeldung per `setStatus`
- Query-Antwort mit `ProtocolStatus`
- ein kleiner Dispatch-Vertrag auf `ProtocolBuffer`

Dispatch-Operationen:
- `1`: Echo, kopiert den Input-Buffer in den Output-Buffer.
- `2`: Checksum, schreibt eine einfache additive 32-Bit-Pruefsumme little
  endian in den Output-Buffer.

Build:

    cd Code
    ..\DevTools\Zig\zig.exe build

Ergebnis:

    Code\zig-out\EXAMPLE.R4P

Im normalen Image liegt die Datei unter:

    C:\R4OS\PROTOCOLS\EXAMPLE.R4P

Abnahme in R4OS:

    C:\>R4PTEST
    C:\>PROTOCOLS

`R4PTEST` prueft, dass `misc.example` aktiv ist und dass der Echo-Dispatch
funktioniert. `PROTOCOLS` zeigt `EXAMPLE.R4P` in der Protocol Registry.

Projektstruktur seit 0.51.22
--------------------------------

Dieses Verzeichnis ist ein eigenstaendiges R4OS-SDK-Projekt fuer EXAMPLE.R4P.

Build:

    cd Code\System\Protocols\Example
    ..\..\..\DevTools\Zig\zig.exe build

Artefakt:

    zig-out\EXAMPLE.R4P

Manifest:

    module.R4MF

Image-Zielpfad: C:\R4OS\PROTOCOLS\EXAMPLE.R4P
