# PROF
# for xsltproc, the xinclude can have one or two dashes

default: 
	@echo "make -n ... to display commands with running"
	@echo "make -s ... to not display commands when running them"
	@echo "Choices: html, latex, images, list (prints copy-paste select image creation), counterr, toperr, typeerr, allerr"
	@echo "make all will make html, latex, and images"

git: 
	git diff-index --stat master

${BEE}/user/mathbook-prof-latex.xsl: mathbook-prof-latex.xsl
	cp mathbook-prof-latex.xsl ${BEE}/user/

${BEE}/user/mathbook-prof-html.xsl: mathbook-prof-html.xsl
	cp mathbook-prof-html.xsl ${BEE}/user/

JChristensen.html: ${BEE}/user/mathbook-prof-html.xsl PROF.ptx 
	xsltproc --xinclude ${BEE}/user/mathbook-prof-html.xsl PROF.ptx 
	@echo ""

html: JChristensen.html

JChristensen.tex: ${BEE}/user/mathbook-prof-latex.xsl PROF.ptx 
	xsltproc --xinclude ${BEE}/user/mathbook-prof-latex.xsl PROF.ptx 

JChristensen.ind: JChristensen.idx JChristensen.tex
	makeindex JChristensen.idx

JChristensen.pdf: JChristensen.ind JChristensen.tex
	pdflatex JChristensen.tex && pdflatex JChristensen.tex  || pdflatex JChristensen.tex 

latex: JChristensen.tex

index: JChristensen.ind

pdf: JChristensen.pdf

images: PROF.ptx
	${BEE}/script/mbx -v -c latex-image -f svg -d images ${AIY}/PROF.ptx
#	${BEE}/script/mbx -v -c latex-image -r [specific image reference] -f svg -d images ${AIY}/PROF.ptx


# To list the images in the ptx and print a line that will check to see if that image exists and (if not) try to create the image...

list: PROF.ptx
	rm -f ./scripts/runlist
	cp ./scripts/.script ./scripts/runlist
	cat PROF.ptx | \
		sed 's/^ *<image/<image/g' | \
		grep '<image' | grep -v "images" | \
		sed 's/ width=.*>/>/g' | \
		sed 's+^.*ptx:id=\"\(.*\)\">+ls images/\1.svg || ${BEE}/script/mbx \-v \-c latex-image \-r \1 \-f svg \-d images ${AIY}/PROF.ptx || ${BEE}/script/mbx \-v \-c latex-image \-r \1 \-f source \-d images ${AIY}/PROF.ptx+g' >> ./scripts/runlist
	@echo "run the script   ./scripts/runlist   to create any images that do not currently exist."

checkref: PROF.ptx
	@echo "The following checks for common mistakes I have made in the past (bad xrefs)"
	@grep "</xref>" PROF.ptx | sed 's@.*\(\<xref .*\/xref\>\).*@\1@g' | grep -v "text=" | sort -k2
	@grep "</xref>" PROF.ptx | sed 's@\(.*\)\(\<xref .*\/xref\>\)\(.*\)@\1@g' | grep "</xref>" | sed 's@\(.*\)\(\<xref .*\/xref\>\)\(.*\)@\2@g' | grep -v "text=" | sort -k2
	@grep "</xref>" PROF.ptx | sed 's@\(.*\)\(\<xref .*\/xref\>\)\(.*\)@\1@g' | grep "</xref>" PROF.ptx | sed 's@\(.*\)\(\<xref .*\/xref\>\)\(.*\)@\1@g' | grep "</xref>" | sed 's@\(.*\)\(\<xref .*\/xref\>\)\(.*\)@\2@g' | grep -v "text=" | sort -k2
	@grep "</xref>" PROF.ptx | sed 's@\(.*\)\(\<xref .*\/xref\>\)\(.*\)@\3@g' | grep "</xref>" | sed 's@\(.*\)\(\<xref .*\/xref\>\)\(.*\)@\2@g' | grep -v "text=" | sort -k2
	@grep "</xref>" PROF.ptx | sed 's@\(.*\)\(\<xref .*\/xref\>\)\(.*\)@\3@g' | grep "</xref>" PROF.ptx | sed 's@\(.*\)\(\<xref .*\/xref\>\)\(.*\)@\1@g' | grep "</xref>" | sed 's@\(.*\)\(\<xref .*\/xref\>\)\(.*\)@\2@g' | grep -v "text=" | sort -k2


counterr: ${BEE}/../jing-trang/build/jing.jar ${BEE}/../jing-trang/build/xercesImpl.jar ${BEE}/schema/pretext.rng PROF.ptx 
	@echo "Counting lines from checking for specific types of errors"
	@echo `java -classpath ${BEE}/../jing-trang/build -Dorg.apache.xerces.xni.parser.XMLParserConfiguration=org.apache.xerces.parsers.XIncludeParserConfiguration \
		-jar ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng PROF.ptx | wc -l`" errors (41 known errors)"
	@echo -e "part: \t\t"`java -classpath ${BEE}/../jing-trang/build -Dorg.apache.xerces.xni.parser.XMLParserConfiguration=org.apache.xerces.parsers.XIncludeParserConfiguration \
		-jar ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng PROF.ptx | grep ": element \"part" | wc -l`" \t(24 known, hidden)"
	@echo -e "font: \t\t"`java -classpath ${BEE}/../jing-trang/build -Dorg.apache.xerces.xni.parser.XMLParserConfiguration=org.apache.xerces.parsers.XIncludeParserConfiguration \
		-jar ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng PROF.ptx | grep ": element \"font" | wc -l`" \t(4 known, hidden)"
	@echo -e "paragraph: \t"`java -classpath ${BEE}/../jing-trang/build -Dorg.apache.xerces.xni.parser.XMLParserConfiguration=org.apache.xerces.parsers.XIncludeParserConfiguration \
		-jar ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng PROF.ptx | grep ": element \"paragraph" | wc -l`" \t(1 known, hidden)"
	@echo -e "tabular: \t"`java -classpath ${BEE}/../jing-trang/build -Dorg.apache.xerces.xni.parser.XMLParserConfiguration=org.apache.xerces.parsers.XIncludeParserConfiguration \
		-jar ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng PROF.ptx | grep ": element \"tabular" | wc -l`" \t(1 known, hidden)"
	@echo -e "license: \t"`java -classpath ${BEE}/../jing-trang/build -Dorg.apache.xerces.xni.parser.XMLParserConfiguration=org.apache.xerces.parsers.XIncludeParserConfiguration \
		-jar ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng PROF.ptx | grep frontmatterPROF.ptx | wc -l`" \t(11 known, hidden)"

toperr: ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng PROF.ptx 
	java -classpath ${BEE}/../jing-trang/build -Dorg.apache.xerces.xni.parser.XMLParserConfiguration=org.apache.xerces.parsers.XIncludeParserConfiguration \
		-jar ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng PROF.ptx | head -5

typeerr: counterr ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng PROF.ptx 
	java -classpath ${BEE}/../jing-trang/build -Dorg.apache.xerces.xni.parser.XMLParserConfiguration=org.apache.xerces.parsers.XIncludeParserConfiguration \
		-jar ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng PROF.ptx | \
		grep -v ": element \"part" | \
		grep -v ": element \"font" | \
		grep -v `grep -n "xml:id=\"p-intuition-motion" PROF.ptx | sed s/:.*//g` | \
		grep -v `grep -n "Known tag abuse 1" PROF.ptx | sed s/:.*//g` | \
		grep -v "frontmatterPROF.ptx" | \
		sed 's/.*:\([0-9][0-9]*\):\([0-9][0-9]*\): error: element "\([a-zA-Z][a-zA-Z]*\)".*/\3 line \1:\2/g' | \
		sort -k1

#grep -v `grep -n "xml:id=\"p-intuition-motion" src/part-introMFE.ptx | sed s/:.*//g` | \
#grep -v `grep -n "Known tag abuse 1" src/part-prerequisites.ptx | sed s/:.*//g` | \

# To find the errors on "todo"  (must change in two places)                                                vvvv                                                 vvvv
# 	java -classpath ${BEE}/../jing-trang/build -Dorg.apache.xerces.xni.parser.XMLParserConfiguration=org.apache.xerces.parsers.XIncludeParserConfiguration -jar ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng PROF.ptx | grep ": element \"todo" | sed 's/.*:\([0-9][0-9]*\):\([0-9][0-9]*\):.*/todo line \1:\2/g'
#                                                                                                          ^^^^                                                 ^^^^

allerr: checkref counterr ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng PROF.ptx 
	java -classpath ${BEE}/../jing-trang/build -Dorg.apache.xerces.xni.parser.XMLParserConfiguration=org.apache.xerces.parsers.XIncludeParserConfiguration \
		-jar ${BEE}/../jing-trang/build/jing.jar ${BEE}/schema/pretext.rng PROF.ptx | \
		grep -v ": element \"part" | \
		grep -v ": element \"font" | \
		grep -v `grep -n "xml:id=\"p-intuition-motion" PROF.ptx | sed s/:.*//g` | \
		grep -v `grep -n "Known tag abuse 1" PROF.ptx | sed s/:.*//g` | \
		grep -v "frontmatterPROF.ptx" | \
		sort -k4  

#grep -v `grep -n "xml:id=\"p-intuition-motion" src/part-introMFE.ptx | sed s/:.*//g` | \
#grep -v `grep -n "Known tag abuse 1" src/part-prerequisites.ptx | sed s/:.*//g` | \

all: html latex images
