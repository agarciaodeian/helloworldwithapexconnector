/**
 * @agarciaodeian
 */

public with sharing class HelloWorldConnection extends DataSource.Connection
{
	public HelloWorldConnection(DataSource.ConnectionParams connectionParams) {}

	override public List<DataSource.Table> sync()
	{
		List<DataSource.Table> tables = new List<DataSource.Table>();
		List<DataSource.Column> columns;

		columns = new List<DataSource.Column>();

		//Standard fields
		columns.add(DataSource.Column.text('ExternalId', 255));
		columns.add(DataSource.Column.url('DisplayUrl'));

		//Custom fields
		columns.add(DataSource.Column.text('Name', 80));
		columns.add(DataSource.Column.text('Month', 32));
		columns.add(DataSource.Column.text('Hashtag',15));
		columns.add(DataSource.Column.number('Attendes',18,0));
		columns.add(DataSource.Column.boolean('Finished'));

		//Define table
		tables.add(DataSource.Table.get('DreamforceEvents', 'Name', columns));

		return tables;
	}

	override public DataSource.TableResult query(DataSource.QueryContext context)
	{
		if (context.tableSelection.columnsSelected.size() == 1
		    && context.tableSelection.columnsSelected.get(0).aggregation == DataSource.QueryAggregation.COUNT)
		{
			List<Map<String,Object>> rows = getRows(context);

			List<Map<String,Object>> response = DataSource.QueryUtils.filter(context, getRows(context));
			List<Map<String, Object>> countResponse = new List<Map<String, Object>>();
			Map<String, Object> countRow = new Map<String, Object>();

			countRow.put(context.tableSelection.columnsSelected.get(0).columnName,response.size());
			countResponse.add(countRow);
			return DataSource.TableResult.get(context,countResponse);
		}
		else
		{
			List<Map<String,Object>> filteredRows = DataSource.QueryUtils.filter(context, getRows(context));
			List<Map<String,Object>> sortedRows = DataSource.QueryUtils.sort(context, filteredRows);
			List<Map<String,Object>> limitedRows = DataSource.QueryUtils.applyLimitAndOffset(context,sortedRows);
			return DataSource.TableResult.get(context, limitedRows);
		}
	}

	override public List<DataSource.TableResult> search(DataSource.SearchContext context)
	{
		List<DataSource.TableResult> results = new List<DataSource.TableResult>();
		for(DataSource.TableSelection tableSelection : context.tableSelections)
		{
			results.add(DataSource.TableResult.get(tableSelection,getRows(context)));
		}
		return results;
	}

	private List<Map<String,Object>> getRows(DataSource.ReadContext context)
	{
		List<Map<String, Object>> rows = new List<Map<String, Object>>();

		DataSource.QueryContext myContext = (DataSource.QueryContext)context;
		DataSource.Filter filter = myContext.tableSelection.filter;

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

		return rows;
	}
}