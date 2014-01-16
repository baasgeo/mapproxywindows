# MapProxyWindows

Windows installer for the excellend MapProxy tile cache solution, see http://mapproxy.org. This is not an official distribution for MapProxy and is in no way endorsed by the folks at MapProxy.org.

This installer is created to have an easy to use installation on Windows based systems. 

## Download

You can download the latest build [here](https://github.com/bartbaas/MapProxyWindows/releases/download/1.6.0-RC1/MapProxy-1.6.0-RC1.exe).

## Usage

The installer should setup MapProxy out of the box. Just download the executable and run the wizard. When the installation is completed, MapProxy is ready to run.

## Documentation

This MapProxy uses [Portable Python](http://portablepython.com/wiki/Download/) 2.7.5 to not depend or interfere on/with other Python installations. MapProxy is configured with [CherryPy](http://www.cherrypy.org/) on top as WSGI webserver. Mark Hammond's pywin32 package is used to run MapProxy as windows service.

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

This installer is released under the GPL License. See http://www.gnu.org/licenses/gpl.html for additional information.
