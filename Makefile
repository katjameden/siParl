2speech1:
	$s -xsl:drama2speech.xsl drama/SDT6-list.xml
2speech:
	ls drama/SDT*-list.xml | $P --jobs 12 \
	'$s -xsl:drama2speech.xsl {}'

################################################
s = java -jar /usr/share/java/saxon.jar
j = java -jar /usr/share/java/jing.jar
P = parallel --gnu --halt 2
