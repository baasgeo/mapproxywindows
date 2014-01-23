# MapProxy Windows installer

Windows installer for the excellend tile cache solution MapProxy, see http://mapproxy.org. This is not an official distribution for MapProxy and is in no way endorsed by [MapProxy](http://mapproxy.org) creators.

The aim of this installer is to make the MapProxy installation as easy, automatic and production-ready as possible on Windows based systems. During installation, it is possible to specify the data directory, server port and whether to run as a Windows service.

## Download

You can download the latest build [here](https://github.com/bartbaas/MapProxyWindows/releases/download/1.6.0/MapProxy-1.6.0.exe).

## Usage

The installer should setup MapProxy out of the box. Just download the executable and run the wizard, the default settings are just fine. When the installation is completed, MapProxy is ready to run. Go to Start Menu -> Programs -> MapProxy 1.x.x -> Start MapProxy to start the server. 
The demo page is also available at the Start Menu, MapProxy Web Admin Page.

## Documentation

This MapProxy uses [Portable Python](http://portablepython.com/wiki/Download/) 2.7.5 to not depend or interfere on/with other Python installations. MapProxy is configured with [CherryPy](http://www.cherrypy.org/) on top as WSGI webserver. Pywin32 is used to run MapProxy as windows service.

Tested as working for:
- Windows 7 (32 bit)
- Windows 8 (32 bit)

Documentation for MapProxy is available at http://mapproxy.org/documentation.html.

## How To Build

For developers wanting to improve or modify this installer, clone this repository first.

    $ git clone https://github.com/bartbaas/MapProxyWindows.git
    $ cd MapProxyWindows

Make sure you have`NSIS` and `git` installed in your system, if not, grab it at http://nsis.sourceforge.net and http://git-scm.com/download/win.

Now download [Portable Python](http://portablepython.com/wiki/Download/) 2.7.5 and install the file to the `PortablePython` directory. During the extraction wizard, choose the minimal install and select the optional modules PIL and PyWin32.

Offline setup is provided by including the egg files for MapProxy. These files have to be downloaded before running the NSIS compiler. Get the egg files by running `easy_install` from the portable python folder and save them to the folder `eggs`.

    $ PortablePython\App\Scripts\easy_install -zmaxd eggs mapproxy==1.6.0 Shapely pyproj cherrypy==3.2.4

Now everything is ready to for NSIS. Create the installer by using the `makensis` program.

    $ makensis SetupMapProxy.nsi

## Contact

Created and maintained by Bart Baas

- http://github.com/bartbaas
- http://nl.linkedin.com/in/baasb/
- http://baasgeo.com

## License

This installer is released under the GPL License. See http://www.gnu.org/licenses/gpl.html for additional information. MapProxy s released under the [Apache Software License 2.0](http://www.apache.org/licenses/LICENSE-2.0.html). 
