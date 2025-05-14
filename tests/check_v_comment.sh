#!/bin/bash
cd "$(dirname "$(readlink -f "$0")")"
awk '
  /^#/{prev=prev $0 "\n";next}
  /L_.*[(][)] { L_handle_v/{
    if (!(prev ~ "@option -v")) {
      gsub(/[(].*/, "")
      print
      fail++
    }
  }
  {prev=""}
  END{ exit(fail) }
' ../bin/L_lib.sh
