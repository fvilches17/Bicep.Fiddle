using Azure.Extensions.AspNetCore.Configuration.Secrets;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Bicep.Fiddle.BlazorApp
{
    public class Program
    {
        public static void Main(string[] args)
        {
            CreateHostBuilder(args).Build().Run();
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                //.ConfigureAppConfiguration((_, configBuilder) =>
                //{
                //    var config = configBuilder.Build();
                //    AddAzureKeyVault(config, configBuilder);
                //})
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.UseStartup<Startup>();
                });

        private static void AddAzureKeyVault(IConfiguration config, IConfigurationBuilder configBuilder)
        {
            var secretClient = new SecretClient(
                vaultUri: new Uri($"https://{config["KeyVaultName"]}.vault.azure.net/"),
                credential: new DefaultAzureCredential());

            configBuilder.AddAzureKeyVault(secretClient, new KeyVaultSecretManager());
        }
    }
}
