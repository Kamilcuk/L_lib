#!/usr/bin/env python3

import argparse

def one():
    parser = argparse.ArgumentParser()
    parser.add_argument("-r", "--rabit", "--abit", dest="bla", required=True)
    parser.add_argument("-f", "--fabit", dest="bla", required=True)
    parser.add_argument("-p", action="store_true")
    args = parser.parse_args()
    print(args)

def two():
    parser = argparse.ArgumentParser()
    parser.add_argument("-r", "--rabit", "--abit", required=True)
    parser.add_argument("p", nargs=1)
    args = parser.parse_args()
    print(args)

two()

