using System;
using System.Threading.Tasks;
using Azure.Identity;
using Azure.Security.KeyVault.Keys;

namespace AzCliCred
{
    class Program
    {
        static async Task Main(string[] args)
        {
            Console.WriteLine("Hello World!");

            try
            {
                //var credential = new DefaultAzureCredential();
                var credential = new AzureCliCredential();
                var client = new KeyClient(new Uri("https://stsgpntest-kv.vault.azure.net/"), credential);

                var key = await client.GetKeyAsync("key1");

                Console.WriteLine(key.Value.Name);
            }
            catch (System.Exception)
            {
                throw;
            }
        }
    }
}
