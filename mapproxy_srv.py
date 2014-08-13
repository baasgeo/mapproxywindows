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
import sys
from cherrypy import wsgiserver 
from mapproxy.wsgiapp import make_wsgi_app
if sys.hexversion > 0x03000000:
    import winreg
else:
    import _winreg as winreg

# globals
version='1.0.0'
rootkey=winreg.HKEY_LOCAL_MACHINE
subkey=r'SOFTWARE\COMPANY\APP\NUM'
server_ip='0.0.0.0'

class MyService(win32serviceutil.ServiceFramework):
    """NT Service."""
    
    _svc_name_ = 'MapProxy-' + version
    _svc_display_name_ = 'MapProxy ' + version
    _svc_description_ = 'This service runs the MapProxy tile server'
    
    def SvcDoRun(self):
        key=winreg.OpenKey(rootkey, subkey, 0, winreg.KEY_READ)
        port_to_bind=int(winreg.QueryValueEx(key, 'Port')[0])
        data_dir=str(winreg.QueryValueEx(key, 'DataDir')[0])
        app_config=data_dir + r'\mapproxy.yaml'
        log_conf=data_dir + r'\log.ini'
        
        fileConfig(log_conf, {'here': data_dir})
        application=make_wsgi_app(app_config)
        d=wsgiserver.WSGIPathInfoDispatcher({'/mapproxy': application})
        self.server=wsgiserver.CherryPyWSGIServer( (server_ip, port_to_bind), d, numthreads=10, server_name=None, max=-1, request_queue_size=2048, timeout=10, shutdown_timeout=5)
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