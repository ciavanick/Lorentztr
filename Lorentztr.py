import momentum as mnt
import math

constant = mnt.constant

#function to calculate with const. int digit the lorentz transformation for each axis
def casting(scale1, beta2, betax, gamma, energy1, px):
    scaleoverbeta1 =int(((scale1) / (beta2))*constant)
    gammaminusbeta =int(gamma - constant)
    gammabetaxenergy1 = int((gamma * betax * energy1)/(constant*constant))
    betweenx = int((gammaminusbeta * betax * scaleoverbeta1)/(constant*constant)) 
    #print("first part : " + str(scaleoverbeta1))
    #print("(gamma - 1.) : " + str(gammaminusbeta))
    #print("second part : " + str(gammabetaxenergy1))
    #print("between x : " + str(betweenx))
    
    return px + betweenx - gammabetaxenergy1
    
    

#defining lorentz transformation
def lorentz_transformation(fPr1, fPr2):
    
    fPrMass = int(0.93827208816*constant) #proton mass in GeV
    
    energy1 = int(math.sqrt(fPr1 * fPr1 + fPrMass * fPrMass)) #energy for the first particle 
    #print("energy1 : " + str(energy1))
    energy2 = int(math.sqrt(fPr2 * fPr2 + fPrMass * fPrMass)) #energy for the second particle 
    #print("energy2 : " + str(energy2))
    
    #total momentum
    fPtotx = fPr1.fPx + fPr2.fPx 
    fPtoty = fPr1.fPy + fPr2.fPy 
    fPtotz = fPr1.fPz + fPr2.fPz 
    #print("total momentum : " + str(fPtotx) + "\t" + str(fPtoty) + "\t" + str(fPtotz))
    
    energytot = energy1 + energy2 #total energy
    #print("energytot : " + str(energytot))
    
    #definition of the x,y,z relativistic velocity components
    betax = int(((fPtotx* constant)/ energytot))  ##in VHDL multiply the constant before
    #print("betax : " + str(betax))
    
    betay = int(((fPtoty * constant)/ energytot) ) ##in VHDL multiply the constant before
    #print("betay : " + str(betay))
    
    betaz = int(((fPtotz * constant)/ energytot) ) ##in VHDL multiply the constant before
    #print("betaz : " + str(betaz))
    ##print(str(betax) + "\t" + str(betay) + "\t" + str(betaz))
    
    #definition of the square of the relativistic velocity
    beta2 = int((betax * betax + betay * betay + betaz * betaz) / constant)
    #print("beta2 : " + str(beta2))
    #print(beta2)
    
    #definition of the lorentz gamma
    #print("math.sqrt(constant - beta2) : " + str(math.sqrt(constant - beta2)))
    gamma = int(constant*math.sqrt(constant) / (math.sqrt(constant - beta2)))
    #print("gamma : " + str(gamma))
    
    #print(type(fPr1))
    #print(fPr2)
    #definition of scaling support functions
    scale1 = int((betax * fPr1.fPx + betay * fPr1.fPy + betaz * fPr1.fPz)/constant) #for fPr1
    #print("scale1 : " + str(scale1))
    
    scale2 = int((betax * fPr2.fPx + betay * fPr2.fPy + betaz * fPr2.fPz)/constant) #for fPr2
    #print("scale2 : " + str(scale2))

    
    #Lorentz transformation of fPr1
    fPr1.fPx = casting(scale1, beta2, betax, gamma, energy1, fPr1.fPx)
    fPr1.fPy= casting(scale1, beta2, betay, gamma, energy1, fPr1.fPy)
    fPr1.fPz= casting(scale1, beta2, betaz, gamma, energy1, fPr1.fPz)
    
    #fPr1.fPx = fPr1.fPx + (gamma - 1000000) * betax * (scale1) / (beta2) - gamma * betax * energy1
    #fPr1.fPy = fPr1.fPy + (gamma - 1000000) * betay * (scale1) / (beta2) - gamma * betay * energy1
    #fPr1.fPz = fPr1.fPz + (gamma - 1000000) * betaz * (scale1) / (beta2) - gamma * betaz * energy1
    
    #Lorentz transformation of fPr1
    
    fPr2.fPx = casting(scale2, beta2, betax, gamma, energy2, fPr2.fPx)
    fPr2.fPy= casting(scale2, beta2, betay, gamma, energy2, fPr2.fPy)
    fPr2.fPz= casting(scale2, beta2, betaz, gamma, energy2, fPr2.fPz)
    
    #fPr2.fPx = fPr2.fPx + (gamma - 1.) * betax * (scale2) / (beta2)-gamma * betax * energy2
    #fPr2.fPy = fPr2.fPy + (gamma - 1.) * betay * (scale2) / (beta2)-gamma * betay * energy2
    #fPr2.fPz = fPr2.fPz + (gamma - 1.) * betaz * (scale2) / (beta2)-gamma * betaz * energy2
    
    return fPr1, fPr2
    


def main():
    #preliminary testing
    x = mnt.momentum(-0.177692,       -0.132973 ,      0.0376951)
    y = mnt.momentum(0.00145509   , -0.388307    ,   -0.0688528)
    
    print("first particle momentum :")
    print(x)
    print("second particle momentum :")
    print(y)
    p1, p2 = lorentz_transformation(x,y)
    
    
    print("first particle final momentum :")
    print(p1)
    print("second particle final momentum :")
    print(p2)
    
    p1 = mnt.reverse(p1)
    p2 = mnt.reverse(p2)
    
    print("first particle final momentum :")
    print(p1)
    print("second particle final momentum :")
    print(p2)
    
            

if __name__ == "__main__":
    main()
