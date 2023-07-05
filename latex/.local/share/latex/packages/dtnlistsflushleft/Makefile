# build latex package: dtnlistsflushleft

# this makefile assumes 'sty' and 'pdf' files are built from
# source 'dtx' and 'ins' files in a build directory, and the
# 'sty' and 'pdf' files are then copied to appropriate
# locations in the TEXMFHOME directory tree

# here are the relative paths to the build and copied files:
#
#   |-- .local
#   |   `-- share
#   |       `-- latex
#   |           `-- packages
#   |               `-- $(PACKAGE)
#   |                   |-- $(PACKAGE).dtx
#   |                   |-- $(PACKAGE).ins
#   |                   |-- $(PACKAGE).pdf
#   |                   `-- $(PACKAGE).sty
#   |-- $(TEXMFHOME)
#       |-- doc
#       |   `-- local
#       |       `-- $(PACKAGE).pdf
#       `-- tex
#           `-- latex
#               `-- local
#                   `-- $(PACKAGE).sty

# because paths are relative this makefile can be used with
# symbolic link managers like stow

# this makefile deliberately does not create or update an
# ls-R database file in TEXMFHOME


    PACKAGE = dtnlistsflushleft

PACKAGE_STY = $(PACKAGE).sty
PACKAGE_PDF = $(PACKAGE).pdf
PACKAGE_DTX = $(PACKAGE).dtx
PACKAGE_INS = $(PACKAGE).ins

    TEX_AUX = *.aux *.glo *.hd *.idx *.log *.out
    TEX_OUT = *.pdf *.sty

      LATEX = pdflatex
 LATEX_OPTS = -interaction=batchmode

LOCAL_LATEX = ../../../../../texmf/tex/latex/local/
  LOCAL_DOC = ../../../../../texmf/doc/local/

         CP = cp
         RM = rm -f


# default target
all: $(PACKAGE_STY) $(PACKAGE_PDF)

$(PACKAGE_STY):
	$(LATEX) $(LATEX_OPTS) $(PACKAGE_INS)
	$(CP) $(PACKAGE_STY) $(LOCAL_LATEX)

$(PACKAGE_PDF):
	@# requires two runs
	$(LATEX) $(LATEX_OPTS) $(PACKAGE_DTX)
	$(LATEX) $(LATEX_OPTS) $(PACKAGE_DTX)
	$(CP) $(PACKAGE_PDF) $(LOCAL_DOC)

clean:
	$(RM) $(TEX_AUX)

cleanall:
	$(RM) $(TEX_AUX) $(TEX_OUT)
