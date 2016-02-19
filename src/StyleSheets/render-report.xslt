<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:dotml="http://www.martin-loetzsch.de/DOTML" >

  <xsl:key name='subreports-by-source-object' match='SubReport' use='@sourceObject'/>

  <xsl:template match='/Database/Reports/Report' mode='report'>
    <xsl:variable name='control-code' select='Sections/Section/Controls/descendant::Code'/>
    <xsl:variable name='controls' select='Sections/Section/Controls/descendant::*'/>
    <xsl:variable name='events' select='Events/Code'/>
    <xsl:variable name='report-id' select='generate-id(.)'/>
    <xsl:variable name='used-by' select="key('subreports-by-source-object', @name)/ancestor::Report"/>
    <hr/>
    <a name='{$report-id}'/>
    <h4>
      <xsl:value-of select='@name'/>
      <xsl:text> </xsl:text>
      <span class="label label-default">
        <xsl:choose>
          <xsl:when test='$used-by'>
            <xsl:value-of select='@defaultView'/> (SubReport)
          </xsl:when>
          <xsl:when test='@defaultView'>
            <xsl:value-of select='@defaultView'/>
          </xsl:when>
          <xsl:otherwise>Report</xsl:otherwise>
        </xsl:choose>
      </span>
    </h4>

    <xsl:if test='$used-by'>
      <div>
        <xsl:text>Parent form(s): </xsl:text>
        <xsl:for-each select='$used-by'>
          <xsl:variable name='sform-id' select='generate-id(.)'/>
          <span class="button button-small">
            <a href='#{$sform-id}'>
              <xsl:value-of select='@name'/>
            </a>
          </span>
        </xsl:for-each>
      </div>
    </xsl:if>

    <div>
      <button class="btn btn-primary" type="button" data-toggle="collapse" data-target="#h_{$report-id}" >Show form</button>
      <div class="collapse" id="h_{$report-id}">
        <xsl:apply-templates select='.' mode='render-report'/>
      </div>
      <!--
      <button class="btn btn-default" type="button" data-toggle="collapse" data-target="#ctrl_{$form-id}" >Show controls</button>
      <div class="collapse" id="ctrl_{$form-id}">
        <table class='table table-bordered table-condensed table-hover'>
          <xsl:apply-templates select='Sections/Section/Controls/*' mode='control-table' />
        </table>
      </div>
      -->
      <xsl:if test='Module'>

        <button class="btn btn-default" type="button" data-toggle="collapse" data-target="#code_{$report-id}" >Show code</button>
        <div class="collapse" id="code_{$report-id}">
          <xsl:variable name="code" select="descendant::Code"/>
          <xsl:if test="$code">
            <table>
              <xsl:if test="Events/Code">
                <tr>
                  <th>Form</th>
                  <td>
                    <xsl:apply-templates mode="code-button" select="Events/Code"/>
                  </td>
                </tr>
              </xsl:if>
            </table>
          </xsl:if>
          <table class='table table-bordered table-condensed table-hover'>
            <xsl:for-each select='Events/Code'>
              <tr>
                <th>
                  <xsl:apply-templates mode="code-button" select="."/>
                </th>
              </tr>
              <tr>
                <td>
                  <code>...</code>
                </td>
              </tr>
            </xsl:for-each>
          </table>
          <xsl:apply-templates select='Module' mode='code'/>
        </div>
      </xsl:if>
    </div>

  </xsl:template>

  <xsl:template match='Report' mode='render-report'>
    <!-- <div class='form-def' style='width:{@width}px; height:{@height}px; '> -->
    <div>
      <xsl:apply-templates select='Events/Code' mode='code-button'/>
    </div>
    <div class='report-def'>
      <div class="report-canvas" >
        <xsl:apply-templates select='Sections' mode='render-control'/>
        <!-- <xsl:apply-templates select='Controls/*' mode='render-control'/>-->
      </div>
    </div>
  </xsl:template>


</xsl:stylesheet>
