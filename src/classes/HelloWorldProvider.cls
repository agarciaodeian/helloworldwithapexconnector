/**
 * agarciaodeian
 */

public with sharing class HelloWorldProvider extends DataSource.Provider
{
	override public List<DataSource.AuthenticationCapability> getAuthenticationCapabilities()
	{
		List<DataSource.AuthenticationCapability> capabilities = new List<DataSource.AuthenticationCapability>();
		capabilities.add(DataSource.AuthenticationCapability.ANONYMOUS);
		return capabilities;
	}

	override public List<DataSource.Capability> getCapabilities()
	{
		List<DataSource.Capability> capabilities = new List<DataSource.Capability>();

		capabilities.add(DataSource.Capability.ROW_QUERY);
		capabilities.add(DataSource.Capability.SEARCH);

		return capabilities;
	}

	override public DataSource.Connection getConnection(DataSource.ConnectionParams connectionParams)
	{
		return new HelloWorldConnection(connectionParams);
	}
}