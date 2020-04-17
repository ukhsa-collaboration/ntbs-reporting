<?xml version="1.0" encoding="utf-8"?>
<ComponentItem Name="ToYear" xmlns="http://schemas.microsoft.com/sqlserver/reporting/2010/01/componentdefinition" xmlns:rdl="http://schemas.microsoft.com/sqlserver/reporting/2016/01/reportdefinition" xmlns:rd="http://schemas.microsoft.com/SQLServer/reporting/reportdesigner">
  <Properties>
    <Property Name="Type">ReportParameter</Property>
    <Property Name="ThumbnailSource">iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAH7SURBVEhL7VW/i1pBEJ4Lh/ijUUsLIYVgoVbaprQJBCEgEf8BtVNBuCZFBA2IpkhnF7ASEiQQUIlBsBMN5FpBC0EMIgqCWmUz37A+cvAgPC5XJOSDj/lmd9/O7sws70opRQ8JI8DTlx//WKRPr55daUmPtH0w/P0BCDUAC4UCm/tD72Ps+4/WoFgs3uG9cMnV/xpcEAqFYIyXfK2tZfT7fRoMBnQ4HPQIUTwep1QqBfmZ+YK5sVyD3W6nyuWyajQaaj6f61GlVquVajabqlQqiWZ8Y9pNA0BfePGxIQDbarVEm6HX68kBTqcT3BtLN5hMJnJC/bEEymazQgTGPOawBppxa6nIy+WSIpEI2e12qcFisaBKpSKczWbkcDhkDmu22y0+CZgW2exx1Wo12mw2FAwGxUeBk8kkud1u8X0+nwQAXC4XHY9HyB+mAer1ulZ34XQ6iVMgGt3j9XpFn89n4sKSx+MRHzeLRqOQXy2lyO/303g8Fo0TIy1At9sVyx1G0+mU1us1hcNhDL2xFCAWi8nJR6MRpdNp6nQ6lMvlZC6RSEga2+02ZTIZpO4tD3+w1EUAeh9dg57X/W6GJlP2NX76XNjf/vRtNhtVq9X3+/3++XA4lE76FYFAgPL5PORr5g2EcQOLfMJ8x1wwj0zgO/MLs8R8zOR1in4CaL7GQ+Chs5oAAAAASUVORK5CYII=</Property>
    <Property Name="ThumbnailMimeType">image/png</Property>
  </Properties>
  <RdlFragment>
    <rdl:Report>
      <rdl:AutoRefresh>0</rdl:AutoRefresh>
      <rdl:DataSources>
        <rdl:DataSource Name="PHE">
          <rdl:ConnectionProperties>
            <rdl:DataProvider>SQL</rdl:DataProvider>
            <rdl:ConnectString>Data Source=sqlnisntbscol02;Initial Catalog=NTBS_R1_Reporting_Staging</rdl:ConnectString>
            <rdl:IntegratedSecurity>true</rdl:IntegratedSecurity>
            <rdl:Prompt>Enter a user name and password to access the data source:</rdl:Prompt>
          </rdl:ConnectionProperties>
          <rd:SecurityType>Integrated</rd:SecurityType>
          <rd:DataSourceID>c4640378-9393-438a-a618-034c268737e7</rd:DataSourceID>
        </rdl:DataSource>
      </rdl:DataSources>
      <rdl:DataSets>
        <rdl:DataSet Name="YearShared">
          <rdl:Query>
            <rdl:DataSourceName>PHE</rdl:DataSourceName>
            <rdl:CommandText>SELECT
  vwNotificationYear.Id
  ,vwNotificationYear.NotificationYear
FROM
  vwNotificationYear</rdl:CommandText>
            <rd:DesignerState>
              <QueryDefinition xmlns="http://schemas.microsoft.com/ReportingServices/QueryDefinition/Relational">
                <SelectedColumns>
                  <ColumnExpression ColumnOwner="vwNotificationYear" ColumnName="Id" />
                  <ColumnExpression ColumnOwner="vwNotificationYear" ColumnName="NotificationYear" />
                </SelectedColumns>
              </QueryDefinition>
            </rd:DesignerState>
          </rdl:Query>
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
        <rdl:ReportParameter Name="ToYear">
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
            <ComponentId>59445244-695b-4eb1-976b-eab1edface68</ComponentId>
            <SourcePath>/Report Parts/ToYear</SourcePath>
            <SyncDate>2019-01-03T10:17:56.3270000+00:00</SyncDate>
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
      <rd:ReportID>6606f4de-e6a3-4904-b8a9-026c5b0937d5</rd:ReportID>
    </rdl:Report>
  </RdlFragment>
</ComponentItem>