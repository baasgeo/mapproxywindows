# WSGI module for use with cherrypy

# # uncomment the following lines for logging
# # create a log.ini with `mapproxy-util create -t log-ini`
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
rootkey=winreg.HKEY_LOCAL_MACHINE
subkey=r'SOFTWARE\COMPANY\APP\NUM'
server_ip='0.0.0.0'
        
if __name__ == '__main__':
    try:
        key=winreg.OpenKey(rootkey, subkey, 0, winreg.KEY_READ)
        port_to_bind=int(winreg.QueryValueEx(key, 'Port')[0])
        data_dir=str(winreg.QueryValueEx(key, 'DataDir')[0])
        app_config=data_dir + r'\mapproxy.yaml'
        log_conf=data_dir + r'\log.ini'        

        print ' MapProxy server running at http://localhost:' + str(port_to_bind) + '/mapproxy'
        print ' Close this dialog to stop the server' 

        fileConfig(log_conf, {'here': data_dir})
        application=make_wsgi_app(app_config)
        d=wsgiserver.WSGIPathInfoDispatcher({'/mapproxy': application})
        server=wsgiserver.CherryPyWSGIServer( (server_ip, port_to_bind), d, numthreads=10, server_name=None, max=-1, request_queue_size=2048, timeout=10, shutdown_timeout=5)
        
        server.start()
        
    except KeyboardInterrupt:
        server.stop()
    
    except Exception, e:
        print str(e)