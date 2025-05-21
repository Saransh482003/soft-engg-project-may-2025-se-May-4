from Exceptions import NoFunctionException,UnequalTestSetException
import requests
import json
class unittest:
    tmap={
        "nearby_hospitals":("lattitude","longitude")
    }#A map of all the function names and their arguments
    state=False
    def __init__(self,tc:list,func:str,expected:list):
        if func not in self.tmap:
            stmt="The given function has not been added yet, Here are some added functions: "
            for fun in self.tmap:
                stmt+=fun+","
            raise NoFunctionException(stmt[:-1])# To not include the stray comma
        else:
            self.func=func
        self.expected,self.tc=expected,tc
        if len(expected)!=len(tc):
            raise UnequalTestSetException
    def __str__(self):
        if self.state:
            return "Pass"
        else:
            return "Fail"
    def test_nearby_hospitals(self,lat,long):
        dat={"latitude":lat,"longitude":long}
        response=requests.post('http://127.0.0.1:5000/nearby-hospitals',json=dat)
        if response.ok:
            return response.json()
        else:
            return response.status_code
    def test(self):
        #This tests the function with the testcases
        for ind in range(len(self.tc)):
            ag=""
            for arg in self.tc[ind]:
                ag+=str(arg)+","
            res=eval("test_"+self.func+"("+ag[:-1]+")")
            self.state=res==self.expected[ind]
            print(self)