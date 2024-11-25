#!/usr/bin/env python3

import argparse
import re
import shlex
from dataclasses import dataclass, field
from types import NoneType
from typing import Dict, List


def ns2str(ns: int) -> str:
    if ns > 1000**2:
        return f"{ns//1000//1000}ms{ns//1000%1000}us{ns%1000}ns"
    if ns > 1000:
        return f"{ns//1000}us{ns%1000}ns"
    return f"{ns}ns"


parser = argparse.ArgumentParser()
parser.add_argument("profilefile")


@dataclass
class Record:
    stamp: int
    depth: int
    line: str
    trace: List[int]
    lineno: int
    spent: int = 0

    def __str__(self):
        return f"Record({self.stamp} {self.depth} {self.line} {self.trace} {self.lineno} {ns2str(self.spent)}"

    def printtrace(self):
        txt = ""
        for i in self.trace:
            txt += f" -> {records[i].line}"
        print(txt)


args = parser.parse_args()
records: Dict[int, Record] = {}
records[0] = Record(0, 0, "", [], 0, 0)
trace: List[int] = []
prevdepth = 0
prevlineno = 0
with open(args.profilefile, "rb") as f:
    for lineno, line in enumerate(f):
        line = line.decode(errors="replace")
        lineno += 1
        if re.match(r"^[0-9]+ \++ .+$", line):
            a, b, line = line.split(" ", 2)
            stamp = int(a)
            depth = len(b)
            line = repr(line.rstrip("\n"))
            if depth > prevdepth:
                trace.append(prevlineno)
            elif depth < prevdepth:
                if trace:
                    prev = trace[-1]
                    print(prev)
                    print(
                        "LESSDEPTH",
                        trace,
                        depth,
                        prevdepth,
                        line,
                        records[prev].line,
                        records[prev].printtrace(),
                    )
                    records[prev].spent = stamp - records[prev].stamp
                    trace.pop()
            prevdepth = depth
            prevlineno = lineno
            records[lineno] = Record(stamp, depth, line, trace, lineno)
        if lineno > 5000:
            exit()

spent2 = sorted(list(records.values()), key=lambda x: x.spent, reverse=True)
for x in spent2[:20]:
    print(x)
exit()


@dataclass
class Spent:
    lines: List[int] = field(default_factory=list)
    spent: int = 0

    def add(self, diff: int, lineno: int):
        self.spent += diff
        self.lines.append(lineno)


spent: dict[str, Spent] = {}
prev = None
for lineno, record in records.items():
    diff = record.stamp - prev if prev is not None else 0
    print(record)
    spentkey = record.line.split()[0]
    spent.setdefault(spentkey, Spent()).add(diff, lineno)
    prev = record.stamp
arr = sorted(list(spent.values()), key=lambda x: x.spent, reverse=True)
for record in arr[:20]:
    txt = " ".join(str(j) for x in record.lines for j in records[x].trace)
    txt = ""
    print(f"spent: {record.spent} {txt}")
