<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >
	<xsl:output method="xml" indent="yes" />

	<xsl:variable name='quote'>"</xsl:variable>

	<xsl:variable name='twips-per-pixel'>15</xsl:variable>
	
	<xsl:key name='subforms-by-name' match='Control[@type-name="SubForm"]' use='Properties/Property[@name="SourceObject"]' />
	
	<xsl:template match='/'>
		<Database>
			<Forms>
				<xsl:apply-templates select='/Database/Forms/Form'/>
			</Forms>
			<Reports>
        <xsl:apply-templates select='/Database/Reports/Report'/>
      </Reports>
      <Modules>
        <xsl:apply-templates select='/Database/Modules/Module'/>
      </Modules>
		</Database>
	</xsl:template>
		
	<xsl:template match="Form">
		<xsl:variable name='sub-forms' select='key("subforms-by-name", @name)' />
		<xsl:variable name='height' select='(Properties/Property[@name="WindowHeight"]) div $twips-per-pixel'/>
		<xsl:variable name='width' select='(Properties/Property[@name="WindowWidth"]) div $twips-per-pixel'/>
    <xsl:variable name='default-view'>
      <xsl:choose>
        <xsl:when test='Properties/Property[@name="DefaultView"] = 0'>SingleForm</xsl:when>
        <xsl:when test='Properties/Property[@name="DefaultView"] = 1'>ContinuousForm</xsl:when>
        <xsl:when test='Properties/Property[@name="DefaultView"] = 2'>Datasheet</xsl:when>
        <xsl:when test='Properties/Property[@name="DefaultView"] = 3'>PivotTable</xsl:when>
        <xsl:when test='Properties/Property[@name="DefaultView"] = 4'>PivotChart</xsl:when>
        <xsl:when test='Properties/Property[@name="DefaultView"] = 5'>SplitForm</xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
<!--
    <xsl:variable name='required-height'>
      <xsl:call-template name='get-required-height'>
        <xsl:with-param name='form' select='.'/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name='required-width'>
      <xsl:call-template name='get-required-width'>
        <xsl:with-param name='form' select='.'/>
      </xsl:call-template>
    </xsl:variable>
    -->
		<Form name='{@name}' id='{@id}' height="{$height}" width="{$width}" defaultView="{$default-view}">
			<xsl:if test='count($sub-forms) > 0'>
				<xsl:attribute name='subform'><xsl:value-of select='count($sub-forms)'/></xsl:attribute>
			</xsl:if> 
			<Events>
				<xsl:apply-templates select='Properties/Property[@method]' mode='code'/>
			</Events>
			<RecordSource type='form'> 
				<DataSource>
					<xsl:apply-templates select="Properties/Property[@name='RecordSource']"/>
				</DataSource>
				<Parameters>
					<xsl:apply-templates select="Properties/Property[@name='InputParameters']"/>
				</Parameters>
			</RecordSource>
			<Sections>
				<xsl:apply-templates select='Section' />
			</Sections>

      <xsl:apply-templates select='Module' />

			<References>
				<xsl:call-template name='search-vba'>	
					<xsl:with-param name='text' select='concat("DoCmd.OpenForm ", $quote, @name, $quote)'/>
					<xsl:with-param name='operation'>OpenForm</xsl:with-param>
				</xsl:call-template>
			</References>
		</Form>
	</xsl:template>
	
	<xsl:template match='Section[not(Controls/Control)]'>
		<xsl:comment>Section: <xsl:value-of select='@name'/></xsl:comment>
	</xsl:template>
	
	<xsl:template match='Section[Controls/Control]'>
		<xsl:variable name='height' select='Properties/Property[@name="Height"] div $twips-per-pixel'/>
		<xsl:variable name='order'>
			<xsl:choose>
				<xsl:when test='starts-with(@name, "FormHeader")'>1</xsl:when>
				<xsl:when test='starts-with(@name, "PageHeader")'>2</xsl:when>
				<xsl:when test='starts-with(@name, "Detail")'>3</xsl:when>
				<xsl:when test='starts-with(@name, "PageFooter")'>4</xsl:when>
				<xsl:when test='starts-with(@name, "FormFooter")'>5</xsl:when>
				<xsl:otherwise>10</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<Section name="{@name}" height="{round($height)}" order="{$order}">
			<Controls>
				<xsl:variable name='vba' select='Controls/Control[VBA]'/>
				<xsl:variable name='source' select='Controls/Control[Properties/Property[@name="ControlSource"]]'/>
				<xsl:variable name='master' select='Controls/Control[Properties/Property[@name="LinkMasterFields"]]'/>
				<xsl:variable name='events' select='Controls/Control[Properties/Property[@method]]'/>
				<xsl:variable name='all' select='Controls/Control' /><!-- select='$vba | $source | $events | $master' /> -->
				<xsl:for-each select='$all'>
					<xsl:variable name='current' select='@name'/>
					<xsl:choose>
						<!-- already referenced as a reference-->
						<xsl:when test='count($all[Controls/ControlRef[@name=$current]]) > 0'>
							<xsl:comment>Control: <xsl:value-of select='@name'/></xsl:comment>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select='.'>
								<xsl:with-param name='controls' select='$all'/>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</Controls>
		</Section>
	</xsl:template>

  <xsl:template match='Form/Module'>
    <Module name='{@name}' line='{@lines}'>
      <xsl:apply-templates/>
    </Module>
  </xsl:template>

  <xsl:template match='Module/Declarations'>
    <Declarations>
      <xsl:value-of select='.'/>
    </Declarations>
  </xsl:template>

  <xsl:template match='Module/Section'>
    <Section id='{@id}' name='{@name}' lineNo='{@lineNo}' type='{@type}'>
      <xsl:value-of select='.'/>
    </Section>
  </xsl:template>

  <xsl:template match="Report">
		<Report name='{@name}' id='{@id}'>
      <Events>
        <xsl:apply-templates select='Properties/Property[@method]' mode='code'/>
      </Events>
      <RecordSource type='form'>
        <DataSource>
          <xsl:apply-templates select="Properties/Property[@name='RecordSource']"/>
        </DataSource>
        <Parameters>
          <xsl:apply-templates select="Properties/Property[@name='InputParameters']"/>
        </Parameters>
      </RecordSource>
      <Sections>
        <xsl:apply-templates select='Section' />
      </Sections>

      <xsl:apply-templates select='Module' />

      <References>
        <xsl:call-template name='search-vba'>
          <xsl:with-param name='text' select='concat("DoCmd.OpenReport ", $quote, @name, $quote)'/>
          <xsl:with-param name='operation'>OpenReport</xsl:with-param>
        </xsl:call-template>
      </References>
		</Report>
	</xsl:template>

  <xsl:template match="Database/Modules/Module">
    <Module name='{@name}' id='{@id}'>
      <xsl:apply-templates/>
    </Module>
  </xsl:template>
	
	<xsl:template match='ControlRef'>
		<xsl:variable name='name' select='@name'/>
		<xsl:variable name='parent' select='../..'/>
		<xsl:variable name='parent-name' select='$parent/@name'/>
		<xsl:variable name='section' select='ancestor::Section'/>
		<xsl:variable name='control-refs' select='$section/Controls/Control/Controls/ControlRef[@name=$name]'/>
		<xsl:variable name='control' select='$section/Controls/Control[@name=$name]'/>
		<xsl:choose>
			<xsl:when test='count($control-refs) = 1'>
				<xsl:apply-templates select='$control'/>
			</xsl:when>
			<xsl:when test='count($parent/Controls/ControlRef) = 1'>
				<xsl:apply-templates select='$control'/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:comment>Control: <xsl:value-of select='@name'/></xsl:comment>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match='Control'>
		<xsl:param name='controls' select='../Control'/>
		<xsl:variable name='this' select='.'/>
		<xsl:variable name='type'>
			<xsl:choose>
				<xsl:when test='@type-name="Text Box"'>TextBox</xsl:when>
				<xsl:when test='@type-name="Command Button"'>Button</xsl:when>
				<xsl:when test='@type-name="Option group"'>OptionGroup</xsl:when>
				<xsl:when test='@type-name="Option button"'>OptionButton</xsl:when>
				<xsl:when test='@type-name="Toggle Button"'>ToggleButton</xsl:when>
				<xsl:when test='@type-name="Combo box"'>ComboBox</xsl:when>
				<xsl:when test='@type-name="Check box"'>CheckBox</xsl:when>
				<xsl:when test='@type-name="List box"'>ListBox</xsl:when>
        <xsl:when test='@type-name="Tab Control"'>TabControl</xsl:when>
        <xsl:when test='@type-name="Empty Cell"'>EmptyCell</xsl:when>
        <xsl:when test='@type-name="ActiveX (custom) control"'>ActiveXCustomControl</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select='@type-name'/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!--
		<xsl:variable name='child-names' select='Controls/ControlRef/@name'/>
		<xsl:variable name='child-controls' select='../Control[@name=$child-names]'/>
		<xsl:variable name='all-controls' select='../Control'/>
		-->
		<xsl:element name='{$type}'>
			<xsl:attribute name='name'>
				<xsl:value-of select='@name'/>
			</xsl:attribute>
			<xsl:attribute name='left'>
				<xsl:value-of select='round(@left div $twips-per-pixel)'/>
			</xsl:attribute>
			<xsl:attribute name='top'>
				<xsl:value-of select='round(@top div $twips-per-pixel)'/>
			</xsl:attribute>
			<xsl:attribute name='width'>
				<xsl:value-of select='round(@width div $twips-per-pixel)'/>
			</xsl:attribute>
			<xsl:attribute name='height'>
				<xsl:value-of select='round(@height div $twips-per-pixel)'/>
			</xsl:attribute>
			<xsl:apply-templates select='Properties/Property' mode='control-property'/>
			<xsl:apply-templates select='Properties/Property[@method]' mode='code'/>
			
			<xsl:apply-templates select='Controls/ControlRef'/>
			<!--
			<xsl:for-each select='$child-controls'>
				<xsl:variable name='current' select='@name'/>
				<xsl:variable name='refs' select='$this/ancestor::Section/descendant::ControlRef[@name=$current]'/>
				
 				<xsl:choose>
					<xsl:when test='$this/../descendant::ControlRef[@name=$current]'>
					</xsl:when>
					<xsl:when test='$this/descendant::ControlRef[@name=$current]'>
						<xsl:comment>Control: <xsl:value-of select='@name'/></xsl:comment>
					</xsl:when>
					
					<xsl:when test='count($all-controls[Controls/ControlRef[@name=$current]]) > 0'>
					</xsl:when>
					
					<xsl:otherwise>
						<xsl:apply-templates select='.'>
							<xsl:with-param name='controls' select='$controls'/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
			-->
		</xsl:element>
	</xsl:template>
		
	<xsl:template match='Control/Properties/Property' mode='control-property'/>
	
	<xsl:template match='Control/Properties/Property[@name="Caption"]' mode='control-property'>
		<xsl:attribute name='caption'>
			<xsl:value-of select='.'/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match='Control/Properties/Property[@name="ControlSource"]' mode='control-property'>
		<xsl:attribute name='controlSource'>
			<xsl:value-of select='.'/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match='Control/Properties/Property[@name="SourceObject"]' mode='control-property'>
		<xsl:attribute name='sourceObject'>
			<xsl:value-of select='.'/>
		</xsl:attribute>
	</xsl:template>
	
	<xsl:template match='Control/Properties/Property[@name="LinkMasterFields"]' mode='control-property'>
		<xsl:attribute name='linkMaster'>
			<xsl:value-of select='.'/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match='Control/Properties/Property[@name="RowSource"]' mode='control-property'>
		<xsl:attribute name='rowSource'>
			<xsl:value-of select='.'/>
		</xsl:attribute>
	</xsl:template>

	
	<xsl:template match='Control/Properties/Property[@name="LinkChildFields"]' mode='control-property'>
		<xsl:attribute name='linkChild'>
			<xsl:value-of select='.'/>
		</xsl:attribute>
	</xsl:template>
	
	<xsl:template match='Control/Properties/Property[@name="OptionValue"]' mode='control-property'>
		<xsl:attribute name='optionValue'>
			<xsl:value-of select='.'/>
		</xsl:attribute>
	</xsl:template>
		
	<xsl:template match='Property[@method]' mode='code'>
		<Code name='{@name}' method='{@method}' id='{@method-id}'><xsl:value-of select='.'/></Code>
	</xsl:template>

	<xsl:template match='Modules/Module/Section' mode='reference'>
		<xsl:variable name='function' select='@name'/>
		<xsl:variable name='file' select='../@name'/>
		<xsl:variable name='id' select='../@id'/>
		<Reference id='{$id}' type='Module' module='{$file}' function='{$function}'>
			<xsl:value-of select='.'/>
		</Reference>
	</xsl:template>
	
	<xsl:template match='Form/Module/Section' mode='reference'>
		<xsl:variable name='function' select='@name'/>
		<xsl:variable name='module' select='../@name'/>
		<xsl:variable name='file' select='../../@name'/>
		<xsl:variable name='id' select='../../@id'/>
		<Reference id='{$id}' type='Form' file='{$file}' module='{$module}' function='{$function}'>
			<xsl:value-of select='.'/>
		</Reference>
	</xsl:template>

	<xsl:template match='Report/Module/Section' mode='reference'>
		<xsl:variable name='function' select='@name'/>
		<xsl:variable name='module' select='../@name'/>
		<xsl:variable name='file' select='../../@name'/>
		<xsl:variable name='id' select='../../@id'/>
		<Reference id='{$id}' type='Report' file='{$file}' module='{$module}' function='{$function}'>
			<xsl:value-of select='.'/>
		</Reference>
	</xsl:template>
	
	<xsl:template name='search-vba'>
		<xsl:param name='text'/>
		<xsl:param name='operation'/>
		<xsl:variable name='vba-sections' select="//Module/Section[contains(text(), $text)]"/>
		<xsl:choose>
			<xsl:when test='string-length($operation) > 0'>
				<xsl:apply-templates select='$vba-sections[contains(text(), $operation)]' mode='reference'/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select='$vba-sections' mode='reference'/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

  <!--
  <xsl:template name='get-required-height'>
    <xsl:param name='form' select='.'/>
    <xsl:variable name='max-section-height'>
      <xsl:call-template name='sum-attributes'>
        <xsl:with-param name='nodes' select='$form/Sections/Section'/>
        <xsl:with-param name='attribute'>height</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name='max-control-height'>
      <xsl:call-template name='get-max-control-height'>
        <xsl:with-param name='controls' select='$form/Sections/Section/descendant::*[@top and @height]'/>
      </xsl:call-template>
    </xsl:variable>
  </xsl:template>

  <xsl:template name='sum-attributes'>
    <xsl:param name='nodes' select='.'/>
    <xsl:param name='attribute'>value</xsl:param>
    <xsl:param name='total'>0</xsl:param>
    <xsl:param name='position'>1</xsl:param>
    <xsl:variable name='count' select='count($nodes)'/>
    <xsl:variable name='value'>
      <xsl:choose>
        <xsl:when test='@*[name()=$attribute]'>
          <xsl:value-of select='@*[name()=$attribute]'/>
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test='$position = $count'>
        <xsl:value-of select='$total + $value'/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name='sum-attributes'>
          <xsl:with-param name='nodes' select='$nodes'/>
          <xsl:with-param name='attribute' select='$attribute'/>
          <xsl:with-param name='total' select='$total + $value'/>
          <xsl:with-param name='position' select='$position + 1'/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
-->
	<!--
	
	<xsl:template match="*">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*">
		<xsl:copy/>
	</xsl:template>

	-->
</xsl:stylesheet>
