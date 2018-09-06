# QIFs

This repository is for storing QIFs used in QPACK development
and interop experiments.

## Encoder Input

A QPACK encoder uses a QIF file as input.  QIF files are stored
in `qifs/` directory.

## Encoder Output

A QPACK encoder produces a file whose format is described in
[QPACK Offline Interop](https://github.com/quicwg/base-drafts/wiki/QPACK-Offline-Interop).
Outputs produced by various encoders are stored in `encoded/`
directory.

The encoder output server as the decoder input.  The idea of
the interop is to take a QIF file, encode it using an encoder
from one distribution and decode it using a decoder from another
distribution.

## Converting HARs to QIFs

A HAR is easy to manufacture using any of the major browsers.
On the other hand, a HAR is inconvenient for the kind of end-to-end
testing that the interop suggests: they are difficult to generate
and compare.  A HAR can be converted to a QIF format using
`bin/har2qif.pl` program.

## Comparing QIFs

QIFs are text files and can be compared using standard UNIX tools
such as `diff(1)`.

Because both input and output QIF files can contain comments and, more
importantly, because the decoding process may output header lists in a
different order, `bin/sort-qif.pl` is provided.  Sample use:

```
sh$ encode source.qif > encoded.bin
sh$ decode encoded.bin > result.qif
sh$ diff <(grep -v ^# source.qif) <(sort-qif.pl --strip-comments result.qif)
```
