/**
 * @agarciaodeian
 */

@isTest
private class HelloWorldTest
{
	@isTest
	static void retrieveListViewFilteredByFinishedEvents()
	{
		DataSource.ConnectionParams params = new DataSource.ConnectionParams();

		HelloWorldProvider provider = new HelloWorldProvider();
		DataSource.Connection connect = provider.getConnection(params);

		HelloWorldConnection connection = new HelloWorldConnection(params);

		List<DataSource.Table> tables = connection.sync();
		System.assertEquals(1, tables.size());

		DataSource.Table theTable = tables.get(0);
		System.assertEquals('DreamforceEvents', theTable.Name);

		DataSource.QueryContext myNewContext = updateQueryContextFinishedEvents(new DataSource.QueryContext(), theTable.Name);

		DataSource.TableResult tableResult = connection.query(myNewContext);

		List<Map<String,Object>> tableRows = tableResult.rows;
		System.assertEquals(2, tableRows.size());

		for(Integer i=0; i<2; i++)
		{
			Map<String,Object> fieldAndValue = tableRows.get(i);

			String externalIdValue = (String)fieldAndValue.get('ExternalId');

			//I have retrieved row filterd by Finished value.
			//As long as Dremforce has ended, I will show it
			for(String fieldName : fieldAndValue.keySet())
			{
				if(fieldName == 'Attendes')
				{
					if(externalIdValue == 'df_1')
						System.assertEquals(120000, fieldAndValue.get(fieldName));
					else
						System.assertEquals(135000, fieldAndValue.get(fieldName));
				}
				else if(fieldName == 'DisplayUrl')
				{
					if(externalIdValue == 'df_1')
						System.assertEquals('http://www.dftest1.com', fieldAndValue.get(fieldName));
					else
						System.assertEquals('http://www.dftest2.com', fieldAndValue.get(fieldName));
				}
				else if(fieldName == 'ExternalId')
				{
					if(externalIdValue == 'df_1')
						System.assertEquals('df_1', fieldAndValue.get(fieldName));
					else
						System.assertEquals('df_2', fieldAndValue.get(fieldName));
				}
				else if(fieldName == 'Finished')
				{
					System.assertEquals(true, fieldAndValue.get(fieldName));
				}
				else if(fieldName == 'Hashtag')
				{
					if(externalIdValue == 'df_1')
						System.assertEquals('#DF13', fieldAndValue.get(fieldName));
					else
						System.assertEquals('#DF14', fieldAndValue.get(fieldName));
				}
				else if(fieldName == 'Month')
				{
					if(externalIdValue == 'df_1')
						System.assertEquals('November', fieldAndValue.get(fieldName));
					else
						System.assertEquals('October', fieldAndValue.get(fieldName));
				}
				else if(fieldName == 'Name')
				{
					if(externalIdValue == 'df_1')
						System.assertEquals('Dreamforce_2013', fieldAndValue.get(fieldName));
					else
						System.assertEquals('Dreamforce_2014', fieldAndValue.get(fieldName));
				}
			}
		}
	}



	private static DataSource.QueryContext updateQueryContextFinishedEvents(DataSource.QueryContext c,
	                                                                        String tableName)
	{
		DataSource.ColumnSelection colSelection = new DataSource.ColumnSelection();
		colSelection.aggregation = DataSource.QueryAggregation.NONE;
		colSelection.columnName = 'Finished';
		colSelection.tableName = tableName;

		DataSource.TableSelection contextTableSelection = new DataSource.TableSelection();
		contextTableSelection.columnsSelected = new List<DataSource.ColumnSelection> {colSelection};

		DataSource.Filter theFilter = new DataSource.Filter();
		theFilter.columnName = 'Finished';
		theFilter.columnValue = true;
		theFilter.subfilters = null;
		theFilter.tableName = tableName;
		theFilter.type = DataSource.FilterType.EQUALS;

		contextTableSelection.filter = theFilter;

		DataSource.Order theOrder = new DataSource.Order();
		theOrder.columnName = 'ExternalId';
		theOrder.direction = DataSource.OrderDirection.ASCENDING;
		theOrder.tableName = tableName;

		contextTableSelection.order = new List<DataSource.Order> {theOrder};

		contextTableSelection.tableSelected = tableName;

		c.tableSelection = contextTableSelection;

		return c;
	}

	private static DataSource.QueryContext updateQueryContextSingleRecord(DataSource.QueryContext c, String tableName)
	{
		DataSource.ColumnSelection colSelection = new DataSource.ColumnSelection();
		List<DataSource.ColumnSelection> columnsSelected = new List<DataSource.ColumnSelection>();

		colSelection = new DataSource.ColumnSelection();
		colSelection.aggregation = DataSource.QueryAggregation.COUNT;

		//Any of them would work as both are used to open a record
		colSelection.columnName = 'ExternalId';
		colSelection.tableName = tableName;
		columnsSelected.add(colSelection);

		DataSource.TableSelection contextTableSelection = new DataSource.TableSelection();
		contextTableSelection.columnsSelected = columnsSelected;

		DataSource.Filter theFilter = new DataSource.Filter();
		theFilter.columnName = 'ExternalId';
		theFilter.columnValue = 'df_1';
		theFilter.subfilters = null;
		theFilter.tableName = tableName;
		theFilter.type = DataSource.FilterType.EQUALS;

		contextTableSelection.filter = theFilter;

		contextTableSelection.tableSelected = tableName;

		c.tableSelection = contextTableSelection;

		return c;
	}

	private static List<Map<String,Object>> getRows(DataSource.ReadContext context)
	{
		List<Map<String, Object>> rows = new List<Map<String, Object>>();

		DataSource.QueryContext myContext = (DataSource.QueryContext)context;
		DataSource.Filter filter = myContext.tableSelection.filter;

		if(myContext.tableSelection.columnsSelected.size() == 1 &&
		   filter.columnValue == 'df_1')
		{
			Map<String, Object> row = new Map<String, Object>();

			row.put('ExternalId', 'df_1');
			row.put('DisplayUrl','http://www.dftest1.com');

			String year = '2013';
			row.put('Name', 'Dreamforce_2013');

			row.put('Month', 'November');
			row.put('Hashtag', '#DF13');
			row.put('Attendes', 120000 );
			row.put('Finished', true);

			rows.add(row);
		}
		else
		{
			for(Integer i=1; i<=3; i++)
			{
				Map<String, Object> row = new Map<String, Object>();

				row.put('ExternalId', 'df_'+i);
				row.put('DisplayUrl','http://www.dftest' + i + '.com');

				String year = i == 1 ? '2013' : i == 2 ? '2014' : '2015';
				row.put('Name', 'Dreamforce_' + year);

				row.put('Month', i == 1 ? 'November' : i == 2 ? 'October' : 'September');
				row.put('Hashtag', i == 1 ? '#DF13' : i == 2 ? '#DF14' : '#DF15');
				row.put('Attendes', i == 1 ? 120000 : i == 2 ? 135000 : null);
				row.put('Finished', i <= 2 ? true : false);

				rows.add(row);
			}
		}

		return rows;
	}
}