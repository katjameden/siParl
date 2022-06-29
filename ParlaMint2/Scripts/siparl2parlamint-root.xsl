<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:tei="http://www.tei-c.org/ns/1.0"
		exclude-result-prefixes="#all"
		version="2.0">
  
  <xsl:output method="xml" indent="yes"/>
  
  <!-- Verzija -->
  <xsl:param name="edition">3.0a</xsl:param>
  <!-- CLARIN.SI Handle, kjer bo korpus shranjen v repozitoriju -->
  <xsl:param name="clarinHandle">http://hdl.handle.net/11356/1486</xsl:param>
  
  <xsl:decimal-format name="euro" decimal-separator="," grouping-separator="."/>
  
  <!-- Povezave to ustreznih taksonomij -->
  <!-- Ni jasno, ali res hočemo tule tako... -->
  <xsl:param name="taxonomy-legislature">taxo-legislature.xml</xsl:param>
  <xsl:param name="taxonomy-speakers">taxo-speakers.xml</xsl:param>
  <xsl:param name="taxonomy-subcorpus">taxo-subcorpus.xml</xsl:param>

  <!-- People (also) responsible for the TEI encoding of the corpus -->
  <xsl:variable name="TEI-resps" xmlns="http://www.tei-c.org/ns/1.0">
    <persName ref="https://orcid.org/0000-0002-1560-4099 http://viaf.org/viaf/15145066459666591823">Tomaž Erjavec</persName>
    <persName>Katja Meden</persName>
  </xsl:variable>
  
  <xsl:variable name="today" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>

  <!-- The teiHeaders of each term -->
  <xsl:variable name="teiHeaders">
    <xsl:for-each select="mappings/source">
      <xsl:copy-of select="document(.)//tei:teiHeader"/>
    </xsl:for-each>
  </xsl:variable>
  <!-- The filenames of each component, starting with the year directory -->
  <xsl:variable name="components">
    <xsl:for-each select="/mappings/map">
      <component>
	<xsl:copy-of select="replace(target, '.+?/(\d\d\d\d/)', '$1')"/>
      </component>
    </xsl:for-each>
  </xsl:variable>

  <xsl:template match="/">
    <teiCorpus xmlns="http://www.tei-c.org/ns/1.0" xml:lang="sl" xml:id="ParlaMint-SI">
      <teiHeader>
	<xsl:call-template name="fileDesc"/>
	<xsl:call-template name="encodingDesc"/>
	<xsl:call-template name="profileDesc"/>
      </teiHeader>
      <xsl:for-each select="$components/component">
	<xi:include xmlns:xi="http://www.w3.org/2001/XInclude"
		    href="{.}"/>
      </xsl:for-each>
    </teiCorpus>
  </xsl:template>
  
  <xsl:template name="fileDesc">
    <fileDesc xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:variable name="mandates">
	<xsl:for-each select="$teiHeaders//tei:titleStmt/tei:meeting">
	  <xsl:sort select="@n" data-type="number"/>
	  <xsl:copy-of select="."/>
	</xsl:for-each>
      </xsl:variable>
      <xsl:variable name="min-mandate" select="$mandates/tei:meeting[1]/@n"/>
      <xsl:variable name="max-mandate" select="$mandates/tei:meeting[last()]/@n"/>
      <xsl:variable name="min-date">
	<xsl:variable name="from-dates">
	  <xsl:for-each select="$teiHeaders//tei:sourceDesc/tei:bibl/tei:date">
	    <xsl:sort select="@from" data-type="number"/>
	    <date xmlns="http://www.tei-c.org/ns/1.0">
	      <xsl:value-of select="replace(@from, 'T.+', '')"/>
	    </date>
	  </xsl:for-each>
	</xsl:variable>
	<xsl:value-of select="$from-dates/tei:date[1]"/>
      </xsl:variable>
      <xsl:variable name="max-date">
	<xsl:variable name="to-dates">
	  <xsl:for-each select="$teiHeaders//tei:sourceDesc/tei:bibl/tei:date">
	    <xsl:sort select="@to" data-type="number"/>
	    <xsl:if test="@to">
	      <date xmlns="http://www.tei-c.org/ns/1.0">
		<xsl:value-of select="replace(@to, 'T.+', '')"/>
	      </date>
	    </xsl:if>
	  </xsl:for-each>
	</xsl:variable>
	<xsl:value-of select="$to-dates/tei:date[last()]"/>
      </xsl:variable>
      <titleStmt>
        <title type="main" xml:lang="sl">Slovenski parlamentarni korpus ParlaMint-SI [ParlaMint]</title>
        <title type="main" xml:lang="en">Slovenian parliamentary corpus ParlaMint-SI [ParlaMint]</title>
	<xsl:variable name="min-year" select="replace($min-date, '-.+', '')"/>
	<xsl:variable name="max-year" select="replace($max-date, '-.+', '')"/>
        <title type="sub" xml:lang="sl">
	  <xsl:text>Zapisi sej Državnega zbora Republike Slovenije, </xsl:text>
	  <xsl:value-of select="concat($min-mandate, '.—', $max-mandate, '. mandat ')"/>
	  <xsl:value-of select="concat('(', $min-year, '—', $max-year, ')')"/>
	</title>
        <title type="sub" xml:lang="en">
	  <xsl:text>Minutes of the National Assembly of the Republic of Slovenia, Terms </xsl:text>
	  <xsl:value-of select="concat($min-mandate, '—', $max-mandate, ' ')"/>
	  <xsl:value-of select="concat('(', $min-year, '—', $max-year, ')')"/>
	</title>
	<xsl:copy-of select="$mandates"/>
        <xsl:for-each-group select="$teiHeaders//tei:titleStmt/tei:respStmt"
			    group-by="tei:resp[@xml:lang = 'sl']">
          <respStmt>
	    <xsl:for-each select="distinct-values(current-group()/tei:persName)">
	      <xsl:variable name="this" select="."/>
	      <xsl:copy-of select="$teiHeaders//tei:titleStmt/tei:respStmt/tei:persName[.=$this]
				   [not(preceding::tei:persName[.=$this])]"/>
	    </xsl:for-each>
	    <xsl:if test="current-grouping-key() = 'Kodiranje TEI'">
	      <xsl:copy-of select="$TEI-resps"/>
	    </xsl:if>
	    <xsl:copy-of select="current-group()[1]/tei:resp"/>
          </respStmt>
	</xsl:for-each-group>
        <funder>
          <orgName xml:lang="sl">Raziskovalna infrastruktura CLARIN</orgName>
          <orgName xml:lang="en">The CLARIN research infrastructure</orgName>
        </funder>
        <funder>
          <orgName xml:lang="sl">Slovenska raziskovalna infrastruktura CLARIN.SI</orgName>
          <orgName xml:lang="en">The Slovenian research infrastructure CLARIN.SI</orgName>
        </funder>
        <funder>
          <orgName xml:lang="sl">Raziskovalni program ARRS P6-0411 "Jezikovni viri in tehnologije za slovenski jezik"</orgName>
          <orgName xml:lang="en">Slovenian Research Agency Programme P6-0411 "Language Resources and Technologies for Slovene"</orgName>
        </funder>
      </titleStmt>
      <editionStmt>
        <edition>
	  <xsl:value-of select="$edition"/>
	</edition>
      </editionStmt>
      <extent>
	<xsl:variable name="texts" select="sum($teiHeaders//tei:fileDesc/tei:extent/
					   tei:measure[@unit='texts']/@quantity)"/>
	<xsl:variable name="words" select="sum($teiHeaders//tei:fileDesc/tei:extent/
					   tei:measure[@unit='words']/@quantity)"/>
	<!-- Note that ParlaMint actually expects speeches (and words from .ana) -->
        <measure unit="texts" quantity="{$texts}">
	  <xsl:value-of select="format-number($texts,'###.###','euro')"/>
	  <xsl:text> besedil</xsl:text>
	</measure>
        <measure unit="texts" quantity="{$texts}" xml:lang="en">
	  <xsl:value-of select="format-number($texts,'###,###')"/>
	  <xsl:text> texts</xsl:text>
	</measure>
        <measure unit="words" quantity="{$words}">
	  <xsl:value-of select="format-number($words,'###.###','euro')"/>
	  <xsl:text> besed</xsl:text>
	</measure>
        <measure unit="words" quantity="{$words}" xml:lang="en">
	  <xsl:value-of select="format-number($words,'###,###')"/>
	  <xsl:text> words</xsl:text>
	</measure>
      </extent>
      <publicationStmt>
        <publisher>
          <orgName xml:lang="sl">Raziskovalna infrastrukutra CLARIN</orgName>
          <orgName xml:lang="en">CLARIN research infrastructure</orgName>
          <ref target="https://www.clarin.eu/">www.clarin.eu</ref>
        </publisher>
        <idno subtype="handle" type="URI">
	  <xsl:value-of select="$clarinHandle"/>
	</idno>
        <availability status="free">
          <licence>http://creativecommons.org/licenses/by/4.0/</licence>
          <p xml:lang="sl">To delo je ponujeno pod <ref target="http://creativecommons.org/licenses/by/4.0/">Creative Commons Priznanje avtorstva 4.0 mednarodna licenca</ref>.</p>
          <p xml:lang="en">This work is licensed under the <ref target="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</ref>.</p>
        </availability>
        <date when="{$today}">
	  <xsl:value-of select="$today"/>
	</date>
      </publicationStmt>
      <sourceDesc>
        <bibl>
          <title type="main" xml:lang="sl">Zapisi sej Državnega zbora Republike Slovenije</title>
          <title type="main" xml:lang="en">Minutes of the National Assembly of the Republic of Slovenia</title>
          <idno type="URI" subtype="parliament">https://www.dz-rs.si</idno>
          <date from="{$min-date}" to="{$max-date}">
	    <xsl:value-of select="format-date($min-date, '[D1].[M1].[Y0001]')"/>
	    <xsl:text> — </xsl:text>
	    <xsl:value-of select="format-date($max-date, '[D1].[M1].[Y0001]')"/>
	  </date>
        </bibl>
      </sourceDesc>
    </fileDesc>
  </xsl:template>
  
  <xsl:template name="encodingDesc">
   <encodingDesc xmlns="http://www.tei-c.org/ns/1.0">
   </encodingDesc>
  </xsl:template>
  
  <xsl:template name="profileDesc">
    <profileDesc xmlns="http://www.tei-c.org/ns/1.0">
    </profileDesc>
  </xsl:template>
  
</xsl:stylesheet>
