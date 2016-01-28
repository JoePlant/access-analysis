<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >
	<xsl:output method="xml" indent="yes" />
	
	<xsl:template match='Form'>
		<xsl:copy>
			<xsl:attribute name='id'><xsl:value-of select='concat("F_", @name)'/></xsl:attribute>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match='Report'>
		<xsl:copy>
			<xsl:attribute name='id'><xsl:value-of select='concat("R_", @name)'/></xsl:attribute>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match='Module'>
		<xsl:copy>
			<xsl:choose>
				<xsl:when test='ancestor::Form'/>
				<xsl:when test='ancestor::Report'/>
				<xsl:otherwise>
					<xsl:attribute name='id'><xsl:value-of select='concat("M_", @name)'/></xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match='Module/Section'>
		<xsl:variable name='id' select='concat(../@name, "_line_", @lineNo)'/>
		<xsl:copy>
			<xsl:attribute name='id'><xsl:value-of select='$id'/></xsl:attribute>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>		
	</xsl:template>
	
	<xsl:template match='Form/Properties/Property'>
		<xsl:variable name='owner' select='ancestor::Form | ancestor::Report' />
		<xsl:variable name='vba-ref' select='concat("Me.", @name)'/>
		<xsl:variable name='references' select='$owner/Module/Section[contains(text(), $vba-ref)]'/>
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="node()"/>
			<xsl:choose>
				<xsl:when test='$references'>
					<xsl:element name='VBA'>
						<xsl:for-each select='$references'>
							<xsl:variable name='id' select="concat(@name, '_line_', @lineNo)"/>
							<xsl:element name='ModuleRef'>
								<xsl:attribute name='method'><xsl:value-of select='@name'/></xsl:attribute>
								<xsl:attribute name='method-id'><xsl:value-of select='$id'/></xsl:attribute>
							</xsl:element>
						</xsl:for-each>
					</xsl:element>
				</xsl:when>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match='Control'>
		<xsl:variable name='owner' select='ancestor::Form | ancestor::Report' />
		<xsl:variable name='vba-ref' select='concat("Me.", @name)'/>
		<xsl:variable name='method-ref' select='concat(@name, "_")'/>
		<xsl:variable name='references' select='$owner/Module/Section[contains(text(), $vba-ref)]'/>
		<xsl:variable name='methods' select='$owner/Module/Section[starts-with(@name, $method-ref)]'/>
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="node()"/>
			<xsl:choose>
				<xsl:when test='$references'>
					<xsl:element name='VBA'>
						<xsl:for-each select='$references | $methods'>
							<xsl:variable name='id' select="concat(@name, '_line_', @lineNo)"/>
							<xsl:element name='ModuleRef'>
								<xsl:attribute name='method'><xsl:value-of select='@name'/></xsl:attribute>
								<xsl:attribute name='method-id'><xsl:value-of select='$id'/></xsl:attribute>
							</xsl:element>
						</xsl:for-each>
					</xsl:element>
				</xsl:when>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>

	<xsl:template match='Property[.="[Event Procedure]"]'>
		<xsl:variable name='owner' select='ancestor::Form | ancestor::Report' />
		<xsl:variable name='name' select='@name'/>
		<xsl:variable name='prefix'>
			<xsl:choose>
				<xsl:when test='ancestor::Control'>
					<xsl:value-of select='ancestor::Control/Properties/Property[@name="EventProcPrefix"]'/>
				</xsl:when>
				<xsl:when test='ancestor::Form'>Form</xsl:when>
				<xsl:when test='ancestor::Report'>Report</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name='suffix'>
			<xsl:choose>
				<xsl:when test='starts-with($name, "On")'>
					<xsl:value-of select='substring-after($name, "On")'/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select='$name'/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name='method' select='concat($prefix, "_", $suffix)'/>
		<xsl:variable name='id' select="concat($owner/Module/@name, '_line_',$owner/Module/Section[@name=$method]/@lineNo)"/>
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name='method'><xsl:value-of select='$method'/></xsl:attribute>
			<xsl:attribute name='method-id'><xsl:value-of select='$id'/></xsl:attribute>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="*">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*">
		<xsl:copy/>
	</xsl:template>
</xsl:stylesheet>
