import os.path
import webbrowser
import sys
if sys.hexversion > 0x03000000:
    import winreg
else:
    import _winreg as winreg

# globals
rootkey=winreg.HKEY_LOCAL_MACHINE
subkey=r'SOFTWARE\COMPANY\APP\NUM'
        
if __name__ == '__main__':
    try:
        key=winreg.OpenKey(rootkey, subkey, 0, winreg.KEY_READ)
        port_to_bind=str(winreg.QueryValueEx(key, 'Port')[0])
        webbrowser.open('http://localhost:' + port_to_bind + '/mapproxy')
    
    except Exception, e:
        print str(e)