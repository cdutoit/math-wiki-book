"""Simulate the Monty Hall game and compare sticking with switching.

Run:  python3 monty_hall.py [games]
"""
import random
import sys


def play(switch: bool) -> bool:
    doors = ["A", "B", "C"]
    car = random.choice(doors)
    pick = "A"  # we always choose door A, as in the chapter
    # The host opens a door that is neither our pick nor the car.
    host = random.choice([d for d in doors if d not in (pick, car)])
    if switch:
        pick = next(d for d in doors if d not in (pick, host))
    return pick == car


games = int(sys.argv[1]) if len(sys.argv) > 1 else 100_000
for switch in (False, True):
    wins = sum(play(switch) for _ in range(games))
    print(f"{'switch' if switch else 'stick ':6}: won {wins / games:.3f} of {games} games")
