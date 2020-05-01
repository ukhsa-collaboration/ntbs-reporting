<?xml version="1.0" encoding="utf-8"?>
<ComponentItem Name="FromYear" xmlns="http://schemas.microsoft.com/sqlserver/reporting/2010/01/componentdefinition" xmlns:rdl="http://schemas.microsoft.com/sqlserver/reporting/2016/01/reportdefinition" xmlns:rd="http://schemas.microsoft.com/SQLServer/reporting/reportdesigner">
  <Properties>
    <Property Name="Type">ReportParameter</Property>
    <Property Name="ThumbnailSource">iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAH7SURBVEhL7VW/i1pBEJ4Lh/ijUUsLIYVgoVbaprQJBCEgEf8BtVNBuCZFBA2IpkhnF7ASEiQQUIlBsBMN5FpBC0EMIgqCWmUz37A+cvAgPC5XJOSDj/lmd9/O7sws70opRQ8JI8DTlx//WKRPr55daUmPtH0w/P0BCDUAC4UCm/tD72Ps+4/WoFgs3uG9cMnV/xpcEAqFYIyXfK2tZfT7fRoMBnQ4HPQIUTwep1QqBfmZ+YK5sVyD3W6nyuWyajQaaj6f61GlVquVajabqlQqiWZ8Y9pNA0BfePGxIQDbarVEm6HX68kBTqcT3BtLN5hMJnJC/bEEymazQgTGPOawBppxa6nIy+WSIpEI2e12qcFisaBKpSKczWbkcDhkDmu22y0+CZgW2exx1Wo12mw2FAwGxUeBk8kkud1u8X0+nwQAXC4XHY9HyB+mAer1ulZ34XQ6iVMgGt3j9XpFn89n4sKSx+MRHzeLRqOQXy2lyO/303g8Fo0TIy1At9sVyx1G0+mU1us1hcNhDL2xFCAWi8nJR6MRpdNp6nQ6lMvlZC6RSEga2+02ZTIZpO4tD3+w1EUAeh9dg57X/W6GJlP2NX76XNjf/vRtNhtVq9X3+/3++XA4lE76FYFAgPL5PORr5g2EcQOLfMJ8x1wwj0zgO/MLs8R8zOR1in4CaL7GQ+Chs5oAAAAASUVORK5CYII=</Property>
    <Property Name="ThumbnailMimeType">image/png</Property>
  </Properties>
  <RdlFragment>
    <rdl:Report>
      <rdl:AutoRefresh>0</rdl:AutoRefresh>
      <rdl:DataSets>
        <rdl:DataSet Name="YearShared">
          <rdl:SharedDataSet>
            <rdl:SharedDataSetReference>/Report Parts/YearShared</rdl:SharedDataSetReference>
            <rd:ReportServerUrl>http://ntbs-reporting.uksouth.cloudapp.azure.com/ReportServer</rd:ReportServerUrl>
          </rdl:SharedDataSet>
          <rdl:Fields>
            <rdl:Field Name="Id">
              <rdl:DataField>Id</rdl:DataField>
              <rd:TypeName>System.Int32</rd:TypeName>
            </rdl:Field>
            <rdl:Field Name="NotificationYear">
              <rdl:DataField>NotificationYear</rdl:DataField>
              <rd:TypeName>System.Int32</rd:TypeName>
            </rdl:Field>
          </rdl:Fields>
        </rdl:DataSet>
      </rdl:DataSets>
      <rdl:ReportSections>
        <rdl:ReportSection>
          <rdl:Body>
            <rdl:Height>0cm</rdl:Height>
            <rdl:Style />
          </rdl:Body>
          <rdl:Width>0cm</rdl:Width>
          <rdl:Page>
            <rdl:Style />
          </rdl:Page>
        </rdl:ReportSection>
      </rdl:ReportSections>
      <rdl:ReportParameters>
        <rdl:ReportParameter Name="FromYear">
          <rdl:DataType>String</rdl:DataType>
          <rdl:Prompt>*Year</rdl:Prompt>
          <rdl:ValidValues>
            <rdl:DataSetReference>
              <rdl:DataSetName>YearShared</rdl:DataSetName>
              <rdl:ValueField>Id</rdl:ValueField>
              <rdl:LabelField>NotificationYear</rdl:LabelField>
            </rdl:DataSetReference>
          </rdl:ValidValues>
          <ComponentMetadata xmlns="http://schemas.microsoft.com/sqlserver/reporting/2010/01/componentdefinition">
            <ComponentId>589711bf-e429-451c-9a7c-cd2ceec3ea4e</ComponentId>
            <SourcePath>/Report Parts/FromYear</SourcePath>
            <SyncDate>2020-04-28T10:22:38.0100000+01:00</SyncDate>
          </ComponentMetadata>
        </rdl:ReportParameter>
      </rdl:ReportParameters>
      <rdl:ReportParametersLayout>
        <rdl:GridLayoutDefinition>
          <rdl:NumberOfColumns>4</rdl:NumberOfColumns>
          <rdl:NumberOfRows>2</rdl:NumberOfRows>
        </rdl:GridLayoutDefinition>
      </rdl:ReportParametersLayout>
      <rd:ReportUnitType>Invalid</rd:ReportUnitType>
      <rd:ReportID>59b4d61c-17e1-4057-8ff1-8d36447ce559</rd:ReportID>
    </rdl:Report>
  </RdlFragment>
</ComponentItem>