# DAWFileKit

A Swift library for reading and writing interchange file formats between popular DAW applications.

Unit tests implemented.

## Currently Supported File Formats

- Cubase
  - Track Archive XML ( import / export )
- Pro Tools
  - Session Info Text file ( import )

## Development Status

### To Do

- Cubase
  - Track Archive XML
    - [ ] Infer tempo curve calculation for events on tracks set to musical-mode timebase (a fair bit of trial and error has been put into this so far without success)
- Pro Tools
  - Session Info Text file
    - [ ] add subframes capability to PT session info parser
    - [ ] check frame rate strings PT outputs to Session Info text file and ensure parser reads them correctly
