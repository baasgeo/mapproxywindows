"""
The most basic (working) CherryPy 3.2 WSGI Windows service possible.
Requires Mark Hammond's pywin32 package.

Taken from here: http://tools.cherrypy.org/wiki/WindowsService and modified.
License and copyright unknown. No licence or warranty claimed on my behalf.
Inquire with source mentioned above regarding either.

To see a list of options for installing, removing, starting, and stopping your service.
	python this_file.py
To install your new service type:
	python this_file.py install
Then type:
	python this_file.py start

If you get "Access Denied" you need to be admin to install, remove, start, stop.
( To run cmd as admin: Windows Key > "cmd" > CTRL+SHIFT+ENTER )
"""
import pywintypes, pythoncom, win32api, win32serviceutil, win32service
from logging.config import fileConfig
import os.path
from cherrypy import wsgiserver 
from mapproxy.wsgiapp import make_wsgi_app

VERSION='1.0.0'
PORT_TO_BIND=8080
'''The port on which this server will listen on'''
SERVER_IP='0.0.0.0' # '0.0.0.0' means "all address on this server"
'''Ip or name of the server hosting this http service.'''
APP_CONFIG=r'C:\programs\MapProxy\Config\mapproxy.yaml'
LOG_CONF=r'C:\programs\MapProxy\Config\log.ini'
DATA_DIR=r'C:\programs\mapproxy\data_dir'

class MyService(win32serviceutil.ServiceFramework):
    """NT Service."""
    
    _svc_name_ = 'MapProxy'
    _svc_display_name_ = 'MapProxy ' + VERSION
    _svc_description_ = 'This service runs the MapProxy tile server'

    def SvcDoRun(self):
        fileConfig(LOG_CONF, {'here': DATA_DIR})
        _application = make_wsgi_app(APP_CONFIG)
        _d = wsgiserver.WSGIPathInfoDispatcher({'/mapproxy': _application})
        self.server = wsgiserver.CherryPyWSGIServer( (SERVER_IP, PORT_TO_BIND), _d, numthreads=10, server_name=None, max=-1, request_queue_size=5, timeout=10, shutdown_timeout=5)
        self.server.start()

    def SvcStop(self):
        self.ReportServiceStatus(win32service.SERVICE_STOP_PENDING)
        if self.server:
            self.server.stop()
        
        self.ReportServiceStatus(win32service.SERVICE_STOPPED) 
        # very important for use with py2exe
        # otherwise the Service Controller never knows that it is stopped !
        
if __name__ == '__main__':
    win32serviceutil.HandleCommandLine(MyService)