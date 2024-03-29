---
title: "PerlNavigator: Perl language server"
author: "David Nebauer"
date: "3 February 2024"
style: [Standard, Latex14pt]
---

This is local installation of the [PerlNavigator perl language server][github].

It was created by following these instructions from this directory (though it
was empty at the time):

```bash
git clone https://github.com/bscan/PerlNavigator
cd PerlNavigator/
npm run ci-all
cd server/
npx tsc
```

Please note:

- The `npm` command appeared to hang for several minutes before successfully
  completing.
- If adding to a git repository, remove the `PerlNavigator/.git` subdirectory
  to avoid inadvertently adding the subtree as a submodule.

[comment]: # "URLs"
[github]: https://github.com/bscan/PerlNavigator
