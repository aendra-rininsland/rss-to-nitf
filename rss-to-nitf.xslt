<?xml version="1.0" encoding="UTF-8"?>


<!--
  RSS to NITF XSLT
  2015 Ændrew Rininsland <aendrew.rininsland@thetimes.co.uk>

  This will (kind of) convert RSS to NITF. Because you like pain and doing things the difficult way, clearly.
-->




<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:content="http://purl.org/rss/1.0/modules/content/"
                xmlns:date="https://github.com/ilyakharlamov/pure-xsl/date">

<!-- Import Date functions; via: https://github.com/ilyakharlamov/pure-xsl -->
<xsl:import href="date.xsl"/>

<!-- These variables are used throughout to populate things not supplied by RSS -->
<xsl:variable name="uid" select="'00000000'" />
<xsl:variable name="title-name" select="'Red Box'" />
<xsl:variable name="title-abbreviation" select="'rb'" />
<xsl:variable name="parent-company" select="'NewsUK'" />
<xsl:variable name="copyright-year" select="'2015'" />
<xsl:variable name="medium" select="'web'" />

<!-- tobject values. Please reference: http://cv.iptc.org/newscodes/subjectcode -->
<xsl:variable name="tobject-type" select="'News'" />
<xsl:variable name="tobject-property-type" select="'analysis'" /> <!-- ??? -->
<xsl:variable name="tobject-subject-type" select="'Politics'" />
<xsl:variable name="tobject-subject-refnum" select="'11000000'" />

<!-- Ensure pre is sent as CDATA -->
<xsl:output method="xml" cdata-section-elements="pre"/>

  <!-- Insert 1000 word rant about the stupidity that is RFC2822 here. -->
  <xsl:template name="format-from-rfc-to-iso">
    <xsl:param name="rfc-date"/>
    <xsl:param name="return-unixtime" select="'false'" />

    <xsl:param name="day-with-zero" select="format-number(substring(substring($rfc-date,6,11),1,2),'00')"/>
    <xsl:param name="month-with-zero">
      <xsl:if test="contains($rfc-date,'Jan')">01</xsl:if>
      <xsl:if test="contains($rfc-date,'Feb')">02</xsl:if>
      <xsl:if test="contains($rfc-date,'Mar')">03</xsl:if>
      <xsl:if test="contains($rfc-date,'Apr')">04</xsl:if>
      <xsl:if test="contains($rfc-date,'May')">05</xsl:if>
      <xsl:if test="contains($rfc-date,'Jun')">06</xsl:if>
      <xsl:if test="contains($rfc-date,'Jul')">07</xsl:if>
      <xsl:if test="contains($rfc-date,'Aug')">08</xsl:if>
      <xsl:if test="contains($rfc-date,'Sep')">09</xsl:if>
      <xsl:if test="contains($rfc-date,'Oct')">10</xsl:if>
      <xsl:if test="contains($rfc-date,'Nov')">11</xsl:if>
      <xsl:if test="contains($rfc-date,'Dec')">12</xsl:if>
    </xsl:param>
    <xsl:param name="year-full" select="format-number(substring(substring($rfc-date,6,11),7,5),'0000')"/>
    <xsl:param name="hour-with-zero" select="format-number(substring(substring($rfc-date,6),13,2), '00')"/>
    <xsl:param name="minute-with-zero" select="format-number(substring(substring($rfc-date,6),16,2),'00')"/>
    <xsl:param name="second-with-zero" select="format-number(substring(substring($rfc-date,6),19,2),'00')"/>
    <xsl:param name="timezone-identity" select="substring(substring($rfc-date,6),22,1)"/>
    <xsl:param name="timezone-offset" select="format-number(substring(substring($rfc-date,6),23,4), '0000')"/>

    <xsl:param name="rfc-date-to-iso">
      <xsl:if test="$return-unixtime = 'true'">
        <xsl:call-template name="date:timestamp">
          <xsl:with-param name="date-time" select="concat($year-full,'-',$month-with-zero,'-',$day-with-zero,'T',$hour-with-zero,':',$minute-with-zero,':',$second-with-zero,$timezone-identity,$timezone-offset)"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="not($return-unixtime = 'true')">
        <xsl:value-of select="concat($year-full,'-',$month-with-zero,'-',$day-with-zero,'T',$hour-with-zero,':',$minute-with-zero,':',$second-with-zero,$timezone-identity,$timezone-offset)" />
      </xsl:if>
    </xsl:param>

    <xsl:value-of select="$rfc-date-to-iso"/>
  </xsl:template>
  <!-- Insert another 1000 word rant here, this time about how awful XSL date handling functions are -->

  <xsl:template match="/rss/channel">
    <nitfs>
      <xsl:variable name="language" select="language" />
      <xsl:for-each select="item">
        <nitf>
          <xsl:attribute name="id">
            <xsl:value-of select="concat($title-abbreviation, ':', $uid)"/>
          </xsl:attribute>
          <xsl:attribute name="class">
            <xsl:value-of select="$title-abbreviation"/>
          </xsl:attribute>
          <xsl:attribute name="baselang">
            <xsl:value-of select="$language"/>
          </xsl:attribute>
          <xsl:attribute name="uno">
            <xsl:value-of select="concat($title-abbreviation, ':', $uid)"/>
          </xsl:attribute>
          <xsl:attribute name="version">-//IPTC//DTD NITF 3.4//EN</xsl:attribute>

          <head>
            <title>
              <xsl:attribute name="type">main</xsl:attribute>
              <xsl:value-of select="title"/>
            </title>

            <meta>
              <xsl:attribute name="name">publicationName</xsl:attribute>
              <xsl:attribute name="content">
                <xsl:value-of select="$title-abbreviation" />
              </xsl:attribute>
            </meta>

            <meta>
              <xsl:attribute name="name">type</xsl:attribute>
              <xsl:attribute name="content">standardArticle</xsl:attribute>
            </meta>

            <meta>
              <xsl:attribute name="name">lastModifiedDate</xsl:attribute>
              <xsl:attribute name="content">
                <xsl:call-template name="format-from-rfc-to-iso">
                  <xsl:with-param name="rfc-date" select="pubDate" />
                </xsl:call-template>
              </xsl:attribute>
            </meta>

            <meta>
              <xsl:attribute name="name">lastModifiedDateEpoch</xsl:attribute>
              <xsl:attribute name="content">
                <xsl:call-template name="format-from-rfc-to-iso">
                  <xsl:with-param name="rfc-date" select="pubDate" />
                  <xsl:with-param name="return-unixtime" select="'true'" />
                </xsl:call-template>
              </xsl:attribute>
            </meta>

            <meta>
              <xsl:attribute name="name">latestVersionDateEpoch</xsl:attribute>
              <xsl:attribute name="content">
                <xsl:call-template name="format-from-rfc-to-iso">
                  <xsl:with-param name="rfc-date" select="pubDate" />
                  <xsl:with-param name="return-unixtime" select="'true'" />
                </xsl:call-template>
              </xsl:attribute>
            </meta>

            <meta>
              <xsl:attribute name="name">latestVersionDate</xsl:attribute>
              <xsl:attribute name="content">
                <xsl:call-template name="format-from-rfc-to-iso">
                  <xsl:with-param name="rfc-date" select="pubDate" />
                </xsl:call-template>
              </xsl:attribute>
            </meta>

            <tobject> <!-- Please reference http://cv.iptc.org/newscodes/subjectcode -->
              <xsl:attribute name="tobject.type">
                <xsl:value-of select="$tobject-type" />
              </xsl:attribute>

              <tobject.property>
                <xsl:attribute name="tobject.property.type">
                  <xsl:value-of select="$tobject-property-type" />
                </xsl:attribute>
              </tobject.property>

              <tobject.subject>
                <xsl:attribute name="tobject.subject.type">
                  <xsl:value-of select="$tobject-subject-type" />
                </xsl:attribute>
                <xsl:attribute name="tobject.subject.ipr">
                  <xsl:value-of select="$title-abbreviation" />
                </xsl:attribute>
                <xsl:attribute name="tobject.subject.refnum">
                  <xsl:value-of select="$tobject-subject-refnum" />
                </xsl:attribute>
              </tobject.subject>
            </tobject>

            <docdata>
              <xsl:attribute name="management-status">usable</xsl:attribute>

              <doc-id>
                <xsl:attribute name="id-string"></xsl:attribute>
                <xsl:attribute name="regsrc">
                  <xsl:value-of select="$title-abbreviation" />
                </xsl:attribute>
              </doc-id>

              <del-list>
                <from-src>
                  <xsl:attribute name="src-name">
                    <xsl:value-of select="$parent-company" />
                  </xsl:attribute>
                  <xsl:attribute name="level-number">1</xsl:attribute>
                </from-src>
              </del-list>

              <date.issue>
                <xsl:attribute name="norm">
                  <xsl:call-template name="format-from-rfc-to-iso">
                    <xsl:with-param name="rfc-date" select="pubDate" />
                  </xsl:call-template>
                </xsl:attribute>
              </date.issue>

              <doc.copyright>
                <xsl:attribute name="year">
                  <xsl:value-of select="$copyright-year" />
                </xsl:attribute>
                <xsl:attribute name="holder">
                  <xsl:value-of select="$parent-company" />
                </xsl:attribute>
              </doc.copyright>

            </docdata>

            <pubdata>
              <xsl:attribute name="date.publication">
                <xsl:call-template name="format-from-rfc-to-iso">
                  <xsl:with-param name="rfc-date" select="pubDate" />
                </xsl:call-template>
              </xsl:attribute>
              <xsl:attribute name="ex-ref">
                <xsl:value-of select="link" />
              </xsl:attribute>
              <xsl:attribute name="name">
                <xsl:value-of select="dc:creator" />
              </xsl:attribute>
              <xsl:attribute name="position.section">
                <xsl:value-of select="category" />
              </xsl:attribute>
              <xsl:attribute name="type">
                <xsl:value-of select="$medium" />
              </xsl:attribute>
            </pubdata>
          </head>

          <body>
            <xsl:attribute name="xml:lang">
              <xsl:value-of select="$language" />
            </xsl:attribute>
            <body.head>
              <hedline>
                <hl1>
                  <xsl:value-of select="title" />
                </hl1>
                <!-- <hl2></hl2> --> <!-- Commented out until we can get subheads into RSS -->
              </hedline>
              <byline>
                <person>
                  <name.given>
                    <xsl:value-of select="dc:creator" />
                  </name.given>
                </person>
              </byline>
              <dateline>
                <story.date>
                  <xsl:call-template name="format-from-rfc-to-iso">
                    <xsl:with-param name="rfc-date" select="pubDate" />
                  </xsl:call-template>
                </story.date>
              </dateline>
            </body.head>
            <body.content>

              <!-- Commented out the <media> section due to RSS being lame -->

              <!--
              <media>
                <xsl:attribute name="id">sto:1188800</xsl:attribute>
                <xsl:attribute name="media-type">image</xsl:attribute>

                <media-metadata>
                  <xsl:attribute name="name">version</xsl:attribute>
                  <xsl:attribute name="value">k</xsl:attribute>
                </media-metadata>

                <media-reference>
                  <xsl:attribute name="alternate-text">Jes Staley spent 30 years at JP Morgan</xsl:attribute>
                  <xsl:attribute name="copyright"></xsl:attribute>
                  <xsl:attribute name="mime-type">image/jpeg</xsl:attribute>
                  <xsl:attribute name="height">386</xsl:attribute>
                  <xsl:attribute name="width">580</xsl:attribute>
                  <xsl:attribute name="name">Jes Staley spent 30 years at JP Morgan (Debra Hurford Brown/Barclays/PA)</xsl:attribute>
                  <xsl:attribute name="source">http://www.thesundaytimes.co.uk/sto/multimedia/dynamic/01188/01_B01MOV_1188800k.jpg</xsl:attribute>
                  <xsl:attribute name="source-credit"></xsl:attribute>
                </media-reference>

                <media-caption>Jes Staley spent 30 years at JP Morgan (Debra Hurford Brown/Barclays/PA)</media-caption>

                <media-producer>
                  <person>
                    <name.given/>
                    <function>photographer</function>
                  </person>
                  <person>
                    <name.given/>
                    <function>author</function>
                  </person>
                </media-producer>
              </media>
              -->

              <customHTML>
              </customHTML>
                <pre>
                  <xsl:value-of select="content:encoded" />
                </pre>
            </body.content>
          </body>
        </nitf>

      </xsl:for-each>
    </nitfs>
  </xsl:template>
</xsl:stylesheet>
