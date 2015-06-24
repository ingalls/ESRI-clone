# ESRI-clone
Clone an entire ESRI rest server to geojson - A wrapper around [esri-dump](https://github.com/openaddresses/esri-dump)

## Installation

Nothing to install! Just download using `git clone git@github.com:ingalls/ESRI-clone`

## Run

`./get.sh example.com/arcgis/rest/service/`

The get script will then work its way through the server and download all the layers it finds. If it fails it will print the error
message and move on to the next service.

If you see failure please report them including the log! `./get.sh URL | tee run.log` will allow you to save your log file while still printing to STDOUT.
