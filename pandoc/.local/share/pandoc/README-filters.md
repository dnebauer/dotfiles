---
title: "Pandoc Filters"
author: "David Nebauer"
date: "9 August 2025"
style: [Standard, Latex14pt]
---

## Sources of filters

The pandoc filters come from multiple sources:

* [pandoc-ext][pandoc-ext] github repository collection:

    * [abstract-section.lua][abstract-sect], [diagram.lua][diagram],
      [include-files.lua][include-files], [list-table.lua][list-table],
      [multibib.lua][multibib], [pagebreak.lua][pagebreak],
      [pretty-urls.lua][pretty-urls], [section-bibliographies.lua][sectbib]

* [pandoc/lua-filters][lua-filters] github repository:

    * [author-info-blocks.lua][author-blocks], [doi2cite.lua][doi2cite],
      [first-line-indent.lua][first-indent],
      [include-code-files.lua][include-code], [latex-hyphen.lua][latex-hyphen],
      [not-in-format.lua][not-in-format], [scholarly-metadata.lua][scholarly],
      [short-captions.lua][short-captions], [spellcheck.lua][spellcheck],
      [table-short-captions.lua][tbl-captions], [wordcount.lua][wordcount]

* personally managed:

    * heading2bold.py, keyboard-font.lua, line-break-between-paras.lua,
      paginatesects.py, text-colour.lua

## Update script

The `update-pandoc-filters` script contains a canonical list of filters and
their sources that should match the above lists.

The script performs the following tasks:

* Download current versions of remote filters and:

    * for any filters where there is no current version, seek user permission
      to install the downloaded version

    * for filters where there is a current version, compare the downloaded
      version to the current versions and, where they differ, seek user
      permission to overwrite the current versions

* Warn user if any of the personally managed filters are not present

* Notify user of any current filters that are not in the canonical filter list.

[comment]: # (URLs)

   [abstract-sect]: https://raw.githubusercontent.com/pandoc-ext/abstract-section/refs/heads/main/_extensions/abstract-section/abstract-section.lua

   [author-blocks]: https://raw.githubusercontent.com/pandoc/lua-filters/refs/heads/master/author-info-blocks/author-info-blocks.lua

   [diagram]: https://raw.githubusercontent.com/pandoc-ext/diagram/refs/heads/main/_extensions/diagram/diagram.lua

   [doi2cite]: https://raw.githubusercontent.com/pandoc/lua-filters/refs/heads/master/doi2cite/doi2cite.lua

   [first-indent]: https://raw.githubusercontent.com/pandoc/lua-filters/refs/heads/master/first-line-indent/first-line-indent.lua

   [include-code]: https://raw.githubusercontent.com/pandoc/lua-filters/refs/heads/master/include-code-files/include-code-files.lua

   [include-files]: https://raw.githubusercontent.com/pandoc-ext/include-files/refs/heads/main/include-files.lua

   [latex-hyphen]: https://raw.githubusercontent.com/pandoc/lua-filters/refs/heads/master/latex-hyphen/latex-hyphen.lua

   [list-table]: https://raw.githubusercontent.com/pandoc-ext/list-table/refs/heads/main/_extensions/list-table/list-table.lua

   [lua-filters]: https://github.com/pandoc/lua-filters

   [multibib]: https://raw.githubusercontent.com/pandoc-ext/multibib/refs/heads/main/_extensions/multibib/multibib.lua

   [not-in-format]: https://raw.githubusercontent.com/pandoc/lua-filters/refs/heads/master/not-in-format/not-in-format.lua

   [pagebreak]: https://raw.githubusercontent.com/pandoc-ext/pagebreak/refs/heads/main/pagebreak.lua

   [pandoc-ext]: https://github.com/orgs/pandoc-ext/repositories

   [pretty-urls]: https://raw.githubusercontent.com/pandoc-ext/pretty-urls/refs/heads/main/_extensions/pretty-urls/pretty-urls.lua

   [scholarly]: https://raw.githubusercontent.com/pandoc/lua-filters/refs/heads/master/scholarly-metadata/scholarly-metadata.lua

   [sectbib]: https://raw.githubusercontent.com/pandoc-ext/section-bibliographies/refs/heads/main/_extensions/section-bibliographies/section-bibliographies.lua

   [short-captions]: https://raw.githubusercontent.com/pandoc/lua-filters/refs/heads/master/short-captions/short-captions.lua

   [spellcheck]: https://raw.githubusercontent.com/pandoc/lua-filters/refs/heads/master/spellcheck/spellcheck.lua

   [tbl-captions]: https://raw.githubusercontent.com/pandoc/lua-filters/refs/heads/master/table-short-captions/table-short-captions.lua

   [wordcount]: https://raw.githubusercontent.com/pandoc/lua-filters/refs/heads/master/wordcount/wordcount.lua
