<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">
    
    <xsl:output method="xml"></xsl:output>
    
    <!-- identity template -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

<!-- Easily extensible parameters for handling yes/no/not voting as new ones are found -->
    <xsl:param name="yesWords">
        <w>Aye</w>
        <w>Yea</w>
    </xsl:param>
    
    <xsl:param name="noWords">
        <w>No</w>
        <w>Nay</w>
    </xsl:param>
    
    <xsl:param name="nvWords">
        <w>Present</w>
        <w>Not Voting</w>
    </xsl:param>
    
    
    <!-- 1: Identify the roll call vote -->
    
        <!-- this param is passed via URL -->
    <xsl:param name="whichVote" select="'477'"></xsl:param>

    <!-- 2: Obtain the information on said vote by number (URL looks like clerk.house.gov/evs/2009/roll971.xml) -->    
    <xsl:variable name="rollCallURL" select="string(concat('http://clerk.house.gov/evs/2009/roll', $whichVote, '.xml'))"></xsl:variable>
    <xsl:variable name="rollCallVote" select="document($rollCallURL)/rollcall-vote/vote-data"></xsl:variable>
    
    <!-- 3: Load the variable that we'll use to map id to district -->    
    <xsl:variable name="congBios" select="document('congBios.xml')/congress/members"></xsl:variable>
    
    
    <!-- 3.5: Make template modes for coloration. -->
    <xsl:template match="@style" mode="DY">
        <xsl:attribute name="style">fill: #44f; stroke:white; stroke-width: 2px; stroke-opacity: 1.0; stroke-opacity: 1.0;
            <xsl:apply-templates></xsl:apply-templates>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@style" mode="DN">
        <xsl:attribute name="style">fill: #003; stroke:white; stroke-width: 2px; stroke-opacity: 1.0; stroke-opacity: 1.0;
            <xsl:apply-templates></xsl:apply-templates>
        </xsl:attribute>         
    </xsl:template>

    <xsl:template match="@style" mode="RN">
        <xsl:attribute name="style">fill: #300; stroke:white; stroke-width: 2px; stroke-opacity: 1.0; stroke-opacity: 1.0;
            <xsl:apply-templates></xsl:apply-templates>
        </xsl:attribute>         
    </xsl:template>

    <xsl:template match="@style" mode="RY">
        <xsl:attribute name="style">fill: #f44; stroke:white; stroke-width: 2px; stroke-opacity: 1.0; stroke-opacity: 1.0;
            <xsl:apply-templates></xsl:apply-templates>
        </xsl:attribute>         
    </xsl:template>    
    
    <xsl:template match="@style" mode="NV">
        <xsl:attribute name="style">fill: #383; stroke:white; stroke-width: 2px; stroke-opacity: 1.0; stroke-opacity: 1.0;
            <xsl:apply-templates></xsl:apply-templates>
        </xsl:attribute>         
    </xsl:template>
    
    
    <!-- 4: And finally, the transformation -->
    <xsl:template match="@style">
        <xsl:variable name="district" select="parent::node()/@id"></xsl:variable>
        <!-- If this is actually the right select I'll eat my hat: -->
        <xsl:variable name="congId" select="$congBios/rep/id[parent::node()/encodedDistrict=$district]"></xsl:variable>
        <!-- I'll be damned. Time to locate a hat-->
        
        
        
        <!-- HI-1 had two representatives during this period, so...
        NOTE: If needed for another district (for example in upstate NY?), we can abstract this out into parameters 
        like we did with yes/no words -->
        <xsl:choose>
            
            <xsl:when test="$district = 'HI_1'">
                <xsl:if test="$rollCallVote/recorded-vote/legislator[@name-id='A000014']/parent::node()/vote= $noWords/*">
                   <xsl:apply-templates select="." mode="DN"></xsl:apply-templates>
                </xsl:if> 

                <xsl:if test="$rollCallVote/recorded-vote/legislator[@name-id='D000611']/parent::node()/vote= $noWords/*">
                    <xsl:apply-templates select="." mode="RN"></xsl:apply-templates>
                </xsl:if> 

                <xsl:if test="$rollCallVote/recorded-vote/legislator[@name-id='A000014']/parent::node()/vote= $yesWords/*">
                    <xsl:apply-templates select="." mode="DY"></xsl:apply-templates>
                </xsl:if> 
                
                <xsl:if test="$rollCallVote/recorded-vote/legislator[@name-id='D000611']/parent::node()/vote= $yesWords/*">
                    <xsl:apply-templates select="." mode="RY"></xsl:apply-templates>
                </xsl:if> 

                <xsl:if test="$rollCallVote/recorded-vote/legislator[@name-id='A000014']/parent::node()/vote= $nvWords/*">
                    <xsl:apply-templates select="." mode="NV"></xsl:apply-templates>
                </xsl:if> 
                
                <xsl:if test="$rollCallVote/recorded-vote/legislator[@name-id='D000611']/parent::node()/vote= $nvWords/*">
                    <xsl:apply-templates select="." mode="NV"></xsl:apply-templates>
                </xsl:if> 
            </xsl:when>


        <!-- Is there a way to make it evaluate these when's and then stop after it's done it once? It'd speed things up.
        Not that it's tremendously slow as-is. -->

            <xsl:when test="
                $rollCallVote/recorded-vote/legislator[@name-id=$congId and @party='D']/parent::node()/vote= $noWords/*">
                <xsl:apply-templates select="." mode="DN"></xsl:apply-templates>
            </xsl:when>
            
            <xsl:when test="
                $rollCallVote/recorded-vote/legislator[@name-id=$congId and @party='D']/parent::node()/vote= $yesWords/*">
                <xsl:apply-templates select="." mode="DY"></xsl:apply-templates>
            </xsl:when>

            <xsl:when test="
                $rollCallVote/recorded-vote/legislator[@name-id=$congId and @party='R']/parent::node()/vote= $noWords/*">
                <xsl:apply-templates select="." mode="RN"></xsl:apply-templates>
            </xsl:when>
            
            <xsl:when test="
                $rollCallVote/recorded-vote/legislator[@name-id=$congId and @party='R']/parent::node()/vote= $yesWords/*">
                <xsl:apply-templates select="." mode="RY"></xsl:apply-templates>
            </xsl:when>
            
            <xsl:when test="
                $rollCallVote/recorded-vote/legislator[@name-id=$congId]/parent::node()/vote= $nvWords/*">
                    <xsl:apply-templates select='.' mode="NV"></xsl:apply-templates>
            </xsl:when>
            
            
            <xsl:when test="parent::node()/@id='State_Border'">
                <xsl:attribute name="style">fill: none; stroke: gray; stroke-width: 10px;
                    <xsl:apply-templates></xsl:apply-templates>
                </xsl:attribute>          
            </xsl:when>
            
            <xsl:when test="parent::node()/@id='State_Borders'">
                <xsl:attribute name="style">fill: none; stroke: black; stroke-width: 5px;
                    <xsl:apply-templates></xsl:apply-templates>
                </xsl:attribute>          
            </xsl:when>
            

        <!-- Error message -->
            <xsl:otherwise>
                <xsl:attribute name="style">fill: #a0a;
                    <xsl:apply-templates></xsl:apply-templates>
                </xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>        
    </xsl:template>

</xsl:stylesheet>
