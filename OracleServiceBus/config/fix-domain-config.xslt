<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: fix-domain-config.xslt,v 1.1 2012/05/17 17:31:10 cvsuser Exp $ -->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:wl="http://xmlns.oracle.com/weblogic/domain">

	<xsl:output method="xml" indent="yes" />

	<!-- Untarget the wlsbjmsrpDataSource data source -->
	<xsl:template match="/wl:domain/wl:jdbc-system-resource/wl:target">
		<xsl:choose>
			<xsl:when
				test="contains(../wl:descriptor-file-name, 'wlsbjmsrpDataSource-jdbc.xml')">
				<xsl:copy />
			</xsl:when>

			<xsl:otherwise>
				<xsl:copy-of select="." />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Untarget the JMS Reporting Provider app -->
	<xsl:template match="/wl:domain/wl:app-deployment/wl:target">
		<xsl:choose>
			<xsl:when test="contains(../wl:source-path, 'jmsreportprovider.ear')">
				<xsl:copy />
			</xsl:when>

			<xsl:otherwise>
				<xsl:copy-of select="." />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="@* | node()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
