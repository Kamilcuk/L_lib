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


def three():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-r",
        "--rabit",
        "--abit",
        required=True,
        nargs=3,
        help="AA FDSA FFDA FF",
        # choices=("X", "Y", "Z"),
    )
    parser.add_argument("p", nargs=1)
    subparsers = parser.add_subparsers(help="subcommand help")
    parser_a = subparsers.add_parser("a", help="a help")
    parser_a.add_argument("bar", type=int, help="bar help")
    parser_b = subparsers.add_parser("b", help="b help")
    parser_b.add_argument("--baz", choices=("X", "Y", "Z"), help="baz help")
    group = parser.add_argument_group("group")
    group.add_argument("--foo1", help="foo help")
    group.add_argument("bar", help="bar help")
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--foo2", action="store_true")
    group.add_argument("--bar", action="store_false")
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--foo3", action="store_true")
    group.add_argument("--bar2", action="store_false")
    group.add_argument("bar3", nargs="?")
    args = parser.parse_args()
    print(args)


three()
