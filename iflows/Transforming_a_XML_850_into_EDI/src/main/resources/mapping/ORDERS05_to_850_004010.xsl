<?xml version="1.0" encoding="UTF-8"?>
<!--
  ╔══════════════════════════════════════════════════════════════════════════╗
  ║  XSLT Map: ORDERS05 (SAP IDoc) → Interchange/M_850 (ASC X12 004010)   ║
  ║  Source XSD : ORDERS05_RD.xsd              SAP S/4HANA 1709, SAP_IDoc  ║
  ║  Target XSD : ASC-X12_850_004010.xsd       ASC X12 version 004010      ║
  ║               targetNamespace: urn:sap.com:typesystem:b2b:116:asc-x12:004010 ║
  ║  XSLT vers  : 1.0                                                       ║
  ╠══════════════════════════════════════════════════════════════════════════╣
  ║  CHANGES vs. previous version of this map                               ║
  ║  ─────────────────────────────────────────────────────────────────────  ║
  ║  • Namespace : …:asc-x12:004010  (was …:asc-x12)                       ║
  ║  • Root elem : Interchange (was M_850)                                   ║
  ║                → adds S_ISA / FunctionalGroup / S_GS / S_GE / S_IEA   ║
  ║  • G_N1      → L_N1  (party name loop)                                  ║
  ║  • G_PO1     → L_PO1 (line item loop)                                   ║
  ║  • G_PID     → L_PID (description loop inside L_PO1)                    ║
  ║  • G_CTT     removed — S_CTT is now a direct child of M_850             ║
  ║  • S_AMT     after S_CTT now named S_AMT_sum in the updated schema      ║
  ║  • ITD D_351 → D_386  (ITD07 = Terms Net Days; D_351 = Discount Days)   ║
  ║  • S_CTT/D_347 added: Hash Total = sum of all PO1 quantities            ║
  ╠══════════════════════════════════════════════════════════════════════════╣
  ║  FULL FIELD MAPPING                                                      ║
  ║  ─────────────────────────────────────────────────────────────────────  ║
  ║  INTERCHANGE ENVELOPE  (not counted in SE01 segment count)              ║
  ║  [constant "00"]                  S_ISA/D_I01   Auth qualifier          ║
  ║  [10 spaces]                      S_ISA/D_I02   Auth info (pad-10)      ║
  ║  [constant "00"]                  S_ISA/D_I03   Security qualifier       ║
  ║  [10 spaces]                      S_ISA/D_I04   Security info (pad-10)  ║
  ║  [constant "ZZ"]                  S_ISA/D_I05_1 Sender ID qualifier     ║
  ║  EDI_DC40/SNDPRN (pad to 15)      S_ISA/D_I06   Sender ID (space-pad)  ║
  ║  [constant "ZZ"]                  S_ISA/D_I05_2 Receiver ID qualifier   ║
  ║  EDI_DC40/RCVPRN (pad to 15)      S_ISA/D_I07   Receiver ID (space-pad)║
  ║  E1EDK03/DATUM (pos 3-8, YYMMDD)  S_ISA/D_I08   ISA date               ║
  ║  [constant "0000"]                S_ISA/D_I09   ISA time                ║
  ║  [constant "U"]                   S_ISA/D_I10   Standards ID            ║
  ║  [constant "00401"]               S_ISA/D_I11   Version                 ║
  ║  DOCNUM rightmost 9               S_ISA/D_I12   ICN (9-char)            ║
  ║  [constant "0"]                   S_ISA/D_I13   Ack requested           ║
  ║  [constant "P"]                   S_ISA/D_I14   Production              ║
  ║  [constant ":"]                   S_ISA/D_I15   Component separator     ║
  ║  [constant "PO"]                  S_GS/D_479    Functional ID           ║
  ║  EDI_DC40/SNDPRN                  S_GS/D_142    App sender              ║
  ║  EDI_DC40/RCVPRN                  S_GS/D_124    App receiver            ║
  ║  E1EDK03/DATUM                    S_GS/D_373    Group date (CCYYMMDD)   ║
  ║  [constant "0000"]                S_GS/D_337    Group time              ║
  ║  DOCNUM rightmost 9               S_GS/D_28     Group control number    ║
  ║  [constant "X"]                   S_GS/D_455    Agency (ASC X12)        ║
  ║  [constant "004010"]              S_GS/D_480    Version                 ║
  ║  TRANSACTION SET  (ST through SE, all counted in SE01)                  ║
  ║  [constant "850"]                 S_ST/D_143                            ║
  ║  DOCNUM rightmost 9               S_ST/D_329    Transaction ctrl num    ║
  ║  E1EDK01/ACTION → code map (1)    S_BEG/D_353   Purpose code           ║
  ║  E1EDK01/BSART  → code map (2)    S_BEG/D_92    PO type code           ║
  ║  E1EDK01/BELNR                    S_BEG/D_324   PO number              ║
  ║  E1EDK03/DATUM                    S_BEG/D_373   PO date (CCYYMMDD)     ║
  ║  [constant "BY"]                  S_CUR/D_98    Buying party            ║
  ║  E1EDK01/CURCY                    S_CUR/D_100   Currency code           ║
  ║  [constant "01"]                  S_ITD/D_336   Terms type (Basic)      ║
  ║  E1EDK01/ZTERM (strip letters)    S_ITD/D_386   Terms net days (ITD07)  ║
  ║  [constant "004"]                 S_DTM/D_374   PO date qualifier       ║
  ║  E1EDK03/DATUM                    S_DTM/D_373   Date (CCYYMMDD)        ║
  ║  E1EDKA1/E1EDKA1/PARVW → map (5) L_N1/S_N1/D_98  Entity code          ║
  ║  E1EDKA1/E1EDKA1/NAME1            L_N1/S_N1/D_93  Name                 ║
  ║  [constant "92"]                  L_N1/S_N1/D_66  ID qualifier          ║
  ║  E1EDKA1/E1EDKA1/LIFNR            L_N1/S_N1/D_67  Vendor ID            ║
  ║  E1EDKA1/E1EDKA1/NAME2            L_N1/S_N2/D_93  Name line 2          ║
  ║  E1EDKA1/E1EDKA1/STRAS            L_N1/S_N3/D_166 Street               ║
  ║  E1EDKA1/E1EDKA1/ORT01            L_N1/S_N4/D_19  City                 ║
  ║  E1EDKA1/E1EDKA1/REGIO (2-char)   L_N1/S_N4/D_156 State               ║
  ║  E1EDKA1/E1EDKA1/PSTLZ            L_N1/S_N4/D_116 Postal               ║
  ║  E1EDKA1/E1EDKA1/LAND1            L_N1/S_N4/D_26  Country              ║
  ║  E1EDP01/E1EDP01/POSEX            L_PO1/S_PO1/D_350  Line number       ║
  ║  E1EDP01/E1EDP01/MENGE            L_PO1/S_PO1/D_330  Qty ordered       ║
  ║  E1EDP01/E1EDP01/MENEE → map (3)  L_PO1/S_PO1/D_355  UOM code         ║
  ║  E1EDP01/E1EDP01/PREIS            L_PO1/S_PO1/D_212  Unit price        ║
  ║  [constant "UM"]                  L_PO1/S_PO1/D_639  Price basis       ║
  ║  E1EDP01/E1EDP19/QUALF → map (4)  L_PO1/S_PO1/D_235  Prod ID qual     ║
  ║  E1EDP01/E1EDP19/IDTNR            L_PO1/S_PO1/D_234  Product ID        ║
  ║  [constant "F"]                   L_PO1/L_PID/S_PID/D_349  Type        ║
  ║  E1EDP01/E1EDP19/KTEXT            L_PO1/L_PID/S_PID/D_352  Desc text   ║
  ║  count(E1EDP01)                   S_CTT/D_354   Line count             ║
  ║  sum(E1EDP01/E1EDP01/MENGE)       S_CTT/D_347   Hash total (qty sum)   ║
  ║  [constant "TT"]                  S_AMT_sum/D_522  Total amount qual   ║
  ║  E1EDS01/SUMME                    S_AMT_sum/D_782  Net order total     ║
  ║  [calculated]                     S_SE/D_96   Segment count            ║
  ║  DOCNUM rightmost 9               S_SE/D_329  = S_ST/D_329             ║
  ║  ─────────────────────────────────────────────────────────────────────  ║
  ║  Code maps                                                               ║
  ║  (1) ACTION → D_353  000/blank→00  001→02  002→05  003→01  004→04      ║
  ║  (2) BSART  → D_92   NB→SA  MK→BL  UB→TR  FO→KN  *→SA                ║
  ║  (3) MENEE  → D_355  TO→MT  KG→KG  G→GR  EA→EA  PC→PC  ST→ST         ║
  ║                       M→ME  M2→SM  M3→CF  LB→LB  FT→FT  L→LT  *→ZZ  ║
  ║  (4) QUALF  → D_235  001→BP  002→VP  003→EN  004→MG  *→ZZ             ║
  ║  (5) PARVW  → D_98   LF→VN  WE→ST  AG→BY  RE→RI  *→OB                ║
  ║  ─────────────────────────────────────────────────────────────────────  ║
  ║  SE01 segment count formula:                                             ║
  ║    3 (ST+BEG+SE fixed) + lineCount×2 (PO1+PID per line) + 1 (CTT)      ║
  ║    + cCUR + cITD + cDTM + cN1 + cN2 + cN3 + cN4 + cAMT               ║
  ║    ISA/GS/GE/IEA are interchange envelope — NOT counted in SE01         ║
  ╚══════════════════════════════════════════════════════════════════════════╝
-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="urn:sap.com:typesystem:b2b:116:asc-x12:004010">

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
  <xsl:strip-space elements="*"/>

  <!-- ════════════════════════════════════════════════════════════════════
       ROOT TEMPLATE
       ════════════════════════════════════════════════════════════════════ -->
  <xsl:template match="/ORDERS05">

    <!-- ── Shared variables ─────────────────────────────────────────── -->
    <xsl:variable name="lineCount" select="count(E1EDP01)"/>

    <!-- Rightmost 9 chars of DOCNUM → ISA13 / GS06 / ST02 / SE02 (all must match) -->
    <xsl:variable name="rawDocNum" select="normalize-space(EDI_DC40/DOCNUM)"/>
    <xsl:variable name="ctrlNum">
      <xsl:choose>
        <xsl:when test="string-length($rawDocNum) &gt; 9">
          <xsl:value-of select="substring($rawDocNum, string-length($rawDocNum) - 8)"/>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="$rawDocNum"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- ISA sender/receiver: exactly 15 chars, right-padded with spaces
         substring(concat(value, 15-spaces), 1, 15)                          -->
    <xsl:variable name="sndId"
      select="substring(concat(normalize-space(EDI_DC40/SNDPRN),'               '),1,15)"/>
    <xsl:variable name="rcvId"
      select="substring(concat(normalize-space(EDI_DC40/RCVPRN),'               '),1,15)"/>

    <!-- ISA date: YYMMDD — positions 3-8 of CCYYMMDD datum -->
    <xsl:variable name="isaDate" select="substring(normalize-space(E1EDK03/DATUM),3,6)"/>

    <!-- ACTION → D_353 Purpose Code -->
    <xsl:variable name="purposeCode">
      <xsl:choose>
        <xsl:when test="E1EDK01/ACTION = '001'">02</xsl:when>
        <xsl:when test="E1EDK01/ACTION = '002'">05</xsl:when>
        <xsl:when test="E1EDK01/ACTION = '003'">01</xsl:when>
        <xsl:when test="E1EDK01/ACTION = '004'">04</xsl:when>
        <xsl:otherwise>00</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- BSART → D_92 PO Type Code -->
    <xsl:variable name="poTypeCode">
      <xsl:choose>
        <xsl:when test="E1EDK01/BSART = 'NB'">SA</xsl:when>
        <xsl:when test="E1EDK01/BSART = 'MK'">BL</xsl:when>
        <xsl:when test="E1EDK01/BSART = 'UB'">TR</xsl:when>
        <xsl:when test="E1EDK01/BSART = 'FO'">KN</xsl:when>
        <xsl:otherwise>SA</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- PO date (CCYYMMDD) — already in the required format -->
    <xsl:variable name="poDate">
      <xsl:choose>
        <xsl:when test="string-length(normalize-space(E1EDK03/DATUM)) = 8">
          <xsl:value-of select="normalize-space(E1EDK03/DATUM)"/>
        </xsl:when>
        <xsl:otherwise>00000000</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- ZTERM net-days: strip all letters.  "NT30" → "30", "NET30" → "30" -->
    <xsl:variable name="ztermDays"
      select="translate(normalize-space(E1EDK01/ZTERM),
              'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz','')"/>

    <!-- ── Conditional-segment presence flags (1 or 0) ──────────────── -->
    <xsl:variable name="cCUR">
      <xsl:choose>
        <xsl:when test="normalize-space(E1EDK01/CURCY) != ''">1</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="cITD">
      <xsl:choose>
        <xsl:when test="normalize-space(E1EDK01/ZTERM) != ''">1</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="cDTM">
      <xsl:choose>
        <xsl:when test="string-length(normalize-space(E1EDK03/DATUM)) = 8">1</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="cN1">
      <xsl:choose>
        <xsl:when test="E1EDKA1">1</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="cN2">
      <xsl:choose>
        <xsl:when test="normalize-space(E1EDKA1/E1EDKA1/NAME2) != ''">1</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="cN3">
      <xsl:choose>
        <xsl:when test="normalize-space(E1EDKA1/E1EDKA1/STRAS) != ''">1</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="cN4">
      <xsl:choose>
        <xsl:when test="normalize-space(E1EDKA1/E1EDKA1/ORT01)  != ''
                     or normalize-space(E1EDKA1/E1EDKA1/REGIO)  != ''
                     or normalize-space(E1EDKA1/E1EDKA1/PSTLZ)  != ''">1</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="cAMT">
      <xsl:choose>
        <xsl:when test="normalize-space(E1EDS01/SUMME) != ''">1</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- SE01 counts only ST…SE. ISA/GS/GE/IEA are envelope — excluded.
         3 (ST+BEG+SE) + lineCount×2 (PO1+PID per line) + 1 (CTT always)
         + conditional segments: CUR ITD DTM N1 N2 N3 N4 AMT_sum           -->
    <xsl:variable name="segmentCount"
      select="3
            + ($lineCount * 2)
            + number($cCUR)
            + number($cITD)
            + number($cDTM)
            + number($cN1)
            + number($cN2)
            + number($cN3)
            + number($cN4)
            + 1
            + number($cAMT)"/>

    <!-- CTT02 Hash Total = sum of all ordered quantities across lines -->
    <xsl:variable name="hashTotal" select="sum(E1EDP01/E1EDP01/MENGE)"/>

    <!-- ════════════════════════════════════════════════════════════════
         OUTPUT — all elements in urn:sap.com:typesystem:b2b:116:asc-x12:004010
         (declared as default xmlns on xsl:stylesheet)
         ════════════════════════════════════════════════════════════════ -->
    <Interchange>

      <!-- ══ S_ISA: Interchange Control Header ═══════════════════════════
           Fixed-length requirements:
             D_I02 / D_I04 = exactly 10 chars (space-padded)
             D_I06 / D_I07 = exactly 15 chars (space-padded right)
             D_I12         = exactly 9 chars (interchange control number)
           xsl:text is used for the space-only fixed fields to prevent
           the indent="yes" serializer from treating them as ignorable ws.  -->
      <S_ISA>
        <D_I01>00</D_I01>
        <D_I02><xsl:text>          </xsl:text></D_I02>
        <D_I03>00</D_I03>
        <D_I04><xsl:text>          </xsl:text></D_I04>
        <D_I05_1>ZZ</D_I05_1>
        <D_I06><xsl:value-of select="$sndId"/></D_I06>
        <D_I05_2>ZZ</D_I05_2>
        <D_I07><xsl:value-of select="$rcvId"/></D_I07>
        <D_I08><xsl:value-of select="$isaDate"/></D_I08>
        <D_I09>0000</D_I09>
        <D_I10>U</D_I10>
        <D_I11>00401</D_I11>
        <D_I12><xsl:value-of select="$ctrlNum"/></D_I12>
        <D_I13>0</D_I13>
        <D_I14>P</D_I14>
        <D_I15>:</D_I15>
      </S_ISA>

      <FunctionalGroup>

        <!-- ── S_GS: Functional Group Header ──────────────────────────
             D_28 (group control number) must match S_GE/D_28              -->
        <S_GS>
          <D_479>PO</D_479>
          <D_142><xsl:value-of select="normalize-space(EDI_DC40/SNDPRN)"/></D_142>
          <D_124><xsl:value-of select="normalize-space(EDI_DC40/RCVPRN)"/></D_124>
          <D_373><xsl:value-of select="$poDate"/></D_373>
          <D_337>0000</D_337>
          <D_28><xsl:value-of select="$ctrlNum"/></D_28>
          <D_455>X</D_455>
          <D_480>004010</D_480>
        </S_GS>

        <!-- ══ M_850: Purchase Order Transaction Set ════════════════════ -->
        <M_850>

          <!-- S_ST: Transaction Set Header -->
          <S_ST>
            <D_143>850</D_143>
            <D_329><xsl:value-of select="$ctrlNum"/></D_329>
          </S_ST>

          <!-- S_BEG: Beginning Segment for Purchase Order -->
          <S_BEG>
            <D_353><xsl:value-of select="$purposeCode"/></D_353>
            <D_92><xsl:value-of select="$poTypeCode"/></D_92>
            <D_324><xsl:value-of select="normalize-space(E1EDK01/BELNR)"/></D_324>
            <D_373><xsl:value-of select="$poDate"/></D_373>
          </S_BEG>

          <!-- S_CUR: Currency (optional)
               D_98 = "BY" — the buying party's transaction currency        -->
          <xsl:if test="$cCUR = '1'">
            <S_CUR>
              <D_98>BY</D_98>
              <D_100><xsl:value-of select="normalize-space(E1EDK01/CURCY)"/></D_100>
            </S_CUR>
          </xsl:if>

          <!-- S_ITD: Terms of Sale (optional)
               D_336 = "01" (Basic / net terms)
               D_386 = ITD07 Terms Net Days ← numeric part of ZTERM
               IMPORTANT: D_386 is the net-payment days field (ITD07).
               D_351 would be ITD05 = Terms Discount Days Due — different!   -->
          <xsl:if test="$cITD = '1'">
            <S_ITD>
              <D_336>01</D_336>
              <D_386><xsl:value-of select="$ztermDays"/></D_386>
            </S_ITD>
          </xsl:if>

          <!-- S_DTM: Date/Time Reference (optional)
               D_374 = "004" (Purchase Order Date qualifier)                 -->
          <xsl:if test="$cDTM = '1'">
            <S_DTM>
              <D_374>004</D_374>
              <D_373><xsl:value-of select="normalize-space(E1EDK03/DATUM)"/></D_373>
            </S_DTM>
          </xsl:if>

          <!-- L_N1: Name Loop (optional, one per E1EDKA1 partner)
               Uses L_N1 (not G_N1 as in previous schema version).
               PARVW → D_98 entity code (code map 5):
                 LF (Vendor)      → "VN"
                 WE (Ship-to)     → "ST"
                 AG (Buyer/Sold)  → "BY"
                 RE (Bill-to)     → "RI"
                 *                → "OB"
               D_66 = "92" (Mutually Defined / Buyer-assigned ID qualifier)  -->
          <xsl:if test="$cN1 = '1'">
            <L_N1>
              <S_N1>
                <D_98>
                  <xsl:choose>
                    <xsl:when test="normalize-space(E1EDKA1/E1EDKA1/PARVW) = 'LF'">VN</xsl:when>
                    <xsl:when test="normalize-space(E1EDKA1/E1EDKA1/PARVW) = 'WE'">ST</xsl:when>
                    <xsl:when test="normalize-space(E1EDKA1/E1EDKA1/PARVW) = 'AG'">BY</xsl:when>
                    <xsl:when test="normalize-space(E1EDKA1/E1EDKA1/PARVW) = 'RE'">RI</xsl:when>
                    <xsl:otherwise>OB</xsl:otherwise>
                  </xsl:choose>
                </D_98>
                <D_93><xsl:value-of select="normalize-space(E1EDKA1/E1EDKA1/NAME1)"/></D_93>
                <D_66>92</D_66>
                <D_67><xsl:value-of select="normalize-space(E1EDKA1/E1EDKA1/LIFNR)"/></D_67>
              </S_N1>
              <xsl:if test="$cN2 = '1'">
                <S_N2>
                  <D_93><xsl:value-of select="normalize-space(E1EDKA1/E1EDKA1/NAME2)"/></D_93>
                </S_N2>
              </xsl:if>
              <xsl:if test="$cN3 = '1'">
                <S_N3>
                  <D_166><xsl:value-of select="normalize-space(E1EDKA1/E1EDKA1/STRAS)"/></D_166>
                </S_N3>
              </xsl:if>
              <xsl:if test="$cN4 = '1'">
                <S_N4>
                  <xsl:if test="normalize-space(E1EDKA1/E1EDKA1/ORT01) != ''">
                    <D_19><xsl:value-of select="normalize-space(E1EDKA1/E1EDKA1/ORT01)"/></D_19>
                  </xsl:if>
                  <!-- D_156 (state/province) requires exactly 2 chars in 004010 -->
                  <xsl:if test="string-length(normalize-space(E1EDKA1/E1EDKA1/REGIO)) = 2">
                    <D_156><xsl:value-of select="normalize-space(E1EDKA1/E1EDKA1/REGIO)"/></D_156>
                  </xsl:if>
                  <xsl:if test="normalize-space(E1EDKA1/E1EDKA1/PSTLZ) != ''">
                    <D_116><xsl:value-of select="normalize-space(E1EDKA1/E1EDKA1/PSTLZ)"/></D_116>
                  </xsl:if>
                  <xsl:if test="normalize-space(E1EDKA1/E1EDKA1/LAND1) != ''">
                    <D_26><xsl:value-of select="normalize-space(E1EDKA1/E1EDKA1/LAND1)"/></D_26>
                  </xsl:if>
                </S_N4>
              </xsl:if>
            </L_N1>
          </xsl:if>

          <!-- L_PO1: Baseline Item Data Loop (one per outer E1EDP01 wrapper)
               Uses L_PO1 (not G_PO1 as in previous schema version).

               ORDERS05 double-nesting pattern:
                 /ORDERS05/E1EDP01           outer wrapper (for-each context node)
                 /ORDERS05/E1EDP01/E1EDP01   inner line item data
                 /ORDERS05/E1EDP01/E1EDP19   material identification

               S_PO1: D_330 = Quantity Ordered (PO102, required)
                      D_235/D_234 = product ID inline (no separate S_LIN needed)
               L_PID: uses L_PID (not G_PID); S_PID/D_352 = KTEXT description  -->
          <xsl:for-each select="E1EDP01">

            <!-- MENEE → D_355 UOM code (code map 3) -->
            <xsl:variable name="uomCode">
              <xsl:choose>
                <xsl:when test="normalize-space(E1EDP01/MENEE) = 'TO'">MT</xsl:when>
                <xsl:when test="normalize-space(E1EDP01/MENEE) = 'KG'">KG</xsl:when>
                <xsl:when test="normalize-space(E1EDP01/MENEE) = 'G'">GR</xsl:when>
                <xsl:when test="normalize-space(E1EDP01/MENEE) = 'EA'">EA</xsl:when>
                <xsl:when test="normalize-space(E1EDP01/MENEE) = 'PC'">PC</xsl:when>
                <xsl:when test="normalize-space(E1EDP01/MENEE) = 'ST'">ST</xsl:when>
                <xsl:when test="normalize-space(E1EDP01/MENEE) = 'M'">ME</xsl:when>
                <xsl:when test="normalize-space(E1EDP01/MENEE) = 'M2'">SM</xsl:when>
                <xsl:when test="normalize-space(E1EDP01/MENEE) = 'M3'">CF</xsl:when>
                <xsl:when test="normalize-space(E1EDP01/MENEE) = 'LB'">LB</xsl:when>
                <xsl:when test="normalize-space(E1EDP01/MENEE) = 'FT'">FT</xsl:when>
                <xsl:when test="normalize-space(E1EDP01/MENEE) = 'L'">LT</xsl:when>
                <xsl:otherwise>ZZ</xsl:otherwise>
              </xsl:choose>
            </xsl:variable>

            <!-- QUALF → D_235 Product ID Qualifier (code map 4) -->
            <xsl:variable name="productQual">
              <xsl:choose>
                <xsl:when test="normalize-space(E1EDP19/QUALF) = '001'">BP</xsl:when>
                <xsl:when test="normalize-space(E1EDP19/QUALF) = '002'">VP</xsl:when>
                <xsl:when test="normalize-space(E1EDP19/QUALF) = '003'">EN</xsl:when>
                <xsl:when test="normalize-space(E1EDP19/QUALF) = '004'">MG</xsl:when>
                <xsl:otherwise>ZZ</xsl:otherwise>
              </xsl:choose>
            </xsl:variable>

            <L_PO1>
              <S_PO1>
                <D_350><xsl:value-of select="normalize-space(E1EDP01/POSEX)"/></D_350>
                <D_330><xsl:value-of select="normalize-space(E1EDP01/MENGE)"/></D_330>
                <D_355><xsl:value-of select="$uomCode"/></D_355>
                <D_212><xsl:value-of select="normalize-space(E1EDP01/PREIS)"/></D_212>
                <D_639>UM</D_639>
                <D_235><xsl:value-of select="$productQual"/></D_235>
                <D_234><xsl:value-of select="normalize-space(E1EDP19/IDTNR)"/></D_234>
              </S_PO1>

              <!-- L_PID / S_PID: Description loop (uses L_PID not G_PID)
                   D_349 = "F" (Free-form)
                   D_352 = KTEXT (material description, up to 80 chars)      -->
              <L_PID>
                <S_PID>
                  <D_349>F</D_349>
                  <xsl:if test="normalize-space(E1EDP19/KTEXT) != ''">
                    <D_352><xsl:value-of select="normalize-space(E1EDP19/KTEXT)"/></D_352>
                  </xsl:if>
                </S_PID>
              </L_PID>

            </L_PO1>
          </xsl:for-each>

          <!-- S_CTT: Transaction Totals
               Direct child of M_850 (no G_CTT wrapper in this schema version).
               D_354 = line count (number of L_PO1 loops)
               D_347 = hash total = sum of all PO1 quantity values           -->
          <S_CTT>
            <D_354><xsl:value-of select="$lineCount"/></D_354>
            <D_347><xsl:value-of select="$hashTotal"/></D_347>
          </S_CTT>

          <!-- S_AMT_sum: Summary Monetary Amount (optional, after S_CTT)
               Named "S_AMT_sum" in schema to distinguish from header S_AMT.
               D_522 = "TT" (Total Transaction Amount qualifier)
               D_782 ← E1EDS01/SUMME (net order value)                       -->
          <xsl:if test="$cAMT = '1'">
            <S_AMT_sum>
              <D_522>TT</D_522>
              <D_782><xsl:value-of select="normalize-space(E1EDS01/SUMME)"/></D_782>
            </S_AMT_sum>
          </xsl:if>

          <!-- S_SE: Transaction Set Trailer
               D_96  = segment count (ST through SE inclusive)
               D_329 = must match S_ST/D_329 exactly                         -->
          <S_SE>
            <D_96><xsl:value-of select="$segmentCount"/></D_96>
            <D_329><xsl:value-of select="$ctrlNum"/></D_329>
          </S_SE>

        </M_850>

        <!-- S_GE: Functional Group Trailer
             D_97 = "1" (one M_850 in this group)
             D_28 must match S_GS/D_28                                        -->
        <S_GE>
          <D_97>1</D_97>
          <D_28><xsl:value-of select="$ctrlNum"/></D_28>
        </S_GE>

      </FunctionalGroup>

      <!-- S_IEA: Interchange Control Trailer
           D_I16 = "1" (one FunctionalGroup in this interchange)
           D_I12 must match S_ISA/D_I12                                       -->
      <S_IEA>
        <D_I16>1</D_I16>
        <D_I12><xsl:value-of select="$ctrlNum"/></D_I12>
      </S_IEA>

    </Interchange>
  </xsl:template>

</xsl:stylesheet>
