from dataclasses import dataclass

constant = 1048576

#defining the momentum vector with x,y,z coordinates
@dataclass
class momentum:
    fPx: int
    fPy: int
    fPz: int 
    
    def __init__(self, fPx : float, fPy : float, fPz: float):
        self.fPx = int(fPx * constant)
        self.fPy = int(fPy * constant)
        self.fPz = int(fPz * constant)
    
    #overloading of add operator
    def __add__(self, other):
        if not isinstance(other, momentum):
            return NotImplemented

        return momentum(fPx=self.fPx + other.fPx, fPy=self.fPy + other.fPy, fPz=self.fPz + other.fPz)
    
    #overloading of sub operator
    def __sub__(self, other):
        if not isinstance(other, momentum):
            return NotImplemented

        return momentum(fPx=self.fPx - other.fPx, fPy=self.fPy - other.fPy, fPz=self.fPz - other.fPz)
    
    #overloading of multiplication operator
    def __mul__(self, other):
        if not isinstance(other, momentum):
            return NotImplemented

        return self.fPx * other.fPx + self.fPy * other.fPy + self.fPz * other.fPz
    
    #overloading of the print
    def __repr__(self):
        return f'{self.fPx}\t{self.fPy}\t{self.fPz}'

    
def reverse(p1 : momentum):
    p1.fPx = p1.fPx / constant
    p1.fPy = p1.fPy / constant
    p1.fPz = p1.fPz / constant
    
    return p1
    