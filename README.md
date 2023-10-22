The file sender code is to create a work around if some web flutter project can't open the file dialog. It happens, for instance, in OBS on Linux where the web browser crashes when opening the file dialog. 


# The way it works

## Client side
Two dialogs (showFileSenderPickDialog and showFileSenderSaveDialog) are provided to establish a connexion with the interface. This connexion is set via WebSocket and is on the port 3004 by default. 

## Interface side
When the client wants to open or save a file, this interface must be active. It is merely a client to a open file dialog or save file dialog.

# Installation

## Client side
Just use the widgets. An example of how to use them is provided in `example`.

## Interface side
The interface must be accessible to receive WebSocket connexion. You can build this interface from `file_sender_interface` in `ressource` to produce the binaries.

