from random import randrange
import sys

s = """# States
0 1
# Target"""
print(s)
print(" ".join(str(randrange(2)) for _ in range(int(sys.argv[1]))))
s = """# Transition table
0 0 0 -> 0
0 0 1 -> 1
0 1 0 -> 1
0 1 1 -> 1
1 0 0 -> 0
1 0 1 -> 1
1 1 0 -> 1
1 1 1 -> 0"""
print(s)