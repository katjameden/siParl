<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:xi="http://www.w3.org/2001/XInclude"
    exclude-result-prefixes="xs xi tei" version="2.0">

<!-- Input: Mappings.xml , Output: sp_csv.csv-->  
    <xsl:output method="text" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:variable name="allSpeakerIDs" as="xs:string*">
        <xsl:for-each select="mappings/map">
            <xsl:variable name="targetDoc" select="document(target)"/>
            <xsl:sequence select="$targetDoc//tei:sp[@who]/@who"/>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:template match="/">
        <text>xml:id,count&#10;</text>
        <xsl:for-each select="distinct-values($allSpeakerIDs)">
            <xsl:sort select="replace(., 'SDT8:', '')"/> <!-- Sort by speaker ID -->
            <xsl:variable name="remove_SDT8" select="replace(., 'SDT8:', '')"/>
            <xsl:value-of select="concat($remove_SDT8, ',')" /> <!-- Output speaker ID -->
            <xsl:value-of select="count($allSpeakerIDs[. = current()])" /> <!-- Output count -->
            <xsl:text>&#10;</xsl:text> <!-- Newline -->
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>
