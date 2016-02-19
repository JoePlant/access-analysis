<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:dotml="http://www.martin-loetzsch.de/DOTML" >

  <xsl:key name='forms-by-name' match='Form' use='@name'/>
  <xsl:key name='subforms-by-source-object' match='SubForm' use='@sourceObject'/>

  <xsl:template match='/Database/Modules/Module' mode='module'>
    <xsl:variable name='module-id' select='generate-id(.)'/>
    <hr/>
		<a name='{$module-id}'/>
    <h4>
      <xsl:value-of select='@name'/>
      <xsl:text> </xsl:text>
      <span class="label label-default">Module</span>
    </h4>

    <div>
        <button class="btn btn-default" type="button" data-toggle="collapse" data-target="#code_{$module-id}" >Show code</button>
        <div class="collapse" id="code_{$module-id}">
          <xsl:apply-templates select='.' mode='code'/>
        </div>
    </div>
		
	</xsl:template>

  <xsl:template match='Code' mode='code-column'>
    <button type="button" class="btn btn-success btn-xs">
      <xsl:value-of select='@name'/>
      <xsl:text> </xsl:text>
      <span class="glyphicon glyphicon-comment" aria-hidden="true"/>
    </button>
  </xsl:template>

  <xsl:template match='Code' mode='control-table'>
    <xsl:comment>
      Code: <xsl:value-of select='@name'/>
    </xsl:comment>
  </xsl:template>

  <xsl:template match='Code' mode='code-button'>
    <button type="button" class="btn btn-success btn-xs">
      <xsl:value-of select='@name'/>
      <xsl:text> </xsl:text>
      <span class="glyphicon glyphicon-comment" aria-hidden="true"/>
    </button>
  </xsl:template>


  <xsl:template match='Module' mode='code'>
    <ul>
      <xsl:for-each select='*'>
        <li>
          <xsl:value-of select='@name'/>
        </li>
      </xsl:for-each>
    </ul>
    <div>
      <xsl:apply-templates mode='code'/>
    </div>
  </xsl:template>

  <xsl:template match='Module/Declarations' mode='code'>
    <pre><xsl:value-of select='.'/></pre>
  </xsl:template>

  <xsl:template match='Module/Section' mode='code'>
    <pre><xsl:value-of select='.'/></pre>
  </xsl:template>

	
	
</xsl:stylesheet>
