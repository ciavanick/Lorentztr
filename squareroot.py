#integer square root function
def sqrt(num : int):
    a = num
    b = 1
    if num < 0 or type(num) != int:
        raise TypeError("number not acceptable")
    else:
        while(a > b):
            a = int((a+b)/2)
            b = int(num/a)
        return a

#integer square root function with recursion
def sqrtr(num : int, a = 1, b = 1, c = False):
    if c == False:
        a = num
        b = 1
    
    if num < 0 or type(num) != int:
        raise TypeError("number not acceptable")
    else:
        if (a > b):
            return sqrtr(num, int((a+b)/2), int(2*num/(a+b)), True)      
        else:
            return a
            
#float square root function with fixed precision
def sqrtfloat(num):
    a = num
    b = 1
    prec = 0.00000000001
    #c = 0
    if num < 0:
        raise TypeError("number not acceptable")
    else:
        while(a - b > prec):
            a = ((a+b)/2)
            b = (num/a)
        #print(c)
        return a

#integer square root function (it has the worst computational algorithm)
def sqrt2(num : int):
    x = 0
    while(x*x < num):
       x += 1
    return x

if __name__ == "__main__":
    import cProfile
    import math
    cProfile.run('sqrt(9999999999999)')
    cProfile.run('sqrtfloat(9999999999999)')
    cProfile.run('sqrtr(9999999999999)')
    cProfile.run('sqrt2(9999999999999)')
    cProfile.run('math.sqrt(9999999999999)')
    
    print(sqrt(1423527))
    print(sqrtr(1423527))
