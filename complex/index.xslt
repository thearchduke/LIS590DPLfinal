<?xml version="1.0" encoding="UTF-8"?>
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml"
 
        version="2.0">
        <xsl:output method="xml"
            doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
            doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
            ></xsl:output>
        
        <xsl:variable name="cocoonBase" select="'http://cocoon.lis.illinois.edu:8080/lis590dpl/jtburke4/congress/bill/'"></xsl:variable>
				<xsl:variable name="votes" select="document('votes.xml')/votes"></xsl:variable>

   <xsl:template match="//body">
        <html>
            <head>
                <link href="http://www.tynanburke.com/housexmlComplex.css" rel="stylesheet" type="text/css"/>
                <script type="text/javascript">
                    function toggleVis(id){
                    var current = document.getElementById(id);
                    if(current.style.display == 'block')
                        current.style.display = 'none';
                    else
                        current.style.display = 'block';
                    }                 
                </script>
                
                <style type="text/css">
                .left {float: left;
                width: 450px;
                }
                
                .right {float: right;
                width: 450px;
                }
                </style>
            </head>
            <body>
					<div class="left">
<h2>Bills as introduced in the House</h2>
					<xsl:for-each select="a[contains(concat($cocoonBase, substring-before(., '.xml'), '/text'), 'ih')]">
			<xsl:variable name="thisUrl" select="concat($cocoonBase, substring-before(., '.xml'), '/text')"></xsl:variable>
			<xsl:variable name="billNumPre" select="substring-before(., '_')"></xsl:variable>
			<xsl:variable name="billNum" select="concat('h111-',substring-after($billNumPre, 'h'))"></xsl:variable>
			<xsl:if test="$votes/vote[@bill=$billNum and contains(@datetime, '2009')]">
							<p>
	      <a href="{$thisUrl}">Transformation of: <xsl:value-of select="."></xsl:value-of></a>
				<br/>
				</p>
				</xsl:if>
				</xsl:for-each>
</div>

<div class="right">
<h2>Bills as passed by the House</h2>
					<xsl:for-each select="a[contains(concat($cocoonBase, substring-before(., '.xml'), '/text'), 'eh')]">
			<xsl:variable name="thisUrl" select="concat($cocoonBase, substring-before(., '.xml'), '/text')"></xsl:variable>
			<xsl:variable name="billNumPre" select="substring-before(., '_')"></xsl:variable>
			<xsl:variable name="billNum" select="concat('h111-',substring-after($billNumPre, 'h'))"></xsl:variable>
			<xsl:if test="$votes/vote[@bill=$billNum and contains(@datetime, '2009')]">
				<p>
	      <a href="{$thisUrl}">Transformation of: <xsl:value-of select="."></xsl:value-of></a>
				<br/>
				</p>
				</xsl:if>
				</xsl:for-each>
				</div>
					</body>
				</html>
    </xsl:template>
    
<!--
    <xsl:template match="a">
    	<xsl:variable name="thisUrl" select="concat($cocoonBase, substring-before(., '.xml'), '/text')"></xsl:variable>
			<xsl:if test="(contains($thisUrl, 'ih'))">
				<div class="left">
	      <a href="{$thisUrl}">Transformation of: <xsl:value-of select="."></xsl:value-of></a>
				<br/>
				</div>
			</xsl:if>


			<xsl:if test="(contains($thisUrl, 'eh'))">
				<div class="right">
	      <a href="{$thisUrl}">Transformation of: <xsl:value-of select="."></xsl:value-of></a>
	      <br/>
				</div>
			</xsl:if>
    </xsl:template>
-->
    <xsl:template match="//text()">
    </xsl:template>


</xsl:stylesheet>