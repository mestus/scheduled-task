using System.Threading;
using System.Threading.Tasks;
using Hangfire;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace ScheduledTask
{
    public class Worker : BackgroundService
    {
        private readonly ILogger<Worker> _logger;
        private readonly IConfiguration _configuration;

        public Worker(ILogger<Worker> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            var exe = _configuration.GetValue<string>("Executable");
            var args = _configuration.GetValue<string>("Arguments");
            var schedule = _configuration.GetValue<string>("Schedule");
            _logger.LogInformation($"Scheduling task '{exe}' with args '{args}' and schedule '{schedule}'");
            RecurringJob.AddOrUpdate(() => Run.Command(exe, args), schedule);
        }
    }
}