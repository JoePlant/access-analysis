<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:dotml="http://www.martin-loetzsch.de/DOTML" >
	
 	<xsl:template match='/Database/Forms' mode='summary'>
		<table class="table table-condensed table-hover">
			<tr>
				<td>Number of forms:</td>
				<td><xsl:value-of select='count(Form)'/></td>
			</tr>
			<tr>
				<td>Number of main forms:</td>
				<td><xsl:value-of select='count($main-forms)'/></td>
			</tr>
			<tr>
				<td>Number of subforms:</td>
				<td><xsl:value-of select='count(Form/Controls/SubForm)'/></td>
			</tr>
		</table>
	</xsl:template>
	
</xsl:stylesheet>
