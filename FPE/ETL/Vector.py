from   decimal import *

class Vector(object):
    def __init__(self, args):
        """ Create a vector, example: v = Vector(1,2) """
        self.values = args
        
    def norm(self):
        """ Returns the norm (length, magnitude) of the vector """
        return Decimal(sum(comp**2 for comp in self.values)).sqrt()
        
    def normalize(self):
        """ Returns a normalized unit vector """
        norm = self.norm()
        if norm:
            normed = list(comp/norm for comp in self.values)
            return Vector(normed)
        else: return self

    def mult(self, other):
        return Vector([a * b for a, b in [x for x in zip(self.values, other.values)]])
   
    def inner(self, other):
        """ Returns the dot product (inner product) of self and other vector """
        return sum(self.mult(other).values)
