﻿<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:dotml="http://www.martin-loetzsch.de/DOTML" >
	
 <xsl:output
     method="html"
     doctype-system="about:legacy-compat"
     encoding="UTF-8"
     indent="yes" />

	<xsl:include href='render-summary.xslt' />
	<xsl:include href='render-form.xslt' />

	 <!--
	<xsl:include href='render-form.xslt' />

	<xsl:include href='render-tables.xslt' /> 
	<xsl:include href='render-tables.xslt'/>
	<xsl:include href='render-columns.xslt'/>
-->	
	<xsl:variable name='crlf'>
</xsl:variable>

	<xsl:variable name='db-name' select='/Database/@name' />
	
	<xsl:variable name='main-forms' select='/Database/Forms/Form[not(@subform)]'/>
	<xsl:variable name='sub-forms' select='/Database/Forms/Form[@subform]'/>

	<xsl:template match="/">
<html lang="en">
  <head>
    <meta charset="utf-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title><xsl:value-of select='$db-name'/></title>

    <!-- Bootstrap -->
    <link href="lib/bootstrap/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="css/database.css" rel="stylesheet"/>

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
      <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>
  <body data-spy='scroll' data-target='.scrollspy'>
    
    <nav class="navbar navbar-inverse navbar-static-top">
      <div class="container">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="#"><xsl:value-of select='$db-name'/></a>
        </div>
        <div class="collapse navbar-collapse">
          <ul class="nav navbar-nav">
            <li class="active"><a href="#top">Home</a></li>
			<li role="presentation" class="dropdown">
				<a class="dropdown-toggle" data-toggle="dropdown" href="#" role="button" aria-haspopup="true" aria-expanded="false">
					<xsl:text>Form </xsl:text>
					<xsl:call-template name='count-badge'><xsl:with-param name='items' select='$main-forms'/></xsl:call-template>
					<xsl:text> </xsl:text><span class="caret"></span>
				</a>
				<ul class="dropdown-menu">
					<xsl:for-each select='$main-forms'>
						<xsl:sort select='@name'/>
						<li><a href='#{@id}'><xsl:value-of select='@name'/></a></li>
					</xsl:for-each>
				</ul>
			  </li>
            <li><a href="#reports">Relationships</a></li>
          </ul>
        </div><!--/.nav-collapse -->
      </div>
    </nav>

  <a id='top' name='top'/>
  
  <div class="container">
    <div class='' role='main' >
      <a name='summary'/>
      <h3>Summary</h3>
      <xsl:apply-templates select='/Database/Forms' mode='summary'/>

      <a name='forms'/>
      <h3>Forms</h3>
      <xsl:apply-templates select='$main-forms' mode='form'>
        <xsl:sort select='@name'/>
      </xsl:apply-templates>
    </div>

  </div>
		<!--
		<div class='list-group' data-spy='affix' data-offset-top="60" data-offset-bottom="200" style='overflow: auto'>
			<a href="#summary" class="list-group-item">Summary</a>
			<a href='#tables' class="list-group-item list-group-item-info">Tables</a>
			<xsl:for-each select='/Database/Tables/Table[Column/*]'>
				<xsl:sort select='@name' />
				<a href='#{@tableId}' class="list-group-item"><xsl:value-of select='@name'/></a>
			</xsl:for-each>
		</div>
		-->
    <br/>
    <hr/>
    <br/>

	<nav class="navbar navbar-default navbar-fixed-bottom">
      <div class="container">
        <div class="navbar-header">
          <a class="navbar-brand" href="#"><xsl:value-of select='$db-name'/></a>
        </div>
        <div class="collapse navbar-collapse">
          <ul class="nav navbar-nav">
            <li>
				<a href="#forms">
					<xsl:text>Forms </xsl:text>
					<xsl:call-template name='count-badge'>
						<xsl:with-param name='items' select='$main-forms'/>
					</xsl:call-template>
				</a>
			</li>
            <li><a href="#reports"><xsl:text>Reports </xsl:text><xsl:apply-templates select='/Database/Reports' mode='count-badge'/></a></li>
          </ul>
        </div>
      </div>
	</nav>
	
    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="lib/jquery/jquery.min.js"/>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="lib/bootstrap/js/bootstrap.min.js"/>
  </body>
</html>
  </xsl:template> 
  
  <xsl:template match='*' mode='count-badge'>
	<xsl:call-template name='count-badge'>
		<xsl:with-param name='items' select='*'/>
	</xsl:call-template>
  </xsl:template>
  
  <xsl:template name='count-badge'>
	<xsl:param name='items' select='*'/>
	<xsl:choose>
		<xsl:when test='count($items) = 0'/>
		<xsl:otherwise>
			<xsl:call-template name='badge'>	
				<xsl:with-param name='number' select='count($items)'/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
  </xsl:template>
  
  <xsl:template name='badge'>
	<xsl:param name='number'>0</xsl:param>
	<xsl:text> </xsl:text>
	<span class='badge'><xsl:value-of select='$number'/></span>
  </xsl:template>

</xsl:stylesheet>