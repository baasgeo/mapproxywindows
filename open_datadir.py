import os
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
        data_dir=str(winreg.QueryValueEx(key, 'DataDir')[0])
        os.startfile(data_dir)
    
    except Exception, e:
        print str(e)