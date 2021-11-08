# photometry.py

BANDDATA={"B": 0.44352, "V": 0.54914, "R": 0.65344, "I": 0.76945,
          "J": 1.2485, "H": 1.6380, "K": 2.1455, "Ks": 2.1455 }

def get_w_of_band(band, unit='um'):
    factor = 1.0
    if unit == 'A':
        factor = 10000.0
    if band in BANDDATA:
        return BANDDATA[band] * factor
    else:
        return 0.0
    
