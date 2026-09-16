<?php

namespace App\Nova\Dashboards;

use App\Nova\Metrics\NewServicesTrend;
use App\Nova\Metrics\TeamMembersCount;
use App\Nova\Metrics\TotalProducts;
use App\Nova\Metrics\TotalServices;
use Instructions\VideoInstruction\VideoInstruction;
use Laravel\Nova\Cards\Help;
use Laravel\Nova\Dashboards\Main as Dashboard;
class Main extends Dashboard
{
    /**
     * Get the cards for the dashboard.
     *
     * @return array
     */
    public function cards()
    {
        return [
            new TotalProducts,
            new TotalServices,
            new TeamMembersCount,

            //new VideoInstruction()
        ];
    }
}
