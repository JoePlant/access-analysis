<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns="urn:schemas-microsoft-com:office:spreadsheet"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
                xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" >
  <!-- 
  This XSL transforms Production data into an Office XML 2003 file.
  https://msdn.microsoft.com/en-us/library/aa140066(v=office.10).aspx
  -->
  <xsl:output method="xml" encoding="utf-8" indent="yes" />
  <xsl:param name="lang">en</xsl:param>

  <xsl:include href='excel-common.xslt' />

  <xsl:key name='forms-by-name' match='Form' use='@name'/>
  <xsl:key name='subforms-by-source-object' match='SubForm' use='@sourceObject'/>

  <xsl:template match="/">
    <xsl:call-template name='excel-header-1'/>
    <Workbook  xmlns="urn:schemas-microsoft-com:office:spreadsheet"
			xmlns:o="urn:schemas-microsoft-com:office:office"
			xmlns:x="urn:schemas-microsoft-com:office:excel"
			xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
			xmlns:html="http://www.w3.org/TR/REC-html40">

      <xsl:call-template name='workbook-styles' />

      <Worksheet ss:Name='Forms'>
        <Table>
          <Row>
            <xsl:call-template name='header-cell'>
              <xsl:with-param name='text'>Form</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name='header-cell'>
              <xsl:with-param name='text'>Type</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name='header-cell'>
              <xsl:with-param name='text'>Controls</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name='header-cell'>
              <xsl:with-param name='text'>SubForms</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name='header-cell'>
              <xsl:with-param name='text'>Used by Form</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name='header-cell'>
              <xsl:with-param name='text'>DataSource</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name='header-cell'>
              <xsl:with-param name='text'>Parameters</xsl:with-param>
            </xsl:call-template>
          </Row>
          <xsl:for-each select='/Database/Forms/Form'>
            <xsl:variable name='sub-forms' select='descendant::SubForm'/>
            <xsl:variable name='used-by' select="key('subforms-by-source-object', @name)/ancestor::Form"/>
            <Row>
              <xsl:call-template name='text-cell'>
                <xsl:with-param name='text' select='@name'/>
              </xsl:call-template>
              <xsl:call-template name='text-cell'>
                <xsl:with-param name='text'>
                  <xsl:choose>
                    <xsl:when test='$used-by'><xsl:value-of select='@defaultView'/> (SubForm)</xsl:when>
                    <xsl:when test='@defaultView'>
                      <xsl:value-of select='@defaultView'/>
                    </xsl:when>
                    <xsl:otherwise>Form</xsl:otherwise>
                  </xsl:choose>
                </xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name='number-cell'>
                <xsl:with-param name='value' select='count(descendant::Controls/*)'/>
              </xsl:call-template>
              <xsl:call-template name='text-cell'>
                <xsl:with-param name='text'>
                  <xsl:for-each select="descendant::SubForm">
                    <xsl:if test="position() > 1">, </xsl:if>
                    <xsl:value-of select="@sourceObject"/>
                  </xsl:for-each>
                </xsl:with-param> 
              </xsl:call-template>
              <xsl:call-template name='text-cell'>
                <xsl:with-param name='text'>
                  <xsl:for-each select="$used-by">
                    <xsl:if test="position() > 1">, </xsl:if>
                    <xsl:value-of select="@name"/>
                  </xsl:for-each> 
                </xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name='text-cell'>
                <xsl:with-param name='text' select='RecordSource/DataSource'/>
              </xsl:call-template>
              <xsl:call-template name='text-cell'>
                <xsl:with-param name='text' select='RecordSource/Parameters'/>
              </xsl:call-template>
            </Row>
          </xsl:for-each>
        </Table>
      </Worksheet>
      
      
      <Worksheet ss:Name='Form Code'>
        <Table>
          <Row>
            <xsl:call-template name='header-cell'>
              <xsl:with-param name='text'>Form</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name='header-cell'>
              <xsl:with-param name='text'>Object</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name='header-cell'>
                <xsl:with-param name='text'>Object name</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name='header-cell'>
              <xsl:with-param name='text'>Code</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name='header-cell'>
              <xsl:with-param name='text'>Code name</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name='header-cell'>
              <xsl:with-param name='text'>Code details</xsl:with-param>
            </xsl:call-template>
          </Row>
          <xsl:for-each select='/Database/Forms/Form'>
            <xsl:variable name='form' select='.'/>
            <xsl:for-each select='$form/Events/Code'>
              <Row>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text' select='$form/@name'/>
                </xsl:call-template>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text'>Form</xsl:with-param> 
                </xsl:call-template>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text'>Form</xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text' select='@name'/>
                </xsl:call-template>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text' select='@method'/>
                </xsl:call-template>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text' select='.'/>
                </xsl:call-template>
              </Row>
            </xsl:for-each>
            <xsl:for-each select='$form/Sections/descendant::Code'>
              <xsl:variable name='control' select='..'/>
              <Row>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text' select='$form/@name'/>
                </xsl:call-template>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text' select='name($control)'/>
                </xsl:call-template>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text' select='$control/@name'/>
                </xsl:call-template>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text' select='@name'/>
                </xsl:call-template>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text' select='@method'/>
                </xsl:call-template>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text' select='.'/>
                </xsl:call-template>
              </Row>
            </xsl:for-each>
          </xsl:for-each>
        </Table>
      </Worksheet>
      <Worksheet ss:Name='Reports'>
        <Table>
          <Row>
            <xsl:call-template name='header-cell'>
              <xsl:with-param name='text'>Report</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name='header-cell'>
              <xsl:with-param name='text'>Type</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name='header-cell'>
              <xsl:with-param name='text'>Controls</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name='header-cell'>
              <xsl:with-param name='text'>DataSource</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name='header-cell'>
              <xsl:with-param name='text'>Parameters</xsl:with-param>
            </xsl:call-template>
          </Row>
          <xsl:for-each select='/Database/Reports/Report'>
<!--            
            <xsl:variable name='sub-forms' select='descendant::SubForm'/>
            <xsl:variable name='used-by' select="key('subforms-by-source-object', @name)/ancestor::Form"/> 
-->
            <Row>
              <xsl:call-template name='text-cell'>
                <xsl:with-param name='text' select='@name'/>
              </xsl:call-template>
              <xsl:call-template name='text-cell'>
                <xsl:with-param name='text'>
                  <xsl:choose>
                    <xsl:when test='@defaultView'>
                      <xsl:value-of select='@defaultView'/>
                    </xsl:when>
                    <xsl:otherwise>Report</xsl:otherwise>
                  </xsl:choose>
                </xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name='number-cell'>
                <xsl:with-param name='value' select='count(descendant::Controls/*)'/>
              </xsl:call-template>
              <xsl:call-template name='text-cell'>
                <xsl:with-param name='text' select='RecordSource/DataSource'/>
              </xsl:call-template>
              <xsl:call-template name='text-cell'>
                <xsl:with-param name='text' select='RecordSource/Parameters'/>
              </xsl:call-template>
            </Row>
          </xsl:for-each>
        </Table>
      </Worksheet>

      <Worksheet ss:Name='Report Code'>
        <Table>
          <Row>
            <xsl:call-template name='header-cell'>
              <xsl:with-param name='text'>Report</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name='header-cell'>
              <xsl:with-param name='text'>Object</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name='header-cell'>
              <xsl:with-param name='text'>Object name</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name='header-cell'>
              <xsl:with-param name='text'>Code</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name='header-cell'>
              <xsl:with-param name='text'>Code name</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name='header-cell'>
              <xsl:with-param name='text'>Code details</xsl:with-param>
            </xsl:call-template>
          </Row>
          <xsl:for-each select='/Database/Reports/Report'>
            <xsl:variable name='report' select='.'/>
            <xsl:for-each select='$report/Events/Code'>
              <Row>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text' select='$report/@name'/>
                </xsl:call-template>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text'>Report</xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text'>Report</xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text' select='@name'/>
                </xsl:call-template>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text' select='@method'/>
                </xsl:call-template>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text' select='.'/>
                </xsl:call-template>
              </Row>
            </xsl:for-each>
            <xsl:for-each select='$report/Sections/descendant::Code'>
              <xsl:variable name='control' select='..'/>
              <Row>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text' select='$report/@name'/>
                </xsl:call-template>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text' select='name($control)'/>
                </xsl:call-template>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text' select='$control/@name'/>
                </xsl:call-template>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text' select='@name'/>
                </xsl:call-template>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text' select='@method'/>
                </xsl:call-template>
                <xsl:call-template name='text-cell'>
                  <xsl:with-param name='text' select='.'/>
                </xsl:call-template>
              </Row>
            </xsl:for-each>
          </xsl:for-each>
        </Table>
      </Worksheet>

    </Workbook>
  </xsl:template>

</xsl:stylesheet>
