---
title: "How to create word list"
author: "David Nebauer"
date: "26 October 2025"
style: [Standard, Latex14pt]
---

Install the 'wordnet' package

In this directory, run the command:

```bash
cat /usr/share/wordnet/index* \
  | cut -d' ' -f1             \
  | sort                      \
  | uniq                      \
  > wordnet_index_all.txt
```
