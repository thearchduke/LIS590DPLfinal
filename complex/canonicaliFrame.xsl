<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    exclude-result-prefixes="dc"
    xmlns="http://www.w3.org/1999/xhtml" 
    version="2.0">
    <xsl:output method="xml"
        doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
        doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
            ></xsl:output>
    
    <!-- TRANSFORMING CONGRESS: FINAL PROJECT
        ===========================================
        
        
        Current version: 1.0
        Author: J. Tynan Burke
        XSL stylesheet to transform & make more useful bills from xml.house.gov
        Some rights reserved, under the CC Attribution-ShareAlike 3.0 Unported License.
            (Basically, drop me a note & credit if for whatever reason you use this)
            
        TO-DO:
            ::Has it been signed by the president?
                ::Need to make an XML file for that; time-consuming, not in the project's scope at the moment.
            ::For Cocoon application, implementation, let's have it do this to save us some time:
                ::Talk to Wendell about DTD caching
                ::Can we write some regex's or something that turn USC references w/o a @parsable-cite into links?
                    My guess is 'no' since I'm not exactly a whiz on those.

            
        QUESTIONS:
            ::<enum> is not transforming properly inside of blockquotes. What gives?
						::What's up with the discrepancy between $whichVote's listed voting question and the other Thomas page? 
							::SOLVED; see ludicrous fix
    -->


<!-- This was my slightly more ludicrous older code:

    <xsl:variable name="whichVote" select="document('votes.xml')/votes/vote[@bill=$billNum and contains(@title, 'On Passage:')]/@roll"></xsl:variable>
    <xsl:variable name="whichVote2" select="document('votes.xml')/votes/vote[@bill=$billNum and contains(@title, 'On Motion to Suspend the Rules and Pass')]/@roll"></xsl:variable>
    <xsl:variable name="whichVote3" select="document('votes.xml')/votes/vote[@bill=$billNum and contains(@title, 'On Motion to Suspend the Rules and Agree')]/@roll"></xsl:variable>
    <xsl:variable name="VoteNumber1" select="format-number($whichVote, '000')"></xsl:variable>
    <xsl:variable name="VoteNumber2" select="format-number($whichVote2, '000')"></xsl:variable>
    <xsl:variable name="VoteNumber3" select="format-number($whichVote3, '000')"></xsl:variable>
    <xsl:variable name="RealVoteNumber">
        <xsl:if test="not($VoteNumber1='NaN')">
            <xsl:value-of select="$VoteNumber1"></xsl:value-of>
        </xsl:if>
        <xsl:if test="not($VoteNumber2='NaN')">
            <xsl:value-of select="$VoteNumber2"></xsl:value-of>
        </xsl:if>
        <xsl:if test="not($VoteNumber3='NaN')">
            <xsl:value-of select="$VoteNumber3"></xsl:value-of>
        </xsl:if>        
    </xsl:variable>

-->


    <xsl:variable name="billNum" select="concat('h111-',substring-after(//form/legis-num/text(),'H. R. '))"></xsl:variable>



    <xsl:variable name="RealVoteNumber">
        <xsl:if test="not(contains(format-number(document('votes.xml')/votes/vote[@bill=$billNum and contains(@title, 'On Passage:')]/@roll, '000'), 'NaN'))">
            <xsl:value-of select="format-number(document('votes.xml')/votes/vote[@bill=$billNum and contains(@title, 'On Passage:')]/@roll, '000')"></xsl:value-of>
        </xsl:if>
        <xsl:if test="not(contains(format-number(document('votes.xml')/votes/vote[@bill=$billNum and contains(@title, 'On Motion to Suspend the Rules and Pass:')]/@roll, '000'), 'NaN'))">
            <xsl:value-of select="format-number(document('votes.xml')/votes/vote[@bill=$billNum and contains(@title, 'On Motion to Suspend the Rules and Pass:')]/@roll, '000')"></xsl:value-of>
        </xsl:if>
        <xsl:if test="not(contains(format-number(document('votes.xml')/votes/vote[@bill=$billNum and contains(@title, 'On Motion to Suspend the Rules and Agree:')]/@roll, '000'), 'NaN'))">
            <xsl:value-of select="format-number(document('votes.xml')/votes/vote[@bill=$billNum and contains(@title, 'On Motion to Suspend the Rules and Agree:')]/@roll, '000')"></xsl:value-of>
        </xsl:if>
        <xsl:if test="not(contains(format-number(document('votes.xml')/votes/vote[@bill=$billNum and contains(@title, 'On Motion to Suspend the Rules and Pass, as Amended:')]/@roll, '000'), 'NaN'))">
            <xsl:value-of select="format-number(document('votes.xml')/votes/vote[@bill=$billNum and contains(@title, 'On Motion to Suspend the Rules and Pass, as Amended:')]/@roll, '000')"></xsl:value-of>
        </xsl:if>
        <xsl:if test="not(contains(format-number(document('votes.xml')/votes/vote[@bill=$billNum and contains(@title, 'On Motion to Suspend the Rules and agree, as amended:')]/@roll, '000'), 'NaN'))">
            <xsl:value-of select="format-number(document('votes.xml')/votes/vote[@bill=$billNum and contains(@title, 'On Motion to Suspend the Rules and agree, as amended:')]/@roll, '000')"></xsl:value-of>
        </xsl:if>        
    </xsl:variable>

    <xsl:variable name="rollCallURL" select="string(concat('http://clerk.house.gov/evs/2009/roll', $RealVoteNumber, '.xml'))"></xsl:variable>
    <xsl:variable name="rollCallMeta" select="document($rollCallURL)/rollcall-vote/vote-metadata"></xsl:variable>
    


    <xsl:template match="bill">

        <html>
            <head>
                <link href="http://www.tynanburke.com/housexmlComplex.css" rel="stylesheet" type="text/css"/>

                <!-- I'm noticing that not everything is Dublin Core-ified, so let's try a when here
                NOTE: To be extended as we discover more title formats!
                -->
                <xsl:choose>
                    <xsl:when test="//dc:title">
                        <title>
                            Transforming Congress: <xsl:value-of select="//dc:title"/>
                        </title>
                    </xsl:when>
                    <xsl:otherwise>
                        <title>Transforming Congress: <xsl:value-of select="(//short-title)[1]"></xsl:value-of></title>
                    </xsl:otherwise>
                </xsl:choose>

                <xsl:for-each select="//dc:*">
                    <xsl:if test="text()">
                        <xsl:variable name="whichDC" select="local-name()"></xsl:variable>
                        <xsl:variable name="dcValue" select="text()"></xsl:variable>
                        <meta name="DC.{$whichDC}" content="{$dcValue}"></meta>&#xa0;
                    </xsl:if>
                </xsl:for-each>

                
                <!-- Routine click to show/click to hide javascript -->
                <script type="text/javascript">
                    function toggleVis(id){
                    var current = document.getElementById(id);
                    if(current.style.display == 'block')
                        current.style.display = 'none';
                    else
                        current.style.display = 'block';
                    }                 
                </script>
            </head>


            <body>
                <div class="container">                 <!-- Remember these parentheses! -->
                <div class="billTitle"><xsl:value-of select="(//short-title)[1]"></xsl:value-of>
                    <br/><xsl:value-of select="/bill/form/legis-num"/>: <xsl:value-of select="/bill/form/legis-type"/><br /><xsl:value-of select="/bill/form/official-title"/></div>
                    <xsl:apply-templates/>
                </div>
                <div class="sidebar">

					<xsl:if test="not($RealVoteNumber='')">
										<p class="sidePara"><i>Please note that there can be many forms of a bill; the information below 
										applies only to the version that was voted on for passage.</i></p>
                                        <p class="sidePara">THE VOTING QUESTION:


                        <xsl:value-of select="$rollCallMeta/vote-question"></xsl:value-of>
                        </p>

                    <p class="sidePara">THE KIND OF VOTE:
                        
                        <xsl:value-of select="$rollCallMeta/vote-type"></xsl:value-of></p>
                        
                        
                    <p class="sidePara">THE RESULT:
                        <xsl:value-of select="$rollCallMeta/vote-result"></xsl:value-of></p>
                    
                    <p class="sidePara">HOW:                        
                    <br/>
                        <xsl:for-each select="$rollCallMeta/vote-totals/totals-by-party">
                            <xsl:value-of select="party"></xsl:value-of> Members:
                            <br/><xsl:value-of select="yea-total"></xsl:value-of> yes, 
                            <br/><xsl:value-of select="nay-total"></xsl:value-of> no, 
                            <br/><xsl:value-of select="present-total"></xsl:value-of> 'present' (actively voted neither yes nor no),
                            <br/><xsl:value-of select="not-voting-total"></xsl:value-of> not voting.
                                <br/><br/>
                        </xsl:for-each>
                    </p>
                    <p class="sidePara">SPONSOR(S):<br/>
                    <xsl:for-each select="/bill/form/action/action-desc/sponsor">
                        <xsl:apply-templates></xsl:apply-templates>&#xa0;&#xa0;
                        <xsl:variable name="congId" select="@name-id"></xsl:variable>
                        <a href="http://bioguide.congress.gov/scripts/biodisplay.pl?index={$congId}">(bio)</a>
                    <br/>
                    </xsl:for-each>
                    </p>
                    <p class="sidePara">COSPONSOR(S):<br/>
                    <xsl:for-each select="/bill/form/action/action-desc/cosponsor">
                        <xsl:variable name="congId" select="@name-id"></xsl:variable>
                        <xsl:variable select="document('congBios.xml')/congress/members/rep[id[text()=$congId]]" name="rep"></xsl:variable>
                        <xsl:apply-templates></xsl:apply-templates>,&#xa0;<xsl:value-of select="$rep/party"></xsl:value-of>-<xsl:value-of select="$rep/state"></xsl:value-of>&#xa0;
                        <a href="http://bioguide.congress.gov/scripts/biodisplay.pl?index={$congId}">(bio)</a>
                        <br/>
                    </xsl:for-each>
                    </p>
                    <p class="sidePara">DISTRICT MAP:<br/>
                    
                    </p>
                        <img src="http://cocoon.lis.illinois.edu:8080/lis590dpl/jtburke4/congress/bill/{$RealVoteNumber}/visualize" 
                                width="525px" height="325px" style="border: 2px solid black;"></img>
                        
                    <br/><i>Key: red and blue are Republican and Democratic representatives; the lighter shades indicate 
                    'yes' votes and the darker 'no' votes. Green represents one of the forms of not voting. Purple 
                    tells me there is an error with this vote in that district.</i>
                </xsl:if>
								<xsl:if test="$RealVoteNumber = ''">
									<p class="sidePara">There appears to be no vote information associated with this bill.</p>
									<p class="sidePara">BILL STATUS: <xsl:value-of select="/bill/@bill-stage"/></p>
								</xsl:if>							
                </div>
            </body>
        </html>
    </xsl:template>
    
    <!-- Make a hideable TOC, but only the main 'head' TOC -->
    <xsl:template match="toc[@container-level='legis-body-container']">
        <br/><a class="toggle" onclick="toggleVis('toc')" href="#">Show/Hide Table of Contents</a>
        <br/><div class="toc" id="toc" style="display:block;"><span style="font-size: 18px; font-weight: bold;">Table of Contents:</span><br />
            <xsl:apply-templates></xsl:apply-templates>
        </div>
    </xsl:template>


    <!-- Thanks, http://dh.obdurodon.org/avt.html 
         Makes appropriately-indented TOC entries. Question: What if the @container-level and 
         @level conventions aren't followed?

				Too bad, for now, I suppose.
    -->
    <xsl:template match="toc-entry[ancestor::node()[@container-level='legis-body-container']]">
        <br />
            <xsl:choose>
                <xsl:when test="@level='title'">
                    <a href="#{@idref}">                     
                    <xsl:apply-templates></xsl:apply-templates>
                    </a>
                </xsl:when>
                <xsl:when test="@level='section'">&#xa0;&#xa0;&#xa0;&#xa0;&#xa0;
                    <a href="#{@idref}">                        
                    <xsl:apply-templates></xsl:apply-templates>
                    </a>
                </xsl:when>
             </xsl:choose>
            <!-- Thanks, semantically-marked sections! -->

    </xsl:template>

    <xsl:template match="quoted-block">
        <div class="blockquote">
            <xsl:apply-templates></xsl:apply-templates>
        </div>
        <xsl:apply-templates select="after-quoted-block" mode="after"></xsl:apply-templates>
    </xsl:template>
    
<!-- WTF CONGRESS what is this 'after-quoted-block' being inside 'quoted-block' nonsense -->
        
    <xsl:template match="after-quoted-block">
    </xsl:template>

    <xsl:template match="after-quoted-block" mode="after">
        <xsl:if test="not(.='.')">
            <div class="afterBlockquote">
                <xsl:apply-templates></xsl:apply-templates>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template match="paragraph">
        <div class="bodyPara"><a name="{@id}"></a>
            <xsl:apply-templates></xsl:apply-templates>
        </div>
    </xsl:template>

    <xsl:template match="enum">
        <xsl:apply-templates></xsl:apply-templates>&#xa0;
    </xsl:template>

    <xsl:template match="section">
        <div class="section"><a name="{@id}"></a>
            <xsl:apply-templates></xsl:apply-templates>
        </div>
    </xsl:template>

    <xsl:template match="subsection">
        <div class="subsection"><a name="{@id}"></a><br/>
            <xsl:apply-templates></xsl:apply-templates>
        </div>
    </xsl:template>

    <xsl:template match="header">
        <span class="header">
            <xsl:apply-templates></xsl:apply-templates><br/>&#xa0;&#xa0;&#xa0;
        </span>
    </xsl:template>
    

    <!-- Don't print metadata except as specified above -->

    <xsl:template match="form"></xsl:template>
    <xsl:template match="dublinCore"></xsl:template>




    <xsl:template match="external-xref">
        <xsl:variable name="uscUrl" select="substring-after(@parsable-cite, 'usc/')"></xsl:variable>
        <a href="http://www.law.cornell.edu/uscode/text/{$uscUrl}">
            <xsl:apply-templates></xsl:apply-templates>
        </a>
    </xsl:template>



</xsl:stylesheet>
