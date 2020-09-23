# DAWFileKit

A Swift library for reading and writing interchange file formats between popular DAW applications.

Unit tests implemented.

## Currently Supported File Formats

- Cubase
  - Track Archive XML ( import / export )
- Pro Tools
  - Session Info Text file ( import )

## Development Status

### Unfinished Features

- Cubase
  - Track Archive XML
    - [ ] Infer tempo curve calculation for events on tracks set to musical-mode timebase (a fair bit of trial and error has been put into this so far without success)
- Pro Tools
  - Session Info Text file
    - [ ] Add subframes capability to PT session info parser
    - [ ] Check frame rate strings PT outputs to Session Info text file and ensure parser reads them correctly

### Roadmap

- [ ] Investigate and implement importers and exporters for file formats from:
  - [ ] Logic Pro X
  - [ ] Digital Performer
  - [ ] ... and more