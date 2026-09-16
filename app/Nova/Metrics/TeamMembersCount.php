<?php

namespace App\Nova\Metrics;

use Laravel\Nova\Metrics\Value;
use Illuminate\Http\Request;
use App\Models\TeamMember;

class TeamMembersCount extends Value
{
    /**
     * Вычисление значения карточки.
     *
     * @param Request $request
     * @return mixed
     */
    public function calculate(Request $request)
    {
        return $this->result(TeamMember::count());
    }

    /**
     * Название карточки.
     *
     * @return string
     */
    public function name()
    {
        return __('Члены команды');
    }
}
