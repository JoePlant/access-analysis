<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:dotml="http://www.martin-loetzsch.de/DOTML" >
	
 	<xsl:template match='/Database/Forms/Form' mode='form'>
		<xsl:variable name='control-code' select='Sections/Section/Controls/descendant::Code'/>
		<xsl:variable name='controls' select='Sections/Section/Controls/descendant::*'/>
		<xsl:variable name='events' select='Events/Code'/>
		<hr/>
		<a name='{@id}'/>
		<h4><xsl:value-of select='@name'/> <span class="label label-default">Form</span></h4>
		
		<div>
      <button class="btn btn-primary" type="button" data-toggle="collapse" data-target="#h_{@id}" >Show form</button>
      <div class="collapse" id="h_{@id}">
        <xsl:apply-templates select='.' mode='render-form'/>
      </div>
      <button class="btn btn-default" type="button" data-toggle="collapse" data-target="#ctrl_{@id}" >Show controls</button>
      <div class="collapse" id="ctrl_{@id}">
        <table class='table table-bordered table-condensed table-hover'>
          <xsl:apply-templates select='Sections/Section/Controls/*' mode='control-table' />
        </table>
      </div>
      <button class="btn btn-default" type="button" data-toggle="collapse" data-target="#code_{@id}" >Show code</button>
      <div class="collapse" id="code_{@id}">
        <table class='table table-bordered table-condensed table-hover'>
          <xsl:for-each select='Events/Code'>
            <tr>
              <th><xsl:value-of select='@name'/></th>
            </tr>
            <tr>
              <td><code>...</code></td>
            </tr>
          </xsl:for-each>
        </table>
      </div>
		</div>
		
	</xsl:template>

	<xsl:template match='Form' mode='render-form'>
		<!-- <div class='form-def' style='width:{@width}px; height:{@height}px; '> -->
    <div>
        <xsl:apply-templates select='Events/Code' mode='code-button'/>
    </div>
    <div class='form-def'>
        <div class="form-canvas" >
				<xsl:apply-templates select='Sections' mode='render-control'/>
			<!-- <xsl:apply-templates select='Controls/*' mode='render-control'/>-->
			</div>
		</div>
	</xsl:template>
	
	<xsl:template match='*' mode='control-table'>
		<xsl:param name='depth'>1</xsl:param>
		<tr>
			<td>
				<xsl:call-template name='indent'>
					<xsl:with-param name='depth' select='$depth'/>
				</xsl:call-template>
				<xsl:value-of select='name()'/>
			</td>
			<td>
				<ul>
				<xsl:for-each select='@*'>
					<li><xsl:value-of select='concat(name(), "=", .)'/></li>
				</xsl:for-each>
				</ul>
			</td>
			<td>
				<xsl:apply-templates select='Code' mode='code-column'/>
			</td>
		</tr>
		<xsl:apply-templates select='*' mode='control-table'>
			<xsl:with-param name='depth' select='$depth + 1'/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match='Sections' mode='render-control'>
		<xsl:apply-templates mode='render-control'>
			<xsl:sort select='@order'/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="Section" mode='render-control'>
<!--		<div title="Section ({@name})" class='control-section' style="top:0px; left:0px; width:100%; height:{@height}px;"> -->
    <div title="Section ({@name})" class='control-section' style="top:0px; left:0px; height:{@height}px;">
        <xsl:apply-templates mode='render-control'/>
		</div>
	</xsl:template>
	
	<xsl:template match='Controls' mode='render-control'>
		<xsl:apply-templates mode='render-control'/> 
	</xsl:template>
	
	
	<xsl:template match="*" mode='render-control'>
		<xsl:comment><xsl:value-of select='name()'/></xsl:comment>
	</xsl:template>
	
	<xsl:template match='Rectangle' mode='render-control'>
		<div title="Rectangle ({@name})" class='control-rectangle' style="top:{@top}px; left:{@left}px; width:{@width}px; height:{@height}px;">
			<xsl:value-of select='@name'/>
		</div>
		<xsl:apply-templates mode='render-control'/>
	</xsl:template>
	
	<xsl:template match='Button' mode='render-control'>
		<button type="button" title="Button '{@caption}' ({@name})" class='control-button' style="top:{@top}px; left:{@left}px; width:{@width}px; height:{@height}px;">
			<xsl:value-of select='@caption'/>
		</button>
		<xsl:apply-templates mode='render-control'/>
	</xsl:template>
	
	<xsl:template match='Label' mode='render-control'>
		<xsl:choose>
			<xsl:when test='string-length(@caption) &gt; 40'>
				<div title="Label '{@caption}' ({@name})" class='control-label' style="top:{@top}px; left:{@left}px; width:{@width}px; height:{@height}px;">
					<pre class='pre'><xsl:value-of select='@caption'/></pre>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<div title="Label '{@caption}' ({@name})" class='control-label' style="top:{@top}px; left:{@left}px; width:{@width}px; height:{@height}px;">
					<xsl:value-of select='@caption'/>
				</div>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode='render-control'/>
	</xsl:template>
	
	<xsl:template match='TextBox' mode='render-control'>
		<input title="TextBox [{@controlSource}] ({@name})" class='control-textbox' style="top:{@top}px; left:{@left}px; width:{@width}px; height:{@height}px;" placeholder="{@controlSource}"/>
		<xsl:apply-templates mode='render-control'/>
	</xsl:template>

	<xsl:template match='ComboBox' mode='render-control'>
		<select title="ComboBox [{@controlSource}] ({@name})" class='control-combobox' style="top:{@top}px; left:{@left}px; width:{@width}px; height:{@height}px;">
			<xsl:if test='@controlSource'>
				<option><xsl:value-of select='@controlSource'/></option>
			</xsl:if>
			<xsl:if test='@rowSource'>
				<option><xsl:value-of select='@rowSource'/></option>
			</xsl:if>
		</select>
		<xsl:apply-templates mode='render-control'/>
	</xsl:template>
	
	<xsl:template match="OptionButton" mode='render-control'>
		<input type='radio' name="{../@name}" title="OptionButton ({@name}) value={@optionValue}" class='control-optionbutton' value='{@optionValue}' style="top:{@top}px; left:{@left}px; width:{@width}px; height:{@height}px;"/>
		<xsl:apply-templates mode='render-control'/>	
	</xsl:template>
	
	<xsl:template match='OptionGroup' mode='render-control'>
		<form>
		<div title="OptionGroup ({@name})" class='control-optiongroup' style="top:{@top}px; left:{@left}px; width:{@width}px; height:{@height}px;"/>
		<xsl:apply-templates mode='render-control'/>		
		</form>
	</xsl:template>

  <xsl:template match='ToggleButton' mode='render-control'>
    <button type="button" title="ToggleButton '{@caption}' ({@name}) value={@optionValue}" class='control-button' style="top:{@top}px; left:{@left}px; width:{@width}px; height:{@height}px;">
      <xsl:value-of select='@caption'/>
    </button>
    <xsl:apply-templates mode='render-control'/>
  </xsl:template>
	
	<xsl:template match="CheckBox" mode='render-control'>
		<input type='checkbox' title="CheckBox ({@name})" class='control-checkbox' value='' style="top:{@top}px; left:{@left}px; width:{@width}px; height:{@height}px;"/>
		<xsl:apply-templates mode='render-control'/>	
	</xsl:template>
	
	<xsl:template match='ActiveXCustomControl' mode='render-control'>
		<div title="ActiveX Custom Control ({@name})" class='control-activex' style="top:{@top}px; left:{@left}px; width:{@width}px; height:{@height}px;">
			<xsl:value-of select='@name'/>
		</div>
		<xsl:apply-templates mode='render-control'/>
	</xsl:template>
	
	<xsl:template match='Image' mode='render-control'>
		<div title="Image ({@name})" class='control-image' style="top:{@top}px; left:{@left}px; width:{@width}px; height:{@height}px;">
			<span class="glyphicon glyphicon-picture" aria-hidden="true"></span>
			<xsl:value-of select='@name'/>
		</div>
		<xsl:apply-templates mode='render-control'/>
	</xsl:template>

	<xsl:template match='SubForm' mode='render-control'>
		<xsl:variable name='source' select='@sourceObject'/>
		<xsl:variable name='subform' select='$sub-forms[@name=$source]'/>
		<div title="SubForm ({@name}) Form={@sourceObject}" class='control-subform' style="top:{@top}px; left:{@left}px; width:{@width}px; height:{@height}px;">
			<xsl:value-of select='@name'/>
			<xsl:apply-templates select='$subform' mode='render-form'/>
		</div>
		<xsl:apply-templates mode='render-control'/>
	</xsl:template>

  <xsl:template match='ListBox' mode='render-control'>
    <select name='{@name}' size='5' title="ListBox ({@name})" class='control-listbox' style="top:{@top}px; left:{@left}px; width:{@width}px; height:{@height}px;">
      <xsl:value-of select='@name'/>
    </select>
    <xsl:apply-templates mode='render-control'/>
  </xsl:template>
	
	<xsl:template match='Code' mode='code-column'>
		<button type="button" class="btn btn-success btn-xs">
			<xsl:value-of select='@name'/>
			<xsl:text> </xsl:text>
			<span class="glyphicon glyphicon-comment" aria-hidden="true"/>
		</button>
	</xsl:template>
	
	<xsl:template match='Code' mode='control-table'>
		<xsl:comment> Code: <xsl:value-of select='@name'/> </xsl:comment>
	</xsl:template>

  <xsl:template match='Code' mode='code-button'>
    <button type="button" class="btn btn-success btn-xs">
      <xsl:value-of select='@name'/>
      <xsl:text> </xsl:text>
      <span class="glyphicon glyphicon-comment" aria-hidden="true"/>
    </button>
  </xsl:template>

  <xsl:template name='indent'>
		<xsl:param name='depth'>0</xsl:param>
		<xsl:choose>
			<xsl:when test='$depth &lt;= 0'/>
			<xsl:when test='$depth = 1'>
				<xsl:text>-</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>-</xsl:text>
				<xsl:call-template name='indent'>
					<xsl:with-param name='depth' select='$depth - 1'/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match='*' mode='tree'>
		<ul>
			<xsl:for-each select='*'>
				<li>
					<xsl:value-of select='@name'/>
					<xsl:if test='*'>
						<xsl:apply-templates mode='tree'/>
					</xsl:if>
				</li>
			</xsl:for-each>
		</ul>
	</xsl:template>
	
	
</xsl:stylesheet>
