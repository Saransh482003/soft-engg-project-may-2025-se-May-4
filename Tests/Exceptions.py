class NoFunctionException(Exception):
    def __init__(self,stmt):
        self.stmt=stmt
    def __str__(self):
        return self.stmt
class UnequalTestSetException(Exception):
    def __init__(self):
        self.stmt="There is a mismatch between the number of Test cases and The number of expected cases"
    def __str__(self):
        return self.stmt