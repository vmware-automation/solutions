<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:param name="bpel.db.user"/>
<xsl:param name="bpel.db.password"/>
<xsl:param name="bpel.db.url"/>

<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>
    <xsl:template match="//connection-pool[@name='BPELPM_CONNECTION_POOL']/connection-factory">
      <xsl:copy>
   
        <xsl:attribute name="newuser">
                <xsl:value-of select="$bpel.db.user"/>
        </xsl:attribute>    
        <xsl:attribute name="newpassword">
                <xsl:value-of select="$bpel.db.password"/>
        </xsl:attribute>    
        <xsl:attribute name="newurl">
                <xsl:value-of select="$bpel.db.url"/>
        </xsl:attribute>        
        <xsl:apply-templates select="@*|node()" />
       </xsl:copy>         
    </xsl:template> 
    
          

</xsl:stylesheet>