<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:dotml="http://www.martin-loetzsch.de/DOTML" >
	
	<xsl:output method="xml" indent="yes" />
	
	<!-- default is not to cluster -->
	<!-- to cluster specify any value that is not empty -->
	<xsl:param name='cluster'></xsl:param>
	
	<!-- default is show messages on labels-->
	<!-- options are node, label, none, '' -->
	<xsl:param name='message-format'>label</xsl:param>
	
	<xsl:param name='mode'/>
	
	<xsl:param name='title'>Graph</xsl:param>
	
	<xsl:param name='direction'>LR</xsl:param>

	<xsl:include href='include-graphs-colours.xslt'/>
	
	<xsl:key name='forms-by-id' match='Form[@id]' use='@id'/>
	<xsl:key name='subforms-by-source' match='SubForm' use='@sourceObject'/>
	<xsl:key name='references-by-id' match='Reference' use='@id'/>
	<xsl:key name='forms-by-name' match='Form[@name]' use='@name'/>
	<xsl:key name='reports-by-name' match='Report[@name]' use='@name'/>
		
	<xsl:template match="/" >
		<xsl:apply-templates select="/Database"/>
	</xsl:template>
	
	<xsl:template match="/Database">
		<dotml:graph file-name="data-flow" label="{$title}" rankdir="{$direction}" fontname="{$fontname}" fontsize="{$font-size-h1}" labelloc='t' >			
			<dotml:cluster id='nodes'>
				<xsl:apply-templates select='Forms/Form' mode='node'/> 
<!--				<xsl:apply-templates select='Report' mode='node'/> -->
			</dotml:cluster>
			<xsl:apply-templates select='Forms/Form' mode='link'/>
<!--			<xsl:apply-templates select='Report' mode='link'/>  -->
		</dotml:graph>
	</xsl:template>
	
	<xsl:template match="Form" mode="node">
		<xsl:variable name='linksTo' select='count(References/Reference)'/>
		<xsl:variable name='linksFrom' select="count(key('references-by-id', @id))"/>
		<xsl:variable name='subForm' select="key('subforms-by-source',@name)" />
		
		<xsl:choose>
			<xsl:when test='count($subForm) > 0'>
				<dotml:node id="{@id}" style="dotted" shape="box" label='{@name}' fillcolor='{$focus-bgcolor}' color="{$form-color}" 
					fontname="{$fontname}" fontsize="{$font-size-h2}" fontcolor="{$form-color}" />
			</xsl:when>
			<xsl:when test='($linksTo + $linksFrom) > 0'>
				<dotml:node id="{@id}" style="solid" shape="box" label='{@name}' fillcolor='{$focus-bgcolor}' color="{$form-color}" 
					fontname="{$fontname}" fontsize="{$font-size-h2}" fontcolor="{$form-color}" />
			</xsl:when>
			<xsl:otherwise>
				<dotml:node id="{@id}" style="solid" shape="box" label='{@name}' color="grey" 
					fontname="{$fontname}" fontsize="{$font-size-h3}" fontcolor="grey" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="Form" mode="link">
		<xsl:variable name='to' select='@id'/>
		<xsl:for-each select='References/Reference'>
			<xsl:variable name='from' select='@id'/>
			<dotml:edge from="{$from}" to="{$to}" color='{$link-color}'  />
		</xsl:for-each>
		<xsl:for-each select='Controls/SubForm'>
			<xsl:variable name='sub' select='key("forms-by-name", @sourceObject)/@id'/>
			<dotml:edge from="{$to}" to="{$sub}" color='{$link-color}'  />
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="Report" mode="node">
		<xsl:variable name='linksTo' select='count(References/Reference)'/>
		<xsl:variable name='linksFrom' select="count(key('references-by-id', @id))"/>
		<xsl:if test='($linksTo + $linksFrom) > 0'>
			<dotml:node id="{@id}" style="solid" shape="box" label='{@name}' fillcolor='{$focus-bgcolor}' color="{$report-color}" 
				fontname="{$fontname}" fontsize="{$font-size-h3}" fontcolor="{$report-color}" />
		</xsl:if>			
	</xsl:template>
	
	<xsl:template match="Report" mode="link">
		<xsl:variable name='to' select='@id'/>
		<xsl:for-each select='References/Reference'>
			<xsl:variable name='from' select='@id'/>
			<dotml:edge from="{$from}" to="{$to}" color='{$link-color}'  />
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="concat-names">
		<xsl:param name="nodes" select='*'/>
		<xsl:for-each select='$nodes[@name]'>
			<xsl:if test='position() > 1'>\n</xsl:if>
			<xsl:value-of select='@name'/>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>
