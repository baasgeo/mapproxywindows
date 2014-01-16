# WSGI module for use with cherrypy

# # uncomment the following lines for logging
# # create a log.ini with `mapproxy-util create -t log-ini`
from logging.config import fileConfig
import os.path
from cherrypy import wsgiserver 
from mapproxy.wsgiapp import make_wsgi_app

PORT_TO_BIND=8080
'''The port on which this server will listen on'''
SERVER_IP='0.0.0.0'
'''Ip or name of the server hosting this http service.'''
APP_CONFIG=r'C:\programs\mapproxy\data_dir\mapproxy.yaml'
LOG_CONF=r'C:\programs\mapproxy\data_dir\log.ini'
DATA_DIR=r'C:\programs\mapproxy\data_dir'

print ' MapProxy server running at http://localhost:' + str(PORT_TO_BIND) + '/mapproxy'
print ' Close this dialog to stop the server' 

fileConfig(LOG_CONF, {'here': DATA_DIR})
application = make_wsgi_app(APP_CONFIG)
d = wsgiserver.WSGIPathInfoDispatcher({'/mapproxy': application})
server = wsgiserver.CherryPyWSGIServer( (SERVER_IP, PORT_TO_BIND), d, numthreads=10, server_name=None, max=-1, request_queue_size=5, timeout=10, shutdown_timeout=5)

if __name__ == '__main__':
   try:
      server.start()
   except KeyboardInterrupt:
      server.stop()